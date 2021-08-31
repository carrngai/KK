pageextension 50114 "General Journal Ext" extends "General Journal"
{
    layout
    {
        // Add changes to page layout here
        modify("Gen. Posting Type") { Visible = false; }
        modify("Gen. Bus. Posting Group") { Visible = false; }
        modify("Gen. Prod. Posting Group") { Visible = false; }
        modify("EU 3-Party Trade") { Visible = false; }
        modify("Bal. Gen. Bus. Posting Group") { Visible = false; }
        modify("Bal. Gen. Posting Type") { Visible = false; }
        modify("Bal. Gen. Prod. Posting Group") { Visible = false; }
        modify("Deferral Code") { Visible = false; }
        modify(Correction) { Visible = false; }
        modify(Comment) { Visible = false; }
        addbefore("Bal. Account type")
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
            }
        }
        addafter("Bal. Account No.")
        {
            field("Netting Source No."; Rec."Netting Source No.")
            {
                ToolTip = 'Specifies the value of the Source No. field';
                ApplicationArea = All;
                Editable = false;
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

                ToolTip = 'Allocate the amount on the selected journal line to the dimensions that you specify.';

                trigger OnAction()
                begin
                    if Rec."IC Path Code" = '' then
                        Error('IC Path Code must not be blank');
                end;


            }
        }
    }

}