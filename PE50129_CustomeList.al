pageextension 50129 "Customer List Ext" extends "Customer List"
{
    layout
    {
        // Add changes to page layout here
        modify("Location Code") { Visible = false; }
        modify("Responsibility Center") { Visible = false; }
        modify("Sales (LCY)") { Visible = false; }
        modify("IC Partner Code") { Visible = true; }
        addafter(Name)
        {
            field("Netting Vendor No."; Rec."Netting Vendor No.")
            {
                ToolTip = 'Specifies the value of the Netting Vendor No. field';
                ApplicationArea = All;
            }
        }
        modify(SalesHistSelltoFactBox) { Visible = false; }
        addafter(CustomerStatisticsFactBox)
        {
            part(Control1905532107; "Dimensions FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Table ID" = CONST(18),
                              "No." = FIELD("No.");
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        modify(PaymentRegistration) { Promoted = false; }
        modify(NewSalesQuote) { Promoted = false; }
        modify(NewSalesOrder) { Promoted = false; }
        modify(NewSalesInvoice) { Promoted = false; }
        modify(NewSalesCrMemo) { Promoted = false; }
        modify(NewReminder) { Promoted = false; }
        // modify(Prices_Prices) { Promoted = false; }
        // modify(Prices_LineDiscounts) { Promoted = false; }

        modify(ReportAgedAccountsReceivable) { Promoted = true; PromotedCategory = Report; }
        modify("Customer - Order Summary") { Promoted = false; }
        modify("Customer - Sales List") { Promoted = false; }

    }

    var
        myInt: Integer;
}