pageextension 50130 "Vendor Card Ext" extends "Vendor Card"
{
    layout
    {
        // Add changes to page layout here
        modify("Privacy Blocked") { Visible = false; }
        modify("Document Sending Profile") { Visible = false; }
        modify("Search Name") { Visible = false; }

        modify(GLN) { Visible = false; }
        modify("Gen. Bus. Posting Group") { ShowMandatory = false; }
        modify("Block Payment Tolerance") { Visible = false; }
        modify("Cash Flow Payment Terms Code") { Visible = false; }
        modify("Creditor No.") { Visible = false; }

        modify(Receiving) { Visible = false; }

        modify(VendorHistBuyFromFactBox) { Visible = false; }
        addafter(VendorStatisticsFactBox)
        {
            part(Control1905532107; "Dimensions FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Table ID" = CONST(23),
                              "No." = FIELD("No.");
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        modify(SendApprovalRequest) { Promoted = false; }
        modify(CancelApprovalRequest) { Promoted = false; }
        modify(CreateFlow) { Promoted = false; }
        modify(SeeFlows) { Promoted = false; }

        modify(NewPurchaseInvoice) { Promoted = false; }
        modify(NewPurchaseOrder) { Promoted = false; }
        modify(NewPurchaseCrMemo) { Promoted = false; }

        modify("Ledger E&ntries") { Promoted = true; PromotedCategory = Category7; }
        // modify(Prices) { Promoted = false; }
        // modify("Line Discounts") { Promoted = false; }
        modify(Quotes) { Promoted = false; }
        modify(Orders) { Promoted = false; }
        modify("Return Orders") { Promoted = false; }
        modify(Purchases) { Promoted = false; }
    }

    var
        myInt: Integer;
}