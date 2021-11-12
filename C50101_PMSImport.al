codeunit 50101 PMSImport
{
    trigger OnRun()
    begin

    end;

    procedure ConvertPMS(pFilename: Text)
    var
        PMSImportTable: Record PMSImportTable;
        GnlJnlLine: Record "Gen. Journal Line";
        LineNo: Integer;
        GLSetup: Record "General Ledger Setup";
        GLEntry: Record "G/L Entry";
        ReversalEntry: Record "Reversal Entry";
        PMSImportSetup: Record "PMS Import Setup";
        DimSetEntryTemp: Record "Dimension Set Entry" temporary;
        Currency: Record Currency;
    begin
        GLSetup.Get();
        GnlJnlLine.Reset();
        GnlJnlLine.SetRange("Journal Template Name", GLSetup."PMS Import Gen. Jnl. Template");
        GnlJnlLine.SetRange("Journal Batch Name", GLSetup."PMS Import Gen. Jnl. Batch");
        if GnlJnlLine.FindLast() then
            LineNo := GnlJnlLine."Line No." + 10000
        else
            LineNo := 10000;

        PMSImportTable.Reset();
        PMSImportTable.SetRange(Status, PMSImportTable.Status::Open);
        PMSImportTable.SetRange("File Name", pFilename);
        if PMSImportTable.FindSet() then
            repeat
                GLEntry.Reset();
                GLEntry.SetRange("Document No.", PMSImportTable."GL Entry Id");
                if GLEntry.FindFirst() then begin
                    if not ToReverseTransaction(GLEntry."Transaction No.") then
                        Log(PMSImportTable, 'Reverse Entry Error; ' + GetLastErrorText());
                end;

                PMSImportSetup.Reset();
                PMSImportSetup.SetRange("PMS Account No.", PMSImportTable."Account Number");
                PMSImportSetup.SetRange("Instrument Type", PMSImportTable.Description);
                if not PMSImportSetup.FindFirst() then
                    Log(PMSImportTable, 'Cannot find PMS Import Setup: ' + PMSImportTable."Account Number" + ' ' + PMSImportTable.Description);

                Currency.Reset();
                Currency.SetRange(code, PMSImportTable.Currency);
                if not Currency.FindFirst() then
                    Log(PMSImportTable, 'Cannot find Currency Code: ' + PMSImportTable.Currency);

                GnlJnlLine.Init();
                GnlJnlLine."Journal Template Name" := GLSetup."PMS Import Gen. Jnl. Template";
                GnlJnlLine."Journal Batch Name" := GLSetup."PMS Import Gen. Jnl. Batch";
                GnlJnlLine."Line No." := LineNo;
                GnlJnlLine.Validate("Posting Date", PMSImportTable."Transaction Date");
                GnlJnlLine.Validate("Document No.", PMSImportTable."GL Entry Id");
                GnlJnlLine.Validate("Account Type", GnlJnlLine."Account Type"::"G/L Account");
                GnlJnlLine.Validate("Account No.", PMSImportSetup."G/L Account No.");
                GnlJnlLine.Validate("External Document No.", PMSImportTable."GL Entry Id");
                GnlJnlLine.Insert();
                GnlJnlLine.Validate(Description, PMSImportTable.Description);

                Clear(DimSetEntryTemp);
                InsertDim(DimSetEntryTemp, 'ISIN / STOCK NO.', PMSImportTable.ISIN, PMSImportTable);
                InsertDim(DimSetEntryTemp, 'BANK / CUSTODIAN', PMSImportTable.Custodian, PMSImportTable);
                InsertDim(DimSetEntryTemp, 'FINANCIAL INSTRUMENT', PMSImportTable."Custodian Account Display Name", PMSImportTable);

                GnlJnlLine.Validate("Dimension Set ID", DimSetEntryTemp.GetDimensionSetID(DimSetEntryTemp));
                GnlJnlLine.Validate("Currency Code", PMSImportTable.Currency);

                if (PMSImportTable."Native Amount" = 0) then begin
                    GnlJnlLine.Validate("System-Created Entry", true);
                    GnlJnlLine.Validate("Allow Zero-Amount Posting", true);
                    GnlJnlLine.Amount := PMSImportTable."Native Amount";
                    GnlJnlLine."Amount (LCY)" := PMSImportTable."Base Amount"
                end
                else begin
                    GnlJnlLine.Validate(Amount, PMSImportTable."Native Amount");
                    GnlJnlLine.Validate("Amount (LCY)", PMSImportTable."Base Amount");
                end;
                GnlJnlLine.Modify();

                LineNo := LineNo + 10000;
                PMSImportTable.Status := PMSImportTable.Status::Closed;
                PMSImportTable.Modify();
            until PMSImportTable.Next() = 0;
    end;

    local procedure InsertDim(var pDimSetEntryTemp: Record "Dimension Set Entry" temporary; DimCode: Code[20]; DimValue: Code[20]; pPMSImportTable: record PMSImportTable)
    var
        DimValueRec: Record "Dimension Value";
    begin
        if DimValue = '' then
            exit;
        DimValueRec.Reset();
        DimValueRec.SetRange("Dimension Code", DimCode);
        DimValueRec.SetRange(Code, DimValue);
        if not DimValueRec.FindFirst() then begin
            Log(pPMSImportTable, 'Dimension Value ' + DimValue + ' cannot be found.');
            exit;
        end;
        pDimSetEntryTemp.Init();
        pDimSetEntryTemp.Validate("Dimension Code", DimCode);
        pDimSetEntryTemp.Validate("Dimension Value Code", DimValue);
        pDimSetEntryTemp.Insert();
    end;

    [TryFunction]
    local procedure ToReverseTransaction(transactionno: Integer)
    var
        ReversalEntry: Record "Reversal Entry";
    begin
        ReversalEntry.ReverseTransaction(transactionno);
    end;

    local procedure Log(pPMSImportTable: Record PMSImportTable; ErrorMessage: Text)
    var
        logentry: Record "PMS Import Log";
        EntryNo: Integer;
    begin
        logentry.Reset();
        if logentry.FindLast() then
            EntryNo := logentry."Entry No." + 1
        else
            EntryNo := 1;
        logentry.Init();
        logentry."Entry No." := EntryNo;
        logentry."User ID" := UserId;
        logentry."Start Date Time" := CurrentDateTime;
        logentry."End Date Time" := CurrentDateTime;
        logentry.Job := 'PMS Import';
        logentry.Status := logentry.Status::Error;
        logentry.Description := 'Error at Line';
        logentry."Line No." := pPMSImportTable."Row No.";
        logentry."File Name" := pPMSImportTable."File Name";
        logentry."Error Message" := copystr(ErrorMessage, 1, 250);
        if (strlen(ErrorMessage) > 250) then
            logentry."Error Message 2" := copystr(ErrorMessage, 251, 500);
        if (strlen(ErrorMessage) > 500) then
            logentry."Error Message 3" := copystr(ErrorMessage, 501, 750);
        if (strlen(ErrorMessage) > 750) then
            logentry."Error Message 4" := copystr(ErrorMessage, 751, 1000);
        logentry.Insert();
    end;
}