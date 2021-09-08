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
        addafter(ShortcutDimCode8)
        {
            field("IC Path Code"; Rec."IC Path Code") //G014
            {
                ToolTip = 'Specifies the value of the IC Path Code field';
                ApplicationArea = All;
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