pageextension 50144 "Currency Exchange Rates Ext" extends "Currency Exchange Rates"
{
    layout
    {
        // Add changes to page layout here
        addbefore("Fix Exchange Rate Amount")
        {

            field("Exch. Rate Amt. - Consol."; Rec."Exch. Rate Amt. - Consol.")
            {
                ToolTip = 'Specifies the value of the Exch. Rate Amt. for Consol. Avg. Rate Cal. field.';
                ApplicationArea = All;
            }
            field("Rel. Exch. Rate Amt. - Consol."; Rec."Rel. Exch. Rate Amt. - Consol.")
            {
                ToolTip = 'Specifies the value of the Relational Exch. Rate Amt. for Consol. Avg. Rate Cal. field.';
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}