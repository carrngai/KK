pageextension 50114 "IC General Journal Ext" extends "IC General Journal"
{
    layout
    {
        // Add changes to page layout here
        modify("Bal. Account Type") { Visible = false; }
        modify("Bal. Account No.") { Visible = false; }
        modify("Bal. Gen. Bus. Posting Group") { Visible = false; }
        modify("Bal. Gen. Posting Type") { Visible = false; }
        modify("Bal. Gen. Prod. Posting Group") { Visible = false; }
        addbefore("IC Partner G/L Acc. No.")
        {
            field("IC Path Code"; Rec."IC Path Code")
            {
                ToolTip = 'Specifies the value of the IC Path Code field';
                ApplicationArea = All;
            }
        }
        modify(JournalLineDetails) { Visible = false; }
        addbefore(JournalLineDetails)
        {
            part("Dimension Set"; "Dimension Set Entries FactBox")
            {
                ApplicationArea = all;
                SubPageLink = "Dimension Set ID" = field("Dimension Set ID");
            }
        }

    }

    actions
    {
        // Add changes to page actions here
        addfirst("&Line")
        {
            action("IC Allocation")
            {
                ApplicationArea = Suite;
                Caption = 'Allocations';
                Image = Allocations;
                Promoted = true;
                PromotedCategory = Category7;
                RunObject = Page "IC Gen. Jnl. Allocations";
                RunPageLink = "Journal Template Name" = FIELD("Journal Template Name"),
                                "Journal Batch Name" = FIELD("Journal Batch Name"),
                                "Journal Line No." = FIELD("Line No.");


                ToolTip = 'Allocate the amount on the selected journal line to the dimensions that you specify.';
            }
        }
    }

    var
        myInt: Integer;
}