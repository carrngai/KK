pageextension 50114 "General Journal Ext" extends "General Journal"
{
    layout
    {
        // Add changes to page layout here
        modify("EU 3-Party Trade") { Visible = false; }
        modify("Bal. Account Type") { Visible = false; }
        modify("Bal. Account No.") { Visible = false; }
        modify("Bal. Gen. Bus. Posting Group") { Visible = false; }
        modify("Bal. Gen. Posting Type") { Visible = false; }
        modify("Bal. Gen. Prod. Posting Group") { Visible = false; }
        modify(Correction) { Visible = false; }
        modify(Comment) { Visible = false; }
        modify("Applies-to Doc. Type") { Visible = true; }
        modify("Applies-to Doc. No.") { Visible = true; }
        addbefore("Bal. Account Type")
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
        modify(JournalLineDetails) { Visible = false; }
        modify(IncomingDocAttachFactBox) { Visible = false; }
    }

    actions
    {
        // Add changes to page actions here
        addlast("&Line")
        {
            action("IC Allocation") //G014
            {
                ApplicationArea = all;
                Caption = 'Allocations';
                Image = Allocations;
                Promoted = true;
                PromotedCategory = Category10;
                RunObject = Page "IC Gen. Jnl. Allocations";
                RunPageLink = "Journal Template Name" = FIELD("Journal Template Name"),
                                "Journal Batch Name" = FIELD("Journal Batch Name"),
                                "Journal Line No." = FIELD("Line No.");

                ToolTip = 'Allocate the amount on the selected journal line to the dimensions that you specify.';
            }

            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

}