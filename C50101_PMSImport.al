codeunit 50101 PMSImport
{
    trigger OnRun()
    begin

    end;

    procedure ConvertPMS()
    var
        PMSImportTable: Record PMSImportTable;
        GnlJnlLine: Record "Gen. Journal Line";
        LineNo: Integer;
        GLSetup: Record "General Ledger Setup";
        GLEntry: Record "G/L Entry";
        ReversalEntry: Record "Reversal Entry";
        PMSImportSetup: Record "PMS Import Setup";
    begin
        GnlJnlLine.Reset();
        GnlJnlLine.SetRange("Journal Template Name", GLSetup."PMS Import General Journal Template");
        GnlJnlLine.SetRange("Journal Batch Name", GLSetup."PMS Import General Journal Batch");
        if GnlJnlLine.FindLast() then
            LineNo := GnlJnlLine."Line No." + 1
        else
            LineNo := 10000;

        GLSetup.Get();
        PMSImportTable.Reset();
        PMSImportTable.SetRange(Status, PMSImportTable.Status::Open);
        if PMSImportTable.FindSet() then
            repeat
                GLEntry.Reset();
                GLEntry.SetRange("Document No.", PMSImportTable."GL Entry Id");
                if GLEntry.FindFirst() then begin
                    if not ToReverseTransaction(GLEntry."Transaction No.") then
                        Log(PMSImportTable, 'Reverse Entry Error; ' + GetLastErrorText());

                    PMSImportSetup.Reset();
                    PMSImportSetup.SetRange("PMS Account No.", PMSImportTable."Account Number");
                    PMSImportSetup.SetRange("Instrument Type", PMSImportTable.Description);
                    if not PMSImportSetup.FindFirst() then
                        Log(PMSImportTable, 'Cannot find PMS Import Setup: ' + PMSImportTable."Account Number" + ' ' + PMSImportTable.Description);

                    GnlJnlLine.Init();
                    GnlJnlLine."Journal Template Name" := GLSetup."PMS Import General Journal Template";
                    GnlJnlLine."Journal Batch Name" := GLSetup."PMS Import General Journal Batch";
                    GnlJnlLine."Line No." := LineNo;
                    GnlJnlLine.Validate("Posting Date", PMSImportTable."Transaction Date");
                    GnlJnlLine.Validate("Account Type", GnlJnlLine."Account Type"::"G/L Account");
                    GnlJnlLine.Validate("Account No.", PMSImportSetup."G/L Account No.");
                    GnlJnlLine.Validate("External Document No.", PMSImportTable."GL Entry Id");
                    GnlJnlLine.Insert();
                    GnlJnlLine.Validate(Description, PMSImportTable.Description);

                end;
            until PMSImportTable.Next() = 0;
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
        logentry."Line No." := pPMSImportTable."Entry No.";
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