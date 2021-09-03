pageextension 50126 "Apply Customer Entries Ext" extends "Apply Customer Entries"
{
    layout
    {
        // Add changes to page layout here
        modify("Pmt. Disc. Amount") { Visible = false; }
        modify("Pmt. Disc. Tolerance Date") { Visible = false; }
        modify("Pmt. Discount Date") { Visible = false; }
        modify("Max. Payment Tolerance") { Visible = false; }
        modify("Remaining Pmt. Disc. Possible") { Visible = false; }
        modify("Original Pmt. Disc. Possible") { Visible = false; }
        addafter("Document No.")
        {
            field("Pre-Assigned No."; Rec."Pre-Assigned No.")
            {
                ToolTip = 'Specifies the value of the Pre-Assigned No. field';
                ApplicationArea = All;
            }

            field("External Document No."; Rec."External Document No.")
            {
                ToolTip = 'Specifies the value of the External Document No. field';
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        modify("Set Applies-to ID")
        {
            Promoted = true;
            PromotedIsBig = true;
            PromotedCategory = Process;
        }
    }

}