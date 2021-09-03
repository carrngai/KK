pageextension 50134 "Vendor Ledger Entries Ext" extends "Vendor Ledger Entries"
{
    layout
    {
        // Add changes to page layout here
        modify("Payment Reference") { Visible = false; }
        modify("Creditor No.") { Visible = false; }
        modify("Pmt. Discount Date") { Visible = false; }
        modify("Pmt. Disc. Tolerance Date") { Visible = false; }
        modify("Original Pmt. Disc. Possible") { Visible = false; }
        modify("Remaining Pmt. Disc. Possible") { Visible = false; }
        modify("Max. Payment Tolerance") { Visible = false; }
        modify("Exported to Payment File") { Visible = false; }
        modify("Message to Recipient") { Visible = false; }
        modify(RecipientBankAcc) { Visible = false; }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}