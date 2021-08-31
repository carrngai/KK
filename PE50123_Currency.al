pageextension 50123 "Currencies Ext" extends Currencies
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addafter("Exch. &Rates")
        {
            action("Exch. Rate Master")
            {
                ApplicationArea = All;
                RunObject = page "Exchange Rate Master";
                RunPageLink = "Currency Code" = FIELD(Code);
                Promoted = true;
                PromotedCategory = Process;
            }
        }
        modify("Exchange Rate Services") { Visible = false; }
        modify(UpdateExchangeRates) { Visible = false; }
        modify("Change Payment &Tolerance") { Visible = false; }
    }


}