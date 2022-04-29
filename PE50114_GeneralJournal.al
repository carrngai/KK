pageextension 50114 "General Journal Ext" extends "General Journal"
{
    layout
    {
        // Add changes to page layout here
        modify("Gen. Posting Type") { Visible = false; }
        modify("Gen. Bus. Posting Group") { Visible = false; }
        modify("Gen. Prod. Posting Group") { Visible = false; }
        addafter("Credit Amount")
        {
            field("Amount (LCY)_"; Rec."Amount (LCY)")
            {
                ToolTip = 'Specifies the value of the Amount (LCY) field';
                ApplicationArea = All;
            }
        }
        modify("EU 3-Party Trade") { Visible = false; }
        modify("Bal. Gen. Bus. Posting Group") { Visible = false; }
        modify("Bal. Gen. Posting Type") { Visible = false; }
        modify("Bal. Gen. Prod. Posting Group") { Visible = false; }
        modify("Deferral Code") { Visible = false; }
        modify(Correction) { Visible = false; }
        modify(Comment) { Visible = false; }
        modify("Bal. Account Type") { Visible = false; }
        modify("Bal. Account No.") { Visible = false; }
        modify("External Document No.") { Visible = true; }
        addafter(ShortcutDimCode8)
        {
            field("IC Path Code"; Rec."IC Path Code") //G014
            {
                ToolTip = 'Specifies the value of the IC Path Code field';
                ApplicationArea = All;

                trigger OnLookup(var Text: Text): Boolean
                var
                    ICPath: Record "IC Transaction Path";
                    ICPath_: Page "IC Transaction Path";
                begin
                    ICPath.SetFilter("From Company", CompanyName);
                    ICPath_.SetTableView(ICPath);
                    ICPath_.LookupMode := true;
                    if ICPath_.RunModal() = Action::LookupOK then begin
                        ICPath_.GetRecord(ICPath);
                        Rec."IC Path Code" := ICPath."Path Code";
                        if Rec.CheckICPathCode(Rec) then begin
                            Rec.InsertICDefaultLine(Rec);
                            Rec.Validate("IC Path Code", ICPath."Path Code"); //trigger InsertICAllocation
                        end;
                    end;
                    CurrPage.Update();
                end;
            }
            field("IC Source Document No."; Rec."IC Source Document No.")
            {
                ToolTip = 'Specifies the value of the IC Source Document No. field.';
                ApplicationArea = All;
            }
            field("IC Source Company"; Rec."IC Source Company")
            {
                ToolTip = 'Specifies the value of the IC Source Company field.';
                ApplicationArea = All;
            }
            field("Allow Zero-Amount Posting"; Rec."Allow Zero-Amount Posting")
            {
                ToolTip = 'Specifies the value of the Allow Zero-Amount Posting field.';
                ApplicationArea = All;
                Editable = false;
            }
            field("System-Created Entry"; Rec."System-Created Entry")
            {
                ToolTip = 'Specifies the value of the System-Created Entry field.';
                ApplicationArea = All;
                Editable = false;
            }
            field("Bal. Account Type_"; Rec."Bal. Account Type")
            {
                ToolTip = 'Specifies the value of the Bal. Account Type field';
                ApplicationArea = All;
                // Editable = false;
            }
            field("Bal. Account No._"; Rec."Bal. Account No.")
            {
                ToolTip = 'Specifies the value of the Bal. Account No. field';
                ApplicationArea = All;
                Editable = false;
            }
            field("Netting Source No."; Rec."Netting Source No.")
            {
                ToolTip = 'Specifies the value of the Source No. field';
                ApplicationArea = All;
                Editable = false;
                Visible = false;
            }


        }
        modify(JournalLineDetails) { Visible = false; }
        modify(IncomingDocAttachFactBox) { Visible = false; }
        modify(Control1900919607) { Visible = true; }     //"Dimension Set Entries FactBox"
    }

    actions
    {
        // Add changes to page actions here
        modify(IncomingDocument) { Visible = false; }
        modify("Renumber Document Numbers")
        {
            Promoted = true;
            PromotedCategory = Process;
        }
        modify("Test Report")
        {
            Promoted = true;
            PromotedCategory = Category9;
        }
        modify(Approvals) { Promoted = false; }

        addlast("&Line")
        {
            action("IC Allocation") //G014
            {
                ApplicationArea = all;
                Caption = 'IC Allocations';
                Image = Allocations;
                Promoted = true;
                PromotedCategory = Category10;
                RunObject = Page "IC Gen. Jnl. Allocations";
                RunPageLink = "Journal Template Name" = FIELD("Journal Template Name"),
                                "Journal Batch Name" = FIELD("Journal Batch Name"),
                                "Journal Line No." = FIELD("Line No.");
                Enabled = ApplyEntriesActionEnabled;

                ToolTip = 'Allocate the amount on the selected journal line to the IC Bal. Account(s) and Dimension(s).';

            }
        }
    }

    var
        ApplyEntriesActionEnabled: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        EnableApplyEntriesAction;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        EnableApplyEntriesAction;
    end;

    local procedure EnableApplyEntriesAction()
    begin
        ApplyEntriesActionEnabled :=
          (Rec."Account Type" in [Rec."Account Type"::Customer, Rec."Account Type"::Vendor]) or
          (Rec."Bal. Account Type" in [Rec."Bal. Account Type"::Customer, Rec."Bal. Account Type"::Vendor]);
    end;
}
