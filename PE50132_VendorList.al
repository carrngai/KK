pageextension 50132 "Vendor List Ext" extends "Vendor List"
{
    layout
    {
        // Add changes to page layout here
        modify("Location Code") { Visible = false; }
        modify("IC Partner Code") { Visible = true; }
        modify("Search Name") { Visible = false; }
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
        modify(NewPurchaseInvoice) { Visible = false; }
        modify(NewPurchaseOrder) { Visible = false; }
        modify(NewPurchaseCrMemo) { Visible = false; }
        modify("Aged Accounts Payable") { Promoted = true; PromotedCategory = Report; }
    }

    var
        myInt: Integer;
}