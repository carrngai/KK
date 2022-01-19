report 50107 "Calculate BU Average Rate"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Business Unit"; "Business Unit")
        {
            trigger OnPreDataItem()
            var
                l_BU: Record "Business Unit";
            begin
                // l_BU.CopyFilters("Business Unit");
                // l_BU.SetRange("Currency Exchange Rate Table", "Currency Exchange Rate Table"::"Business Unit");
                // if l_BU.FindSet() then
                //     Error('All BU(s) must get Currency Exchange Rate Table from current(Local) company');

                CheckConsolidDates(ConsolidStartDate, ConsolidEndDate);
            end;

            trigger OnAfterGetRecord()
            var
                l_AccountingPeriod: Record "Accounting Period";
            begin

                l_AccountingPeriod.Reset();
                l_AccountingPeriod.SetRange("New Fiscal Year", true);
                l_AccountingPeriod.SetFilter("Starting Date", '..%1', ConsolidStartDate);
                if l_AccountingPeriod.FindLast() then
                    FYStartDate := l_AccountingPeriod."Starting Date"
                else
                    Error('FY Start Date does not exist');

                if "Currency Exchange Rate Table" = "Currency Exchange Rate Table"::Local then begin
                    ExchRate.Reset();
                    FYStartRate := 1 / ExchRate.ExchangeRate(FYStartDate, "Currency Code");
                    ConsoEndRate := 1 / ExchRate.ExchangeRate(ConsolidEndDate, "Currency Code");
                    if (FYStartRate <> 0) and (ConsoEndRate <> 0) then begin
                        //System calculates “Average Rate (Manual)” for each Business Unit 
                        //by (Rate @ Consolidation Period End Date + Rate @ Fiscal Year Start Date) / 2
                        "Business Unit"."Income Currency Factor" := 1 / ((FYStartRate + ConsoEndRate) / 2);
                        "Business Unit"."Balance Currency Factor" := 1 / ConsoEndRate;
                        "Business Unit".Modify();
                    end;
                end;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    group("Consolidation Period")
                    {
                        field(ConsolidStartDate; ConsolidStartDate)
                        {
                            ApplicationArea = All;
                            Caption = 'Starting Date';
                        }
                        field(ConsolidEndDate; ConsolidEndDate)
                        {
                            ApplicationArea = All;
                            Caption = 'Ending Date';
                        }
                        field(ParentCurrencyCode; ParentCurrencyCode)
                        {
                            ApplicationArea = Suite;
                            Caption = 'Parent Currency Code';
                            ToolTip = 'Specifies the parent currency code.';
                        }
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if ConsolidStartDate = 0D then
                ConsolidStartDate := WorkDate;
            if ConsolidEndDate = 0D then
                ConsolidEndDate := WorkDate;

            if ParentCurrencyCode = '' then begin
                GLSetup.Get();
                ParentCurrencyCode := GLSetup."LCY Code";
            end;
        end;
    }

    var
        GLSetup: Record "General Ledger Setup";
        ParentCurrencyCode: Code[10];
        SubsidCurrencyCode: Code[10];
        AdditionalCurrencyCode: Code[10];
        ConsolidStartDate: Date;
        ConsolidEndDate: Date;
        FYStartDate: Date;
        ExchRate: Record "Currency Exchange Rate";
        ConsoEndRate: Decimal;
        FYStartRate: Decimal;
        Text006: Label 'Enter the starting date for the consolidation period.';
        Text007: Label 'Enter the ending date for the consolidation period.';
        Text022: Label 'A %1 with %2 on a closing date (%3) was found while consolidating nonclosing entries (%4 %5).';
        Text024: Label 'There is no %1 to consolidate.';
        Text028: Label 'You must create a new fiscal year in the consolidated company.';
        Text023: Label 'Do you want to update Average Rate(Manual) for consolidate in the period from %1 to %2?';
        Text030: Label 'When using closing dates, the starting and ending dates must be the same.';
        Text032: Label 'The %1 is later than the %2 in company %3.';
        ConsPeriodSubsidiaryQst: Label 'The consolidation period %1 .. %2 is not within the fiscal year of one or more of the subsidiaries.\Do you want to proceed with the calculation?', Comment = '%1 and %2 - request page values';
        ConsPeriodCompanyQst: Label 'The consolidation period %1 .. %2 is not within the fiscal year %3 .. %4 of the consolidated company %5.\Do you want to proceed with the calculation?', Comment = '%1, %2, %3, %4 - request page values, %5 - company name';


    local procedure CheckConsolidDates(StartDate: Date; EndDate: Date)
    var
        BusUnit: Record "Business Unit";
        ConfirmManagement: Codeunit "Confirm Management";
        ConsolPeriodInclInFiscalYears: Boolean;
    begin
        if StartDate = 0D then
            Error(Text006);
        if EndDate = 0D then
            Error(Text007);

        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(Text023, StartDate, EndDate), true) then
            CurrReport.Break();

        CheckClosingDates(StartDate, EndDate);

        BusUnit.CopyFilters("Business Unit");
        BusUnit.SetRange(Consolidate, true);
        if not BusUnit.Find('-') then
            Error(Text024, BusUnit.TableCaption);

        ConsolPeriodInclInFiscalYears := true;
        repeat
            if (StartDate = NormalDate(StartDate)) or (EndDate = NormalDate(EndDate)) then
                if (BusUnit."Starting Date" <> 0D) or (BusUnit."Ending Date" <> 0D) then begin
                    CheckBusUnitsDatesToFiscalYear(BusUnit);
                    ConsolPeriodInclInFiscalYears :=
                      ConsolPeriodInclInFiscalYears and CheckDatesToBusUnitDates(StartDate, EndDate, BusUnit);
                end;
        until BusUnit.Next() = 0;

        if not ConsolPeriodInclInFiscalYears then
            if not ConfirmManagement.GetResponseOrDefault(
                 StrSubstNo(ConsPeriodSubsidiaryQst, StartDate, EndDate), true)
            then
                CurrReport.Break();

        CheckDatesToFiscalYear(StartDate, EndDate);
    end;

    local procedure CheckDatesToFiscalYear(StartDate: Date; EndDate: Date)
    var
        AccountingPeriod: Record "Accounting Period";
        ConfirmManagement: Codeunit "Confirm Management";
        FiscalYearStartDate: Date;
        FiscalYearEndDate: Date;
        ConsolPeriodInclInFiscalYear: Boolean;
    begin
        ConsolPeriodInclInFiscalYear := true;

        AccountingPeriod.Reset();
        AccountingPeriod.SetRange(Closed, false);
        AccountingPeriod.SetRange("New Fiscal Year", true);
        if AccountingPeriod.Find('-') then begin
            FiscalYearStartDate := AccountingPeriod."Starting Date";
            // FYStartDate := AccountingPeriod."Starting Date";
            if AccountingPeriod.Find('>') then
                FiscalYearEndDate := CalcDate('<-1D>', AccountingPeriod."Starting Date")
            else
                Error(Text028);

            ConsolPeriodInclInFiscalYear := (StartDate >= FiscalYearStartDate) and (EndDate <= FiscalYearEndDate);

            if not ConsolPeriodInclInFiscalYear then
                if not ConfirmManagement.GetResponseOrDefault(
                     StrSubstNo(
                       ConsPeriodCompanyQst, StartDate, EndDate, FiscalYearStartDate,
                       FiscalYearEndDate, CompanyName), true)
                then
                    CurrReport.Break();
        end;
    end;

    local procedure CheckDatesToBusUnitDates(StartDate: Date; EndDate: Date; BusUnit: Record "Business Unit"): Boolean
    var
        ConsolPeriodInclInFiscalYear: Boolean;
    begin
        ConsolPeriodInclInFiscalYear := (StartDate >= BusUnit."Starting Date") and (EndDate <= BusUnit."Ending Date");
        exit(ConsolPeriodInclInFiscalYear);
    end;

    local procedure CheckClosingDates(StartDate: Date; EndDate: Date)
    begin
        if (StartDate = ClosingDate(StartDate)) or
           (EndDate = ClosingDate(EndDate))
        then begin
            if StartDate <> EndDate then
                Error(Text030);
        end;
    end;

    local procedure CheckBusUnitsDatesToFiscalYear(var BusUnit: Record "Business Unit")
    begin
        if (BusUnit."Starting Date" <> 0D) or (BusUnit."Ending Date" <> 0D) then begin
            BusUnit.TestField("Starting Date");
            BusUnit.TestField("Ending Date");
            if BusUnit."Starting Date" > BusUnit."Ending Date" then
                Error(
                  Text032, BusUnit.FieldCaption("Starting Date"),
                  BusUnit.FieldCaption("Ending Date"), BusUnit."Company Name");
        end;
    end;
}