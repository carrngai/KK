pageextension 50133 "Customer Ledger Entries Ext" extends "Customer Ledger Entries"
{
    layout
    {
        // Add changes to page layout here
        addafter("Document No.")
        {

            field("Pre-Assigned No."; Rec."Pre-Assigned No.")
            {
                ToolTip = 'Specifies the value of the Pre-Assigned No. field';
                ApplicationArea = All;
            }
        }
        modify("Pmt. Discount Date") { Visible = false; }
        modify("Pmt. Disc. Tolerance Date") { Visible = false; }
        modify("Original Pmt. Disc. Possible") { Visible = false; }
        modify("Remaining Pmt. Disc. Possible") { Visible = false; }
        modify("Max. Payment Tolerance") { Visible = false; }
        modify("Exported to Payment File") { Visible = false; }
        modify("Message to Recipient") { Visible = false; }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}