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
            field("IC Bal. Account Type"; Rec."IC Bal. Account Type") //G014
            {
                ToolTip = 'Specifies the value of the IC Bal. Account Type field';
                ApplicationArea = All;
            }
            field("IC Bal. Account No."; Rec."IC Bal. Account No.") //G014
            {
                ToolTip = 'Specifies the value of the IC Bal. Account No. field';
                ApplicationArea = All;

                trigger OnLookup(var Text: Text): Boolean
                var
                    ICPathDetail: Record "IC Transaction Path Details";
                    Company2: Code[50];
                    GLAcc2: Record "G/L Account";
                    GLList2: Page "G/L Account List";
                    BankAcc2: Record "Bank Account";
                    BankList2: Page "Bank Account List";
                begin
                    ICPathDetail.Reset();
                    ICPathDetail.SetRange("Path Code", Rec."IC Path Code");
                    if ICPathDetail.FindLast() then
                        Company2 := ICPathDetail."To Company"
                    else
                        Error('IC Path Detail not found');

                    IF Rec."IC Bal. Account Type" = Rec."IC Bal. Account Type"::"Bank Account" then begin
                        BankAcc2.ChangeCompany(Company2);
                        BankList2.ChangeToCompany(Company2);
                        BankList2.SetTableView(BankAcc2);
                        BankList2.Editable := false;
                        BankList2.LookupMode := true;
                        if BankList2.RunModal() = Action::LookupOK then begin
                            BankList2.GetRecord(BankAcc2);
                            Rec."IC Bal. Account No." := BankAcc2."No.";
                            ICEnable := true;
                        end;
                    end;

                    IF Rec."IC Bal. Account Type" = Rec."IC Bal. Account Type"::"G/L Account" then begin
                        GLAcc2.ChangeCompany(Company2);
                        GLAcc2.SetRange("Account Type", GLAcc2."Account Type"::Posting);
                        GLAcc2.SetRange("Direct Posting", true);
                        GLList2.ChangeToCompany(Company2);
                        GLList2.Editable := false;
                        GLList2.SetTableView(GLAcc2);
                        GLList2.LookupMode := true;
                        if GLList2.RunModal() = Action::LookupOK then begin
                            GLList2.GetRecord(GLAcc2);
                            Rec."IC Bal. Account No." := GLAcc2."No.";
                            ICEnable := true;
                        end;
                    end;
                end;

                trigger OnValidate()
                begin
                    EnableICALlocationAction();
                    CurrPage.Update(true);
                end;
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
                Enabled = ICEnable;

                ToolTip = 'Allocate the amount on the selected journal line to the dimensions that you specify.';

                trigger OnAction()
                var
                    l_ICAccMapping: Record "IC Transaction Account Mapping";
                    l_ICAllocation: Record "IC Gen. Jnl. Allocation";
                begin
                    //If IC Allication is blank, create set from Mapping
                end;
            }
        }
    }

    var
        ICEnable: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        EnableICALlocationAction;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        EnableICALlocationAction;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        EnableICALlocationAction;
    end;

    local procedure EnableICALlocationAction()
    begin
        if (Rec."IC Bal. Account No." <> '') then
            ICEnable := true
        else
            ICEnable := false;
    end;
}