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