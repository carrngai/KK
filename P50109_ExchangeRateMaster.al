page 50109 "Exchange Rate Master"
{
    Caption = 'Exchange Rate Master';
    DataCaptionFields = "Currency Code";
    PageType = List;
    SourceTable = "Exchange Rate Master";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the date on which the exchange rate on this line comes into effect.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the code of the foreign currency on this line.';
                }
                field("Relational Currency Code"; Rec."Relational Currency Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies how you want to set up the two currencies, one of the currencies can be LCY, for which you want to register exchange rates.';
                }
                field("Exchange Rate Amount"; Rec."Exchange Rate Amount")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the amounts that are used to calculate exchange rates for the foreign currency on this line.';
                }
                field("Relational Exch. Rate Amount"; Rec."Relational Exch. Rate Amount")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the amounts that are used to calculate exchange rates for the foreign currency on this line.';
                }
                field("Adjustment Exch. Rate Amount"; Rec."Adjustment Exch. Rate Amount")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the amounts that are used to calculate exchange rates that will be used by the Adjust Exchange Rates batch job.';
                }
                field("Relational Adjmt Exch Rate Amt"; Rec."Relational Adjmt Exch Rate Amt")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the amounts that are used to calculate exchange rates that will be used by the Adjust Exchange Rates batch job.';
                }
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

                field("Fix Exchange Rate Amount"; Rec."Fix Exchange Rate Amount")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies if the currency''s exchange rate can be changed on invoices and journal lines.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        CurrExchRate: Record "Exchange Rate Master";
    begin
        CurrExchRate := xRec;
        if not BelowxRec then begin
            CurrExchRate.CopyFilters(Rec);
            if CurrExchRate.Next(-1) <> 0 then
                Rec.TransferFields(CurrExchRate, false)
        end else
            Rec.TransferFields(CurrExchRate, false)
    end;
}

