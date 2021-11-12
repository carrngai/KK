pageextension 50128 "Customer Card Ext" extends "Customer Card"
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
        modify(TotalSales2) { Visible = false; }
        modify("CustSalesLCY - CustProfit - AdjmtCostLCY") { Visible = false; }
        modify(AdjCustProfit) { Visible = false; }
        modify(AdjProfitPct) { Visible = false; }
        modify("Use GLN in Electronic Document") { Visible = false; }
        modify("Copy Sell-to Addr. to Qte From") { Visible = false; }
        modify("Gen. Bus. Posting Group") { ShowMandatory = false; }
        modify("Prepayment %") { Visible = false; }
        modify("Cash Flow Payment Terms Code") { Visible = false; }
        modify("Block Payment Tolerance") { Visible = false; }
        modify(PricesandDiscounts) { Visible = false; }
        modify("Customer Disc. Group") { Visible = false; }
        modify("Customer price Group") { Visible = false; }
        modify(Shipping) { Visible = false; }

        //modify(PriceAndLineDisc) { Visible = false; }

        modify(SalesHistSelltoFactBox) { Visible = false; }
        modify(Control1905532107) { Visible = true; }
    }

    actions
    {
        // Add changes to page actions here

        modify(PaymentRegistration) { Visible = false; }

        modify(NewSalesQuote) { Promoted = false; }
        modify(NewSalesInvoice) { Promoted = false; }
        modify(NewSalesOrder) { Promoted = false; }
        modify(NewSalesCreditMemo) { Promoted = false; }
        modify(NewReminder) { Promoted = false; }

        modify(Approve) { Promoted = false; }
        modify(Reject) { Promoted = false; }
        modify(Delegate) { Promoted = false; }
        modify(Comment) { Promoted = false; }

        modify(SendApprovalRequest) { Promoted = false; }
        modify(CancelApprovalRequest) { Promoted = false; }
        modify(CreateFlow) { Promoted = false; }
        modify(SeeFlows) { Promoted = false; }

        // modify(Prices) { Promoted = false; }
        // modify("Line Discounts") { Promoted = false; }
        // modify("Prices and Discounts Overview") { Promoted = false; }

        modify("Ledger E&ntries") { Promoted = true; PromotedCategory = Category9; }
        modify("Direct Debit Mandates") { Promoted = false; }
        modify(ShipToAddresses) { Promoted = false; }
        modify(Quotes) { Promoted = false; }
        modify(Orders) { Promoted = false; }
        modify(Invoices) { Promoted = false; }
        modify("Return Orders") { Promoted = false; }
        modify("&Jobs") { Promoted = false; }

    }

    var
        myInt: Integer;
}