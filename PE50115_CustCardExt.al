pageextension 50115 "Customer Card" extends "Customer Card"
{
    layout
    {
        // Add changes to page layout here
        addafter("IC Partner Code")
        {
            field("Netting Vendor No."; Rec."Netting Vendor No.")
            {
                ToolTip = 'Specifies the value of the Netting Vendor No. field';
                ApplicationArea = All;
            }
        }
        modify("Privacy Blocked") { Visible = false; }
        modify("Document Sending Profile") { Visible = false; }
        modify("Use GLN in Electronic Document") { Visible = false; }
        modify("Copy Sell-to Addr. to Qte From") { Visible = false; }
        modify("Gen. Bus. Posting Group") { ShowMandatory = false; }
        modify("Prepayment %") { Visible = false; }
        modify("Cash Flow Payment Terms Code") { Visible = false; }
        modify("Block Payment Tolerance") { Visible = false; }
        modify("Customer Disc. Group") { Visible = false; }
        modify("Customer price Group") { Visible = false; }
        modify(Shipping) { Visible = false; }
    }

    actions
    {
        // Add changes to page actions here
        modify("Ledger E&ntries") { Promoted = true; PromotedCategory = Category5; }
        modify(PaymentRegistration) { Visible = false; }
    }

    var
        myInt: Integer;
}