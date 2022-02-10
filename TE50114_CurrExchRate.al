tableextension 50114 "Currency Exchange Rate Ext" extends "Currency Exchange Rate"
{
    fields
    {
        // Add changes to table fields here
        field(50100; "Exch. Rate Amt. - Consol."; Decimal)
        {
            Caption = 'Exch. Rate Amt. for Consol. Avg. Rate Cal.';
            DecimalPlaces = 1 : 6;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestField("Exch. Rate Amt. - Consol.");
            end;
        }
        field(50101; "Rel. Exch. Rate Amt. - Consol."; Decimal)
        {
            AccessByPermission = TableData Currency = R;
            Caption = 'Relational Exch. Rate Amt. for Consol. Avg. Rate Cal.';
            DecimalPlaces = 1 : 6;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestField("Rel. Exch. Rate Amt. - Consol.");
            end;
        }
    }

    var
        myInt: Integer;

    procedure CONSOLExchangeRate(Date: Date; CurrencyCode: Code[10]): Decimal
    var
        RelExchangeRateAmt: Decimal;
        ExchangeRateAmt: Decimal;
        RelCurrencyCode: Code[10];
        CurrencyFactor: Decimal;

    begin
        if CurrencyCode = '' then
            exit(1);
        FindCurrency(Date, CurrencyCode, 1);

        TestField("Exch. Rate Amt. - Consol.");
        TestField("Rel. Exch. Rate Amt. - Consol.");

        RelExchangeRateAmt := "Rel. Exch. Rate Amt. - Consol.";
        ExchangeRateAmt := "Exch. Rate Amt. - Consol.";
        RelCurrencyCode := "Relational Currency Code";
        if "Relational Currency Code" = '' then
            CurrencyFactor := "Exch. Rate Amt. - Consol." / "Rel. Exch. Rate Amt. - Consol."
        else begin
            FindCurrency(Date, RelCurrencyCode, 2);
            TestField("Exch. Rate Amt. - Consol.");
            TestField("Rel. Exch. Rate Amt. - Consol.");
            CurrencyFactor := (ExchangeRateAmt * "Exch. Rate Amt. - Consol.") / (RelExchangeRateAmt * "Rel. Exch. Rate Amt. - Consol.");
        end;
        exit(CurrencyFactor);
    end;

}