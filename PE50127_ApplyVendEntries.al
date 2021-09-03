pageextension 50127 "Apply Vendor Entries Ext" extends "Apply Vendor Entries"
{
    layout
    {
        // Add changes to page layout here
        modify("External Document No.") { Visible = true; }
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
        modify(ActionSetAppliesToID)
        {
            Promoted = true;
            PromotedIsBig = true;
            PromotedCategory = Process;
        }
    }

}