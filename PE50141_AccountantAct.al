pageextension 50141 AccountantAct_Ext extends "Accountant Activities"
{
    layout
    {
        // Add changes to page layout here
        modify("Overdue Purchase Documents") { Visible = false; }
        modify("New Incoming Documents") { Visible = false; }

        addfirst(Payments)
        {
            field("Overdue Sales Documents"; Rec."Overdue Sales Documents")
            {
                ApplicationArea = Basic, Suite;
                DrillDownPageID = "Customer Ledger Entries";
                ToolTip = 'Specifies the number of invoices where the customer is late with payment.';
            }
            field("Overdue Purchase Documents_"; Rec."Overdue Purchase Documents")
            {
                ApplicationArea = Basic, Suite;
                DrillDownPageID = "Vendor Ledger Entries";
                ToolTip = 'Specifies the number of purchase invoices where you are late with payment.';
            }
        }
        modify("Purch. Invoices Due Next Week") { Visible = false; }
        modify("Purchase Discounts Next Week") { Visible = false; }
        modify("Document Approvals") { Visible = false; }
        modify(Financials) { Visible = false; }
        modify("Incoming Documents") { Visible = false; }
        modify("Product Videos") { Visible = false; }
        modify("Get started") { Visible = false; }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}