codeunit 50131 "Config. Company Exchange"
{
    Permissions = tabledata "service zone" = i;


    trigger OnRun()
    begin
    end;

    var
        SelectedConfigPackage: Record "Config. Package";
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageField: Record "Config. Package Field";
        ConfigPackageRecord: Record "Config. Package Record";
        ConfigPackageData: Record "Config. Package Data";
        ConfigPackageFilter: Record "Config. Package Filter";
        SelectedTable: Record "integer" temporary;
        TempConfigRecordForProcessing: Record "Config. Record For Processing" temporary;
        TempAppliedConfigPackageRecord: Record "Config. Package Record" temporary;
        TempConfigPackageFieldCache: Record "Config. Package Field" temporary;
        ConfigPackageMgt: Codeunit "Config. Package Management";
        ConfigProgressBar: Codeunit "Config. Progress Bar";
        ConfigValidateMgt: Codeunit "Config. Validate Management";
        ConfigMgt: Codeunit "Config. Management";
        TypeHelper: Codeunit "Type Helper";
        ApplyMode: Option ,PrimaryKey,NonKeyFields;
        ErrorTypeEnum: Option General,TableRelation;
        HideDialog: Boolean;
        ImportPackageTxt: Label 'Importing package';
        TableDoesNotExistErr: Label 'An error occurred while importing the %1 table. The table does not exist in the database.';
        TableContainsRecordsQst: Label 'Table %1 in the package %2 contains %3 records that will be overwritten by the import. Do you want to continue?', Comment = '%1=The ID of the table being imported. %2=The Config Package Code. %3=The number of records in the config package.';
        RecordProgressTxt: Label 'Import %1 records', Comment = '%1=The name of the table being imported.';
        ProcessingOrderErr: Label 'Cannot set up processing order numbers. A cycle reference exists in the primary keys for table %1.', Comment = '%1 = The name of the table.';
        ApplyingPackageMsg: Label 'Applying package %1', Comment = '%1 = The name of the package being applied.';
        ApplyingTableMsg: Label 'Applying table %1', Comment = '%1 = The name of the table being applied.';
        RecordsXofYMsg: Label 'Records: %1 of %2', Comment = 'Sample: 5 of 1025. 1025 is total number of records, 5 is a number of the current record ';
        ValidationFieldID: Integer;
        KeyFieldValueMissingErr: Label 'The value of the key field %1 has not been filled in for record %2 : %3.', Comment = 'Parameter 1 - field name, 2 - table name, 3 - code value. Example: The value of the key field Customer Posting Group has not been filled in for record Customer : XXXXX.';
        MSGPPackageCodeTxt: Label 'GB.ENU.CSV';
        BlankTxt: Label '[Blank]';
        UpdatingDimSetsMsg: Label 'Updating dimension sets';
        DimValueDoesNotExistsErr: Label 'Dimension Value %1 %2 does not exist.', Comment = '%1 = Dimension Code, %2 = Dimension Value Code';
        QBPackageCodeTxt: Label 'DM.IIF';
        RecordsInsertedCount: Integer;
        RecordsModifiedCount: Integer;
        NoTablesAndErrorsMsg: Label '%1 tables are processed.\%2 errors found.\%3 records inserted.\%4 records modified.', Comment = '%1 = number of tables processed, %2 = number of errors, %3 = number of records inserted, %4 = number of records modified';


    procedure SetSelectedTables(var ConfigPackageTable: Record "Config. Package Table")
    begin
        IF ConfigPackageTable.FINDSET THEN
            REPEAT
                SelectedTable.Number := ConfigPackageTable."Table ID";
                IF SelectedTable.INSERT THEN;
            UNTIL ConfigPackageTable.NEXT = 0;
    end;

    local procedure GetPrimaryKeyFieldNumber(TableID: Integer): Integer
    var
        RecRef: RecordRef;
        KeyRef: KeyRef;
        FieldRef: FieldRef;
    begin
        RecRef.OPEN(TableID);
        KeyRef := RecRef.KEYINDEX(1);
        FieldRef := KeyRef.FIELDINDEX(1);
        EXIT(FieldRef.NUMBER);
    end;

    [Scope('Personalization')]
    procedure fn_ExportRecordsFromCompany(PackageCode: Code[20]): Boolean
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        l_booImported: Boolean;
        l_intTotalRecord: Integer;
        l_intTotalField: Integer;
        l_intTableID: Integer;
    begin
        CLEAR(l_intTotalRecord);
        CLEAR(l_intTableID);
        CLEAR(l_booImported);
        SelectedConfigPackage.GET(PackageCode);
        //SelectedConfigPackage.TESTFIELD("Copy to Company");

        //Count total records of all selected tables in current company;
        ConfigPackageTable.RESET;
        ConfigPackageTable.SETRANGE("Package Code", PackageCode);
        l_intTotalRecord := ConfigPackageTable.COUNT;

        IF NOT HideDialog THEN
            ConfigProgressBar.Init(l_intTotalRecord, 1, ImportPackageTxt);

        //Import data from each table
        IF ConfigPackageTable.FINDSET THEN
            REPEAT
                l_intTableID := ConfigPackageTable."Table ID";
                RecordRef.OPEN(ConfigPackageTable."Table ID");
                fn_ExportDataFromCompany(PackageCode, l_intTableID, RecordRef);
                RecordRef.CLOSE;

                CASE TRUE OF // Dimensions
                    ConfigMgt.IsDefaultDimTable(l_intTableID):
                        BEGIN
                            ConfigPackageRecord.SETRANGE("Package Code", PackageCode);
                            ConfigPackageRecord.SETRANGE("Table ID", l_intTableID);
                            IF ConfigPackageRecord.FINDSET THEN
                                REPEAT
                                    ConfigPackageData.GET(
                                      ConfigPackageRecord."Package Code", ConfigPackageRecord."Table ID",
                                      ConfigPackageRecord."No.", GetPrimaryKeyFieldNumber(l_intTableID));
                                    ConfigPackageMgt.UpdateDefaultDimValues(ConfigPackageRecord, COPYSTR(ConfigPackageData.Value, 1, 20));
                                UNTIL ConfigPackageRecord.NEXT = 0;
                        END;
                    ConfigMgt.IsDimSetIDTable(l_intTableID):
                        BEGIN
                            ConfigPackageRecord.SETRANGE("Package Code", PackageCode);
                            ConfigPackageRecord.SETRANGE("Table ID", l_intTableID);
                            IF ConfigPackageRecord.FINDSET THEN
                                REPEAT
                                    ConfigPackageMgt.HandlePackageDataDimSetIDForRecord(ConfigPackageRecord);
                                UNTIL ConfigPackageRecord.NEXT = 0;
                        END;
                END;

            UNTIL ConfigPackageTable.NEXT = 0;

        IF NOT HideDialog THEN
            ConfigProgressBar.Close;

        ConfigPackageMgt.UpdateConfigLinePackageData(SelectedConfigPackage.Code);

        // autoapply configuration lines
        ConfigPackageMgt.ApplyConfigTables(SelectedConfigPackage);

        l_booImported := TRUE;

        EXIT(l_booImported);
    end;

    [Scope('Personalization')]
    procedure fn_ExportRecordsFromCompanyPerTable(PackageCode: Code[20]; var ConfigPackageTable: Record "Config. Package Table"): Boolean
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        l_booImported: Boolean;
        l_intTotalRecord: Integer;
        l_intTotalField: Integer;
        l_intTableID: Integer;
    begin
        CLEAR(l_intTotalRecord);
        CLEAR(l_intTableID);
        CLEAR(l_booImported);
        SelectedConfigPackage.GET(PackageCode);
        //SelectedConfigPackage.TESTFIELD("Copy to Company");

        //Count total records of all selected tables in current company;
        l_intTotalRecord := ConfigPackageTable.COUNT;

        IF NOT HideDialog THEN
            ConfigProgressBar.Init(l_intTotalRecord, 1, ImportPackageTxt);

        //Import data from each table
        IF ConfigPackageTable.FINDSET THEN
            REPEAT
                l_intTableID := ConfigPackageTable."Table ID";
                RecordRef.OPEN(ConfigPackageTable."Table ID");
                fn_ExportDataFromCompany(PackageCode, l_intTableID, RecordRef);
                RecordRef.CLOSE;

                CASE TRUE OF // Dimensions
                    ConfigMgt.IsDefaultDimTable(l_intTableID):
                        BEGIN
                            ConfigPackageRecord.SETRANGE("Package Code", PackageCode);
                            ConfigPackageRecord.SETRANGE("Table ID", l_intTableID);
                            IF ConfigPackageRecord.FINDSET THEN
                                REPEAT
                                    ConfigPackageData.GET(
                                      ConfigPackageRecord."Package Code", ConfigPackageRecord."Table ID",
                                      ConfigPackageRecord."No.", GetPrimaryKeyFieldNumber(l_intTableID));
                                    ConfigPackageMgt.UpdateDefaultDimValues(ConfigPackageRecord, COPYSTR(ConfigPackageData.Value, 1, 20));
                                UNTIL ConfigPackageRecord.NEXT = 0;
                        END;
                    ConfigMgt.IsDimSetIDTable(l_intTableID):
                        BEGIN
                            ConfigPackageRecord.SETRANGE("Package Code", PackageCode);
                            ConfigPackageRecord.SETRANGE("Table ID", l_intTableID);
                            IF ConfigPackageRecord.FINDSET THEN
                                REPEAT
                                    ConfigPackageMgt.HandlePackageDataDimSetIDForRecord(ConfigPackageRecord);
                                UNTIL ConfigPackageRecord.NEXT = 0;
                        END;
                END;

            UNTIL ConfigPackageTable.NEXT = 0;

        IF NOT HideDialog THEN
            ConfigProgressBar.Close;

        ConfigPackageMgt.UpdateConfigLinePackageData(SelectedConfigPackage.Code);

        // autoapply configuration lines
        ConfigPackageMgt.ApplyConfigTables(SelectedConfigPackage);

        l_booImported := TRUE;

        EXIT(l_booImported);
    end;

    procedure fn_ExportDataFromCompany(PackageCode: Code[20]; TableID: Integer; RecordRef: RecordRef)
    var
        ConfigXMLExchange: Codeunit "Config. XML Exchange";
    begin
        FillPackageMetadataFromTable(PackageCode, TableID, RecordRef);
        IF NOT ConfigXMLExchange.TableObjectExists(TableID) THEN BEGIN
            ConfigPackageMgt.InsertPackageTableWithoutValidation(ConfigPackageTable, PackageCode, TableID);
            ConfigPackageMgt.InitPackageRecord(ConfigPackageRecord, PackageCode, TableID);
            ConfigPackageMgt.RecordError(ConfigPackageRecord, 0, COPYSTR(STRSUBSTNO(TableDoesNotExistErr, TableID), 1, 250));
        END ELSE
            FillPackageDataFromTable(PackageCode, TableID, RecordRef);
    end;

    [Scope('Personalization')]
    procedure fn_ApplyCompanyPackage(ConfigPackage: Record "Config. Package"; var ConfigPackageTable: Record "Config. Package Table"; SetupProcessingOrderForTables: Boolean) ErrorCount: Integer
    var
        DimSetEntry: Record "Dimension Set Entry";
        ConfigPackageTableParent: Record "Config. Package Table";
        IntegrationService: Codeunit "Integration Service";
        IntegrationManagement: Codeunit "Integration Management";
        TableCount: Integer;
        DimSetIDUsed: Boolean;
        RecordRef: RecordRef;
    begin
        ConfigPackage.TESTFIELD("Copy to Company");
        BINDSUBSCRIPTION(IntegrationService);
        IntegrationManagement.ResetIntegrationActivated;

        ConfigPackage.CALCFIELDS("No. of Records", "No. of Errors");
        TableCount := ConfigPackageTable.COUNT;
        IF (ConfigPackage.Code <> MSGPPackageCodeTxt) AND (ConfigPackage.Code <> QBPackageCodeTxt) THEN
            // Hold the error count for duplicate records.
            ErrorCount := ConfigPackage."No. of Errors";
        IF (TableCount = 0) OR (ConfigPackage."No. of Records" = 0) THEN
            EXIT;
        IF (ConfigPackage.Code <> MSGPPackageCodeTxt) AND (ConfigPackage.Code <> QBPackageCodeTxt) THEN
            // Skip this code to hold the error count for duplicate records.
            CleanPackageErrors(ConfigPackage.Code, ConfigPackageTable.GETFILTER("Table ID"));

        IF SetupProcessingOrderForTables THEN BEGIN
            SetupProcessingOrder(ConfigPackageTable);
            COMMIT;
        END;

        DimSetIDUsed := FALSE;
        IF ConfigPackageTable.FINDSET THEN
            REPEAT
                RecordRef.OPEN(ConfigPackageTable."Table ID");
                RecordRef.CHANGECOMPANY(ConfigPackage."Copy to Company");
                DimSetIDUsed := RecordRef.FIELDEXIST(DATABASE::"Dimension Set Entry");
                RecordRef.CLOSE;
            UNTIL (ConfigPackageTable.NEXT = 0) OR DimSetIDUsed;

        IF DimSetIDUsed AND NOT DimSetEntry.ISEMPTY THEN
            UpdateDimSetIDValues(ConfigPackage);
        IF (ConfigPackage.Code <> MSGPPackageCodeTxt) AND (ConfigPackage.Code <> QBPackageCodeTxt) THEN
            DeleteAppliedPackageRecords(TempAppliedConfigPackageRecord, ConfigPackage."Copy to Company"); // Do not delete PackageRecords till transactions are created

        COMMIT;

        TempAppliedConfigPackageRecord.DELETEALL;
        TempConfigRecordForProcessing.DELETEALL;
        CLEAR(RecordsInsertedCount);
        CLEAR(RecordsModifiedCount);

        // Handle independent tables
        ConfigPackageTable.SETRANGE("Parent Table ID", 0);
        ApplyPackageTables(ConfigPackage, ConfigPackageTable, ApplyMode::PrimaryKey, ConfigPackage."Copy to Company");
        ApplyMode := ApplyMode::NonKeyFields;
        ApplyPackageTables(ConfigPackage, ConfigPackageTable, ApplyMode::NonKeyFields, ConfigPackage."Copy to Company");

        // Handle children tables
        ConfigPackageTable.SETFILTER("Parent Table ID", '>0');
        IF ConfigPackageTable.FINDSET THEN
            REPEAT
                ConfigPackageTableParent.GET(ConfigPackage.Code, ConfigPackageTable."Parent Table ID");
                IF ConfigPackageTableParent."Parent Table ID" = 0 THEN
                    ConfigPackageTable.MARK(TRUE);
            UNTIL ConfigPackageTable.NEXT = 0;
        ConfigPackageTable.MARKEDONLY(TRUE);
        ApplyPackageTables(ConfigPackage, ConfigPackageTable, ApplyMode::PrimaryKey, ConfigPackage."Copy to Company");
        ApplyPackageTables(ConfigPackage, ConfigPackageTable, ApplyMode::NonKeyFields, ConfigPackage."Copy to Company");

        // Handle grandchildren tables
        ConfigPackageTable.CLEARMARKS;
        ConfigPackageTable.MARKEDONLY(FALSE);
        IF ConfigPackageTable.FINDSET THEN
            REPEAT
                ConfigPackageTableParent.GET(ConfigPackage.Code, ConfigPackageTable."Parent Table ID");
                IF ConfigPackageTableParent."Parent Table ID" > 0 THEN
                    ConfigPackageTable.MARK(TRUE);
            UNTIL ConfigPackageTable.NEXT = 0;
        ConfigPackageTable.MARKEDONLY(TRUE);
        ApplyPackageTables(ConfigPackage, ConfigPackageTable, ApplyMode::PrimaryKey, ConfigPackage."Copy to Company");
        ApplyPackageTables(ConfigPackage, ConfigPackageTable, ApplyMode::NonKeyFields, ConfigPackage."Copy to Company");

        ProcessAppliedPackageRecords(TempConfigRecordForProcessing, TempAppliedConfigPackageRecord, ConfigPackage."Copy to Company");
        IF (ConfigPackage.Code <> MSGPPackageCodeTxt) AND (ConfigPackage.Code <> QBPackageCodeTxt) THEN
            DeleteAppliedPackageRecords(TempAppliedConfigPackageRecord, ConfigPackage."Copy to Company"); // Do not delete PackageRecords till transactions are created

        ConfigPackage.CALCFIELDS("No. of Errors");
        ErrorCount := ConfigPackage."No. of Errors" - ErrorCount;
        IF ErrorCount < 0 THEN
            ErrorCount := 0;

        RecordsModifiedCount := MaxInt(RecordsModifiedCount - RecordsInsertedCount, 0);

        IF NOT HideDialog THEN
            MESSAGE(NoTablesAndErrorsMsg, TableCount, ErrorCount, RecordsInsertedCount, RecordsModifiedCount);
    end;

    [Scope('Personalization')]
    procedure ApplySelectedPackageRecords(var ConfigPackageRecord: Record "Config. Package Record"; PackageCode: Code[20]; TableNo: Integer; CopyToCompany: Text[30])
    begin
        //Copy record data to company
        CLEAR(RecordsInsertedCount);
        CLEAR(RecordsModifiedCount);
        TempAppliedConfigPackageRecord.DELETEALL;
        TempConfigRecordForProcessing.DELETEALL;

        ApplyPackageRecords(ConfigPackageRecord, PackageCode, TableNo, ApplyMode::PrimaryKey, CopyToCompany);
        ApplyPackageRecords(ConfigPackageRecord, PackageCode, TableNo, ApplyMode::NonKeyFields, CopyToCompany);

        ProcessAppliedPackageRecords(TempConfigRecordForProcessing, TempAppliedConfigPackageRecord, CopyToCompany);
        DeleteAppliedPackageRecords(TempAppliedConfigPackageRecord, CopyToCompany);
    end;

    local procedure ApplyPackageTables(ConfigPackage: Record "Config. Package"; var ConfigPackageTable: Record "Config. Package Table"; ApplyMode: Option ,PrimaryKey,NonKeyFields; CopyToCompany: Text[30])
    var
        ConfigPackageRecord: Record "Config. Package Record";
    begin
        ConfigPackageTable.SETCURRENTKEY("Package Processing Order", "Processing Order");

        IF NOT HideDialog THEN
            ConfigProgressBar.Init(ConfigPackageTable.COUNT, 1,
              STRSUBSTNO(ApplyingPackageMsg, ConfigPackage.Code));
        IF ConfigPackageTable.FINDSET THEN
            REPEAT
                ConfigPackageTable.CALCFIELDS("Table Name");
                ConfigPackageRecord.SETRANGE("Package Code", ConfigPackageTable."Package Code");
                ConfigPackageRecord.SETRANGE("Table ID", ConfigPackageTable."Table ID");
                IF NOT HideDialog THEN
                    ConfigProgressBar.Update(ConfigPackageTable."Table Name");
                IF NOT IsTableErrorsExists(ConfigPackageTable) THEN// Added to show item duplicate errors
                    ApplyPackageRecords(
                      ConfigPackageRecord, ConfigPackageTable."Package Code", ConfigPackageTable."Table ID", ApplyMode, CopyToCompany);
            UNTIL ConfigPackageTable.NEXT = 0;

        IF NOT HideDialog THEN
            ConfigProgressBar.Close;
    end;

    local procedure ApplyPackageRecords(var ConfigPackageRecord: Record "Config. Package Record"; PackageCode: Code[20]; TableNo: Integer; ApplyMode: Option ,PrimaryKey,NonKeyFields; CopyToCompany: Text[30])
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigTableProcessingRule: Record "Config. Table Processing Rule";
        ConfigPackageMgt: Codeunit "Config. Package Management";
        ConfigProgressBarRecord: Codeunit "Config. Progress Bar";
        RecRef: RecordRef;
        RecordCount: Integer;
        StepCount: Integer;
        Counter: Integer;
        ProcessingRuleIsSet: Boolean;
    begin
        ConfigPackageTable.GET(PackageCode, TableNo);
        ProcessingRuleIsSet := ConfigTableProcessingRule.FindTableRules(ConfigPackageTable);

        ConfigPackageMgt.SetApplyMode(ApplyMode);
        RecordCount := ConfigPackageRecord.COUNT;
        IF NOT HideDialog AND (RecordCount > 1000) THEN BEGIN
            StepCount := ROUND(RecordCount / 100, 1);
            ConfigPackageTable.CALCFIELDS("Table Name");
            ConfigProgressBarRecord.Init(
              RecordCount, StepCount, STRSUBSTNO(ApplyingTableMsg, ConfigPackageTable."Table Name"));
        END;

        Counter := 0;
        IF ConfigPackageRecord.FINDSET THEN BEGIN
            RecRef.OPEN(ConfigPackageRecord."Table ID");
            RecRef.CHANGECOMPANY(CopyToCompany);
            IF ConfigPackageTable."Delete Recs Before Processing" THEN BEGIN
                RecRef.DELETEALL;
                COMMIT;
            END;
            REPEAT
                Counter := Counter + 1;
                IF (ApplyMode = ApplyMode::PrimaryKey) OR NOT IsRecordErrorsExistsInPrimaryKeyFields(ConfigPackageRecord) THEN BEGIN
                    InsertPackageRecord(ConfigPackageRecord, CopyToCompany);
                    IF NOT ((ApplyMode = ApplyMode::PrimaryKey) OR IsRecordErrorsExists(ConfigPackageRecord)) THEN BEGIN
                        CollectAppliedPackageRecord(ConfigPackageRecord, TempAppliedConfigPackageRecord);
                        IF ProcessingRuleIsSet THEN
                            CollectRecordForProcessingAction(ConfigPackageRecord, ConfigTableProcessingRule);
                    END;
                END;
                IF NOT HideDialog AND (RecordCount > 1000) THEN
                    ConfigProgressBarRecord.Update(STRSUBSTNO(RecordsXofYMsg, Counter, RecordCount));
            UNTIL ConfigPackageRecord.NEXT = 0;
        END;

        IF NOT HideDialog AND (RecordCount > 1000) THEN
            ConfigProgressBarRecord.Close;
    end;

    local procedure ProcessAppliedPackageRecords(var TempConfigRecordForProcessing: Record "Config. Record For Processing" temporary; var TempConfigPackageRecord: Record "Config. Package Record" temporary; CopyToCompany: Text[30])
    var
        ConfigTableProcessingRule: Record "Config. Table Processing Rule";
        Subscriber: Variant;
    begin
        OnPreProcessPackage(TempConfigRecordForProcessing, Subscriber);
        IF TempConfigRecordForProcessing.FINDSET THEN
            REPEAT
                IF NOT ConfigTableProcessingRule.Process(TempConfigRecordForProcessing) THEN BEGIN
                    TempConfigRecordForProcessing.FindConfigRecord(TempConfigPackageRecord);
                    TempConfigPackageRecord.DELETE; // Remove it from the buffer to avoid deletion in the package
                    COMMIT;
                END;
            UNTIL TempConfigRecordForProcessing.NEXT = 0;
        TempConfigRecordForProcessing.DELETEALL;
        OnPostProcessPackage;
    end;

    local procedure DeleteAppliedPackageRecords(var TempConfigPackageRecord: Record "Config. Package Record" temporary; CopyToCompany: Text[30])
    var
        ConfigPackageRecord: Record "Config. Package Record";
    begin
        IF TempConfigPackageRecord.FINDSET THEN
            REPEAT
                ConfigPackageRecord.TRANSFERFIELDS(TempConfigPackageRecord);
                ConfigPackageRecord.DELETE(TRUE);
            UNTIL TempConfigPackageRecord.NEXT = 0;
        TempConfigPackageRecord.DELETEALL;
        COMMIT;
    end;

    local procedure FillPackageMetadataFromTable(var PackageCode: Code[20]; TableID: Integer; RecordRef: RecordRef)
    var
        ConfigPackage: Record "Config. Package";
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageField: Record "Config. Package Field";
        "Field": Record "Field";
        ConfigMgt: Codeunit "Config. Progress Bar";
        Value: Text;
        IsTableInserted: Boolean;
    begin
        IF (TableID > 0) AND (NOT ConfigPackageTable.GET(PackageCode, TableID)) THEN BEGIN
            ConfigPackageTable."Package Code" := COPYSTR(PackageCode, 1, MAXSTRLEN(ConfigPackageTable."Package Code"));
            ConfigPackageTable."Table ID" := TableID;
            IF NOT ConfigPackageTable.FIND THEN BEGIN
                IF NOT ConfigPackage.GET(ConfigPackageTable."Package Code") THEN BEGIN
                    ConfigPackage.INIT;
                    ConfigPackage.VALIDATE(Code, ConfigPackageTable."Package Code");
                    ConfigPackage.INSERT(TRUE);
                END;
                ConfigPackageTable.INIT;
                ConfigPackageTable.INSERT(TRUE);
                IsTableInserted := TRUE;
            END;
            PackageCode := ConfigPackageTable."Package Code";
        END;
    end;

    local procedure FillPackageDataFromTable(PackageCode: Code[20]; TableID: Integer; RecordRef: RecordRef)
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageData: Record "Config. Package Data";
        ConfigPackageRecord: Record "Config. Package Record";
        ConfigPackageField: Record "Config. Package Field";
        TempConfigPackageField: Record "Config. Package Field" temporary;
        ConfigProgressBarRecord: Codeunit "Config. Progress Bar";
        FieldRef: FieldRef;
        NodeCount: Integer;
        RecordCount: Integer;
        StepCount: Integer;
        ErrorText: Text[250];
    begin
        IF ConfigMgt.IsSystemTable(TableID) THEN
            EXIT;
        IF ConfigPackageTable.GET(PackageCode, TableID) THEN BEGIN
            ExcludeRemovedFields(ConfigPackageTable);
            ConfigPackageTable.CALCFIELDS("No. of Package Records");
            IF ConfigPackageTable."No. of Package Records" > 0 THEN
                IF CONFIRM(TableContainsRecordsQst, TRUE, TableID, PackageCode, ConfigPackageTable."No. of Package Records") THEN
                    ConfigPackageTable.DeletePackageData
                ELSE
                    EXIT;
            ConfigPackageTable.CALCFIELDS("Table Name");
            IF NOT HideDialog THEN
                ConfigProgressBar.Update(ConfigPackageTable."Table Name");
            RecordCount := RecordRef.COUNT;

            IF NOT HideDialog AND (RecordCount > 1000) THEN BEGIN
                StepCount := ROUND(RecordCount / 100, 1);
                ConfigProgressBarRecord.Init(RecordCount, StepCount,
                  STRSUBSTNO(RecordProgressTxt, ConfigPackageTable."Table Name"));
            END;

            ConfigPackageField.SETRANGE("Package Code", ConfigPackageTable."Package Code");
            ConfigPackageField.SETRANGE("Table ID", ConfigPackageTable."Table ID");
            ConfigPackageField.SETRANGE("Include Field", TRUE);
            IF ConfigPackageField.FINDSET THEN
                REPEAT
                    TempConfigPackageField := ConfigPackageField;
                    TempConfigPackageField.INSERT;
                UNTIL ConfigPackageField.NEXT = 0;

            //Set filter on table records
            RecordRef.RESET;
            ConfigPackageFilter.SETRANGE("Package Code", ConfigPackageTable."Package Code");
            ConfigPackageFilter.SETRANGE("Table ID", ConfigPackageTable."Table ID");
            ConfigPackageFilter.SETRANGE("Processing Rule No.", 0);
            IF ConfigPackageFilter.FINDSET THEN
                REPEAT
                    IF ConfigPackageFilter."Field Filter" <> '' THEN BEGIN
                        FieldRef := RecordRef.FIELD(ConfigPackageFilter."Field ID");
                        FieldRef.SETFILTER(STRSUBSTNO('%1', ConfigPackageFilter."Field Filter"));
                    END;
                UNTIL ConfigPackageFilter.NEXT = 0;

            IF RecordRef.FINDSET THEN
                REPEAT
                    ConfigPackageMgt.InitPackageRecord(ConfigPackageRecord, PackageCode, ConfigPackageTable."Table ID");

                    IF TempConfigPackageField.FINDSET THEN
                        REPEAT
                            FieldRef := RecordRef.FIELD(TempConfigPackageField."Field ID");
                            ConfigPackageData.INIT;
                            ConfigPackageData."Package Code" := TempConfigPackageField."Package Code";
                            ConfigPackageData."Table ID" := TempConfigPackageField."Table ID";
                            ConfigPackageData."Field ID" := TempConfigPackageField."Field ID";
                            ConfigPackageData."No." := ConfigPackageRecord."No.";
                            ConfigPackageData.Value := COPYSTR(FORMAT(FieldRef.VALUE), 1, MAXSTRLEN(ConfigPackageData.Value));
                            ConfigPackageData.INSERT;

                            IF NOT TempConfigPackageField.Dimension THEN BEGIN
                                IF ConfigPackageData.Value <> '' THEN BEGIN
                                    ErrorText := ConfigValidateMgt.EvaluateValue(FieldRef, ConfigPackageData.Value, FALSE);
                                    IF ErrorText <> '' THEN
                                        ConfigPackageMgt.FieldError(ConfigPackageData, ErrorText, ErrorTypeEnum::General)
                                    ELSE
                                        ConfigPackageData.Value := FORMAT(FieldRef.VALUE);

                                    ConfigPackageData.MODIFY;
                                END;
                            END;
                        UNTIL TempConfigPackageField.NEXT = 0;
                    ConfigPackageTable."Imported Date and Time" := CURRENTDATETIME;
                    ConfigPackageTable."Imported by User ID" := USERID;
                    ConfigPackageTable.MODIFY;
                    IF NOT HideDialog AND (RecordCount > 1000) THEN
                        ConfigProgressBarRecord.Update(
                          STRSUBSTNO('Records: %1 of %2', ConfigPackageRecord."No.", RecordCount));

                UNTIL RecordRef.NEXT = 0;

            IF NOT HideDialog AND (RecordCount > 1000) THEN
                ConfigProgressBarRecord.Close;
        END;
    end;

    local procedure ExcludeRemovedFields(ConfigPackageTable: Record "Config. Package Table")
    var
        "Field": Record "Field";
        ConfigPackageField: Record "Config. Package Field";
    begin
        Field.SETRANGE(TableNo, ConfigPackageTable."Table ID");
        Field.SETRANGE(ObsoleteState, Field.ObsoleteState::Removed);
        IF Field.FINDSET THEN
            REPEAT
                IF ConfigPackageField.GET(ConfigPackageTable."Package Code", Field.TableNo, Field."No.") THEN BEGIN
                    ConfigPackageField.VALIDATE("Include Field", FALSE);
                    ConfigPackageField.MODIFY;
                END;
            UNTIL Field.NEXT = 0;
    end;

    local procedure IsRecordErrorsExists(ConfigPackageRecord: Record "Config. Package Record"): Boolean
    var
        ConfigPackageError: Record "Config. Package Error";
    begin
        ConfigPackageError.SETRANGE("Package Code", ConfigPackageRecord."Package Code");
        ConfigPackageError.SETRANGE("Table ID", ConfigPackageRecord."Table ID");
        ConfigPackageError.SETRANGE("Record No.", ConfigPackageRecord."No.");
        EXIT(NOT ConfigPackageError.ISEMPTY);
    end;

    local procedure IsRecordErrorsExistsInPrimaryKeyFields(ConfigPackageRecord: Record "Config. Package Record"): Boolean
    var
        ConfigPackageError: Record "Config. Package Error";
    begin
        WITH ConfigPackageError DO BEGIN
            SETRANGE("Package Code", ConfigPackageRecord."Package Code");
            SETRANGE("Table ID", ConfigPackageRecord."Table ID");
            SETRANGE("Record No.", ConfigPackageRecord."No.");

            IF FINDSET THEN
                REPEAT
                    IF ConfigValidateMgt.IsKeyField("Table ID", "Field ID") THEN
                        EXIT(TRUE);
                UNTIL NEXT = 0;
        END;

        EXIT(FALSE);
    end;

    [Scope('Personalization')]
    procedure InsertPackageRecord(ConfigPackageRecord: Record "Config. Package Record"; CopyToCompany: Text[30])
    var
        ConfigPackageTable: Record "Config. Package Table";
        RecRef: RecordRef;
        DelayedInsert: Boolean;
    begin
        IF (ConfigPackageRecord."Package Code" = '') OR (ConfigPackageRecord."Table ID" = 0) THEN
            EXIT;

        IF ConfigMgt.IsSystemTable(ConfigPackageRecord."Table ID") THEN
            EXIT;

        RecRef.OPEN(ConfigPackageRecord."Table ID");
        RecRef.CHANGECOMPANY(CopyToCompany);
        IF ApplyMode <> ApplyMode::NonKeyFields THEN
            RecRef.INIT;

        ConfigPackageTable.GET(ConfigPackageRecord."Package Code", ConfigPackageRecord."Table ID");
        DelayedInsert := ConfigPackageTable."Delayed Insert";
        InsertPrimaryKeyFields(RecRef, ConfigPackageRecord, TRUE, DelayedInsert);

        IF ApplyMode = ApplyMode::PrimaryKey THEN
            UpdateKeyInfoForConfigPackageRecord(RecRef, ConfigPackageRecord);

        IF (ApplyMode = ApplyMode::NonKeyFields) OR DelayedInsert THEN
            ModifyRecordDataFields(RecRef, ConfigPackageRecord, TRUE, DelayedInsert);
    end;

    local procedure CollectAppliedPackageRecord(ConfigPackageRecord: Record "Config. Package Record"; var TempConfigPackageRecord: Record "Config. Package Record" temporary)
    begin
        TempConfigPackageRecord.INIT;
        TempConfigPackageRecord := ConfigPackageRecord;
        TempConfigPackageRecord.INSERT;
    end;

    local procedure CollectRecordForProcessingAction(ConfigPackageRecord: Record "Config. Package Record"; var ConfigTableProcessingRule: Record "Config. Table Processing Rule")
    begin
        ConfigTableProcessingRule.FINDSET;
        REPEAT
            IF ConfigPackageRecord.FitsProcessingFilter(ConfigTableProcessingRule."Rule No.") THEN
                TempConfigRecordForProcessing.AddRecord(ConfigPackageRecord, ConfigTableProcessingRule."Rule No.");
        UNTIL ConfigTableProcessingRule.NEXT = 0;
    end;

    local procedure InsertPrimaryKeyFields(var RecRef: RecordRef; ConfigPackageRecord: Record "Config. Package Record"; DoInsert: Boolean; var DelayedInsert: Boolean)
    var
        ConfigPackageData: Record "Config. Package Data";
        ConfigPackageField: Record "Config. Package Field";
        TempConfigPackageField: Record "Config. Package Field" temporary;
        ConfigPackageError: Record "Config. Package Error";
        RecRef1: RecordRef;
        FieldRef: FieldRef;
    begin
        ConfigPackageData.SETRANGE("Package Code", ConfigPackageRecord."Package Code");
        ConfigPackageData.SETRANGE("Table ID", ConfigPackageRecord."Table ID");
        ConfigPackageData.SETRANGE("No.", ConfigPackageRecord."No.");

        GetKeyFieldsOrder(RecRef, ConfigPackageRecord."Package Code", TempConfigPackageField);
        GetFieldsMarkedAsPrimaryKey(ConfigPackageRecord."Package Code", RecRef.NUMBER, TempConfigPackageField);

        TempConfigPackageField.RESET;
        TempConfigPackageField.SETCURRENTKEY("Package Code", "Table ID", "Processing Order");

        TempConfigPackageField.FINDSET;
        REPEAT
            FieldRef := RecRef.FIELD(TempConfigPackageField."Field ID");
            ConfigPackageData.SETRANGE("Field ID", TempConfigPackageField."Field ID");
            IF ConfigPackageData.FINDFIRST THEN BEGIN
                ConfigPackageField.GET(ConfigPackageData."Package Code", ConfigPackageData."Table ID", ConfigPackageData."Field ID");
                UpdateValueUsingMapping(ConfigPackageData, ConfigPackageField, ConfigPackageRecord."Package Code");
                ValidationFieldID := FieldRef.NUMBER;
                ConfigValidateMgt.EvaluateTextToFieldRef(
                  ConfigPackageData.Value, FieldRef, ConfigPackageField."Validate Field" AND (ApplyMode = ApplyMode::PrimaryKey));
            END ELSE
                ERROR(KeyFieldValueMissingErr, FieldRef.NAME, RecRef.NAME, ConfigPackageData."No.");
        UNTIL TempConfigPackageField.NEXT = 0;

        RecRef1 := RecRef.DUPLICATE;

        IF RecRef1.FIND THEN BEGIN
            RecRef := RecRef1;
            EXIT
        END;
        IF ((ConfigPackageRecord."Package Code" = QBPackageCodeTxt) OR (ConfigPackageRecord."Package Code" = MSGPPackageCodeTxt)) AND
           (ConfigPackageRecord."Table ID" = 15)
        THEN
            IF ConfigPackageError.GET(
                 ConfigPackageRecord."Package Code", ConfigPackageRecord."Table ID", ConfigPackageRecord."No.", 1)
            THEN
                EXIT;

        IF DelayedInsert THEN
            EXIT;

        IF DoInsert THEN BEGIN
            DelayedInsert := InsertRecord(RecRef, ConfigPackageRecord);
            RecordsInsertedCount += 1;
        END ELSE
            DelayedInsert := FALSE;
    end;

    local procedure UpdateKeyInfoForConfigPackageRecord(RecRef: RecordRef; ConfigPackageRecord: Record "Config. Package Record")
    var
        ConfigPackageData: Record "Config. Package Data";
        KeyRef: KeyRef;
        FieldRef: FieldRef;
        KeyFieldCount: Integer;
    begin
        KeyRef := RecRef.KEYINDEX(1);
        FOR KeyFieldCount := 1 TO KeyRef.FIELDCOUNT DO BEGIN
            FieldRef := KeyRef.FIELDINDEX(KeyFieldCount);

            ConfigPackageData.GET(
              ConfigPackageRecord."Package Code", ConfigPackageRecord."Table ID", ConfigPackageRecord."No.", FieldRef.NUMBER);
            ConfigPackageData.Value := FORMAT(FieldRef.VALUE);
            ConfigPackageData.MODIFY;
        END;
    end;

    local procedure ModifyRecordDataFields(var RecRef: RecordRef; ConfigPackageRecord: Record "Config. Package Record"; DoModify: Boolean; DelayedInsert: Boolean)
    var
        ConfigPackageData: Record "Config. Package Data";
        ConfigPackageField: Record "Config. Package Field";
        ConfigQuestion: Record "Config. Question";
        "Field": Record "Field";
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageError: Record "Config. Package Error";
        ConfigQuestionnaireMgt: Codeunit "Questionnaire Management";
    begin
        ConfigPackageField.RESET;
        ConfigPackageField.SETCURRENTKEY("Package Code", "Table ID", "Processing Order");
        ConfigPackageField.SETRANGE("Package Code", ConfigPackageRecord."Package Code");
        ConfigPackageField.SETRANGE("Table ID", ConfigPackageRecord."Table ID");
        ConfigPackageField.SETRANGE("Include Field", TRUE);
        ConfigPackageField.SETRANGE(Dimension, FALSE);

        ConfigPackageTable.GET(ConfigPackageRecord."Package Code", ConfigPackageRecord."Table ID");
        IF DoModify OR DelayedInsert THEN
            ApplyTemplate(ConfigPackageTable, RecRef);

        OnModifyRecordDataFieldsOnBeforeFindConfigPackageField(ConfigPackageField, ConfigPackageRecord, RecRef, DoModify, DelayedInsert);
        IF ConfigPackageField.FINDSET THEN
            REPEAT
                ValidationFieldID := ConfigPackageField."Field ID";
                IF ((ConfigPackageRecord."Package Code" = QBPackageCodeTxt) OR (ConfigPackageRecord."Package Code" = MSGPPackageCodeTxt)) AND
                   ((ConfigPackageRecord."Table ID" = 15) OR (ConfigPackageRecord."Table ID" = 18) OR
                    (ConfigPackageRecord."Table ID" = 23) OR (ConfigPackageRecord."Table ID" = 27))
                THEN
                    IF ConfigPackageError.GET(
                         ConfigPackageRecord."Package Code", ConfigPackageRecord."Table ID", ConfigPackageRecord."No.", 1)
                    THEN
                        EXIT;

                ModifyRecordDataField(
                  ConfigPackageRecord, ConfigPackageField, ConfigPackageData, ConfigPackageTable, RecRef, DoModify, DelayedInsert, TRUE);
            UNTIL ConfigPackageField.NEXT = 0;

        IF DoModify THEN BEGIN
            IF DelayedInsert THEN
                RecRef.INSERT(TRUE)
            ELSE BEGIN
                RecRef.MODIFY(NOT ConfigPackageTable."Skip Table Triggers");
                RecordsModifiedCount += 1;
            END;

            IF RecRef.NUMBER <> DATABASE::"Config. Question" THEN
                EXIT;

            RecRef.SETTABLE(ConfigQuestion);

            SetFieldFilter(Field, ConfigQuestion."Table ID", ConfigQuestion."Field ID");
            IF Field.FINDFIRST THEN
                ConfigQuestionnaireMgt.ModifyConfigQuestionAnswer(ConfigQuestion, Field);
        END;
    end;

    local procedure ModifyRecordDataField(var ConfigPackageRecord: Record "Config. Package Record"; var ConfigPackageField: Record "Config. Package Field"; var ConfigPackageData: Record "Config. Package Data"; var ConfigPackageTable: Record "Config. Package Table"; var RecRef: RecordRef; DoModify: Boolean; DelayInsert: Boolean; ReadConfigPackageData: Boolean)
    var
        FieldRef: FieldRef;
        IsTemplate: Boolean;
    begin
        IF ConfigPackageField."Primary Key" OR ConfigPackageField.AutoIncrement THEN
            EXIT;

        IF ReadConfigPackageData THEN
            IF NOT ConfigPackageData.GET(
                 ConfigPackageRecord."Package Code", ConfigPackageRecord."Table ID", ConfigPackageRecord."No.", ConfigPackageField."Field ID")
            THEN
                EXIT;

        IsTemplate := IsTemplateField(ConfigPackageTable."Data Template", ConfigPackageField."Field ID");
        IF NOT IsTemplate OR (IsTemplate AND (ConfigPackageData.Value <> '')) THEN BEGIN
            FieldRef := RecRef.FIELD(ConfigPackageField."Field ID");
            UpdateValueUsingMapping(ConfigPackageData, ConfigPackageField, ConfigPackageRecord."Package Code");

            GetCachedConfigPackageField(ConfigPackageData);
            CASE TRUE OF
                IsBLOBFieldInternal(TempConfigPackageFieldCache."Processing Order"):
                    EvaluateBLOBToFieldRef(ConfigPackageData, FieldRef);
                IsMediaSetFieldInternal(TempConfigPackageFieldCache."Processing Order"):
                    ImportMediaSetFiles(ConfigPackageData, FieldRef, DoModify);
                IsMediaFieldInternal(TempConfigPackageFieldCache."Processing Order"):
                    ImportMediaFiles(ConfigPackageData, FieldRef, DoModify);
                ELSE
                    ConfigValidateMgt.EvaluateTextToFieldRef(
                      ConfigPackageData.Value, FieldRef,
                      ConfigPackageField."Validate Field" AND ((ApplyMode = ApplyMode::NonKeyFields) OR DelayInsert));
            END;
        END;
    end;

    local procedure ClearFieldBranchCheckingHistory(PackageCode: Code[20]; var CheckedConfigPackageTable: Record "Config. Package Table"; StackLevel: Integer)
    begin
        CheckedConfigPackageTable.SETRANGE("Package Code", PackageCode);
        CheckedConfigPackageTable.SETFILTER("Processing Order", '>%1', StackLevel);
        CheckedConfigPackageTable.DELETEALL;
    end;

    local procedure AdjustProcessingOrder(var ConfigPackageTable: Record "Config. Package Table")
    var
        RelatedConfigPackageTable: Record "Config. Package Table";
    begin
        WITH ConfigPackageTable DO
            CASE "Table ID" OF
                DATABASE::"G/L Account Category": // Pushing G/L Account Category before G/L Account
                    IF RelatedConfigPackageTable.GET("Package Code", DATABASE::"G/L Account") THEN
                        "Processing Order" := RelatedConfigPackageTable."Processing Order" - 1;
                DATABASE::"Sales Header" .. DATABASE::"Purchase Line": // Moving Sales/Purchase Documents down
                    "Processing Order" += 4;
                DATABASE::"Company Information":
                    "Processing Order" += 1;
                DATABASE::"Custom Report Layout": // Moving Layouts to be on the top
                    "Processing Order" := 0;
                // Moving Jobs tables down so contacts table can be processed first
                DATABASE::Job, DATABASE::"Job Task", DATABASE::"Job Planning Line", DATABASE::"Job Journal Line",
              DATABASE::"Job Journal Batch", DATABASE::"Job Posting Group", DATABASE::"Job Journal Template",
              DATABASE::"Job Responsibility":
                    "Processing Order" += 4;
            END;
    end;

    local procedure MaxInt(Int1: Integer; Int2: Integer): Integer
    begin
        IF Int1 > Int2 THEN
            EXIT(Int1);

        EXIT(Int2);
    end;

    local procedure GetDimSetID(PackageCode: Code[20]; DimSetValue: Text[250]): Integer
    var
        ConfigPackageData: Record "Config. Package Data";
        ConfigPackageData2: Record "Config. Package Data";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit "DimensionManagement";
    begin
        ConfigPackageData.SETRANGE("Package Code", PackageCode);
        ConfigPackageData.SETRANGE("Table ID", DATABASE::"Dimension Set Entry");
        ConfigPackageData.SETRANGE("Field ID", TempDimSetEntry.FIELDNO("Dimension Set ID"));
        IF ConfigPackageData.FINDSET THEN
            REPEAT
                IF ConfigPackageData.Value = DimSetValue THEN BEGIN
                    TempDimSetEntry.INIT;
                    ConfigPackageData2.GET(
                      ConfigPackageData."Package Code", ConfigPackageData."Table ID", ConfigPackageData."No.",
                      TempDimSetEntry.FIELDNO("Dimension Code"));
                    TempDimSetEntry.VALIDATE("Dimension Code", FORMAT(ConfigPackageData2.Value));
                    ConfigPackageData2.GET(
                      ConfigPackageData."Package Code", ConfigPackageData."Table ID", ConfigPackageData."No.",
                      TempDimSetEntry.FIELDNO("Dimension Value Code"));
                    TempDimSetEntry.VALIDATE(
                      "Dimension Value Code", COPYSTR(FORMAT(ConfigPackageData2.Value), 1, MAXSTRLEN(TempDimSetEntry."Dimension Value Code")));
                    TempDimSetEntry.INSERT;
                END;
            UNTIL ConfigPackageData.NEXT = 0;

        EXIT(DimMgt.GetDimensionSetID(TempDimSetEntry));
    end;

    [Scope('Personalization')]
    procedure GetDimSetIDForRecord(ConfigPackageRecord: Record "Config. Package Record"): Integer
    var
        ConfigPackageData: Record "Config. Package Data";
        ConfigPackageField: Record "Config. Package Field";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimValue: Record "Dimension Value";
        DimMgt: Codeunit "DimensionManagement";
        ConfigPackageMgt: Codeunit "Config. Package Management";
        DimCode: Code[20];
        DimValueCode: Code[20];
        DimValueNotFound: Boolean;
    begin
        ConfigPackageData.SETRANGE("Package Code", ConfigPackageRecord."Package Code");
        ConfigPackageData.SETRANGE("Table ID", ConfigPackageRecord."Table ID");
        ConfigPackageData.SETRANGE("No.", ConfigPackageRecord."No.");
        ConfigPackageData.SETRANGE("Field ID", ConfigMgt.DimensionFieldID, ConfigMgt.DimensionFieldID + 999);
        ConfigPackageData.SETFILTER(Value, '<>%1', '');
        IF ConfigPackageData.FINDSET THEN
            REPEAT
                IF ConfigPackageField.GET(ConfigPackageData."Package Code", ConfigPackageData."Table ID", ConfigPackageData."Field ID") THEN BEGIN
                    ConfigPackageField.TESTFIELD(Dimension);
                    DimCode := COPYSTR(FORMAT(ConfigPackageField."Field Name"), 1, 20);
                    DimValueCode := COPYSTR(FORMAT(ConfigPackageData.Value), 1, MAXSTRLEN(TempDimSetEntry."Dimension Value Code"));
                    TempDimSetEntry.INIT;
                    TempDimSetEntry.VALIDATE("Dimension Code", DimCode);
                    IF DimValue.GET(DimCode, DimValueCode) THEN BEGIN
                        TempDimSetEntry.VALIDATE("Dimension Value Code", DimValueCode);
                        TempDimSetEntry.INSERT;
                    END ELSE BEGIN
                        ConfigPackageMgt.FieldError(
                          ConfigPackageData, STRSUBSTNO(DimValueDoesNotExistsErr, DimCode, DimValueCode), ErrorTypeEnum::General);
                        DimValueNotFound := TRUE;
                    END;
                END;
            UNTIL ConfigPackageData.NEXT = 0;
        IF DimValueNotFound THEN
            EXIT(0);
        EXIT(DimMgt.GetDimensionSetID(TempDimSetEntry));
    end;

    local procedure UpdateDimSetIDValues(ConfigPackage: Record "Config. Package")
    var
        ConfigPackageData: Record "Config. Package Data";
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageTableDim: Record "Config. Package Table";
        ConfigPackageDataDimSet: Record "Config. Package Data";
        DimSetEntry: Record "Dimension Set Entry";
    begin
        ConfigPackageTableDim.SETRANGE("Package Code", ConfigPackage.Code);
        ConfigPackageTableDim.SETRANGE("Table ID", DATABASE::Dimension, DATABASE::"Default Dimension Priority");
        IF NOT ConfigPackageTableDim.ISEMPTY THEN BEGIN
            ApplyPackageTables(ConfigPackage, ConfigPackageTableDim, ApplyMode::PrimaryKey, ConfigPackage."Copy to Company");
            ApplyPackageTables(ConfigPackage, ConfigPackageTableDim, ApplyMode::NonKeyFields, ConfigPackage."Copy to Company");
        END;

        ConfigPackageDataDimSet.SETRANGE("Package Code", ConfigPackage.Code);
        ConfigPackageDataDimSet.SETRANGE("Table ID", DATABASE::"Dimension Set Entry");
        ConfigPackageDataDimSet.SETRANGE("Field ID", DimSetEntry.FIELDNO("Dimension Set ID"));
        IF ConfigPackageDataDimSet.ISEMPTY THEN
            EXIT;

        ConfigPackageData.RESET;
        ConfigPackageData.SETRANGE("Package Code", ConfigPackage.Code);
        ConfigPackageData.SETFILTER("Table ID", '<>%1', DATABASE::"Dimension Set Entry");
        ConfigPackageData.SETRANGE("Field ID", DATABASE::"Dimension Set Entry");
        IF ConfigPackageData.FINDSET(TRUE) THEN BEGIN
            IF NOT HideDialog THEN
                ConfigProgressBar.Init(ConfigPackageData.COUNT, 1, UpdatingDimSetsMsg);
            REPEAT
                ConfigPackageTable.GET(ConfigPackage.Code, ConfigPackageData."Table ID");
                ConfigPackageTable.CALCFIELDS("Table Name");
                IF NOT HideDialog THEN
                    ConfigProgressBar.Update(ConfigPackageTable."Table Name");
                IF ConfigPackageData.Value <> '' THEN BEGIN
                    ConfigPackageData.Value := FORMAT(GetDimSetID(ConfigPackage.Code, ConfigPackageData.Value));
                    ConfigPackageData.MODIFY;
                END;
            UNTIL ConfigPackageData.NEXT = 0;
            IF NOT HideDialog THEN
                ConfigProgressBar.Close;
        END;
    end;

    [Scope('Personalization')]
    procedure UpdateDefaultDimValues(ConfigPackageRecord: Record "Config. Package Record"; MasterNo: Code[20])
    var
        ConfigPackageTableDim: Record "Config. Package Table";
        ConfigPackageRecordDim: Record "Config. Package Record";
        ConfigPackageDataDim: array[4] of Record "Config. Package Data";
        ConfigPackageField: Record "Config. Package Field";
        ConfigPackageData: Record "Config. Package Data";
        DefaultDim: Record "Default Dimension";
        DimValue: Record "Dimension Value";
        RecordFound: Boolean;
    begin
        ConfigPackageRecord.TESTFIELD("Package Code");
        ConfigPackageRecord.TESTFIELD("Table ID");

        ConfigPackageData.RESET;
        ConfigPackageData.SETRANGE("Package Code", ConfigPackageRecord."Package Code");
        ConfigPackageData.SETRANGE("Table ID", ConfigPackageRecord."Table ID");
        ConfigPackageData.SETRANGE("No.", ConfigPackageRecord."No.");
        ConfigPackageData.SETRANGE("Field ID", ConfigMgt.DimensionFieldID, ConfigMgt.DimensionFieldID + 999);
        ConfigPackageData.SETFILTER(Value, '<>%1', '');
        IF ConfigPackageData.FINDSET THEN
            REPEAT
                IF ConfigPackageField.GET(ConfigPackageData."Package Code", ConfigPackageData."Table ID", ConfigPackageData."Field ID") THEN BEGIN
                    // find if Dimension Code already exist
                    RecordFound := FALSE;
                    ConfigPackageDataDim[1].SETRANGE("Package Code", ConfigPackageRecord."Package Code");
                    ConfigPackageDataDim[1].SETRANGE("Table ID", DATABASE::"Default Dimension");
                    ConfigPackageDataDim[1].SETRANGE("Field ID", DefaultDim.FIELDNO("Table ID"));
                    ConfigPackageDataDim[1].SETRANGE(Value, FORMAT(ConfigPackageRecord."Table ID"));
                    IF ConfigPackageDataDim[1].FINDSET THEN
                        REPEAT
                            ConfigPackageDataDim[2].SETRANGE("Package Code", ConfigPackageRecord."Package Code");
                            ConfigPackageDataDim[2].SETRANGE("Table ID", DATABASE::"Default Dimension");
                            ConfigPackageDataDim[2].SETRANGE("No.", ConfigPackageDataDim[1]."No.");
                            ConfigPackageDataDim[2].SETRANGE("Field ID", DefaultDim.FIELDNO("No."));
                            ConfigPackageDataDim[2].SETRANGE(Value, MasterNo);
                            IF ConfigPackageDataDim[2].FINDSET THEN
                                REPEAT
                                    ConfigPackageDataDim[3].SETRANGE("Package Code", ConfigPackageRecord."Package Code");
                                    ConfigPackageDataDim[3].SETRANGE("Table ID", DATABASE::"Default Dimension");
                                    ConfigPackageDataDim[3].SETRANGE("No.", ConfigPackageDataDim[2]."No.");
                                    ConfigPackageDataDim[3].SETRANGE("Field ID", DefaultDim.FIELDNO("Dimension Code"));
                                    ConfigPackageDataDim[3].SETRANGE(Value, ConfigPackageField."Field Name");
                                    RecordFound := ConfigPackageDataDim[3].FINDFIRST;
                                UNTIL (ConfigPackageDataDim[2].NEXT = 0) OR RecordFound;
                        UNTIL (ConfigPackageDataDim[1].NEXT = 0) OR RecordFound;
                    IF NOT RecordFound THEN BEGIN
                        IF NOT ConfigPackageTableDim.GET(ConfigPackageRecord."Package Code", DATABASE::"Default Dimension") THEN
                            ConfigPackageMgt.InsertPackageTable(ConfigPackageTableDim, ConfigPackageRecord."Package Code", DATABASE::"Default Dimension");
                        ConfigPackageMgt.InitPackageRecord(ConfigPackageRecordDim, ConfigPackageTableDim."Package Code", ConfigPackageTableDim."Table ID");
                        // Insert Default Dimension record
                        ConfigPackageMgt.InsertPackageData(ConfigPackageDataDim[4],
                          ConfigPackageRecordDim."Package Code", ConfigPackageRecordDim."Table ID", ConfigPackageRecordDim."No.",
                          DefaultDim.FIELDNO("Table ID"), FORMAT(ConfigPackageRecord."Table ID"), FALSE);
                        ConfigPackageMgt.InsertPackageData(ConfigPackageDataDim[4],
                          ConfigPackageRecordDim."Package Code", ConfigPackageRecordDim."Table ID", ConfigPackageRecordDim."No.",
                          DefaultDim.FIELDNO("No."), FORMAT(MasterNo), FALSE);
                        ConfigPackageMgt.InsertPackageData(ConfigPackageDataDim[4],
                          ConfigPackageRecordDim."Package Code", ConfigPackageRecordDim."Table ID", ConfigPackageRecordDim."No.",
                          DefaultDim.FIELDNO("Dimension Code"), ConfigPackageField."Field Name", FALSE);
                        IF IsBlankDim(ConfigPackageData.Value) THEN
                            ConfigPackageMgt.InsertPackageData(ConfigPackageDataDim[4],
                              ConfigPackageRecordDim."Package Code", ConfigPackageRecordDim."Table ID", ConfigPackageRecordDim."No.",
                              DefaultDim.FIELDNO("Dimension Value Code"), '', FALSE)
                        ELSE
                            ConfigPackageMgt.InsertPackageData(ConfigPackageDataDim[4],
                              ConfigPackageRecordDim."Package Code", ConfigPackageRecordDim."Table ID", ConfigPackageRecordDim."No.",
                              DefaultDim.FIELDNO("Dimension Value Code"), ConfigPackageData.Value, FALSE);
                    END ELSE BEGIN
                        ConfigPackageDataDim[3].SETRANGE("Field ID", DefaultDim.FIELDNO("Dimension Value Code"));
                        ConfigPackageDataDim[3].SETRANGE(Value);
                        ConfigPackageDataDim[3].FINDFIRST;
                        ConfigPackageDataDim[3].Value := ConfigPackageData.Value;
                        ConfigPackageDataDim[3].MODIFY;
                    END;
                    // Insert Dimension value if needed
                    IF NOT IsBlankDim(ConfigPackageData.Value) THEN
                        IF NOT DimValue.GET(ConfigPackageField."Field Name", ConfigPackageData.Value) THEN BEGIN
                            ConfigPackageRecord.TESTFIELD("Package Code");
                            IF NOT ConfigPackageTableDim.GET(ConfigPackageRecord."Package Code", DATABASE::"Dimension Value") THEN
                                ConfigPackageMgt.InsertPackageTable(ConfigPackageTableDim, ConfigPackageRecord."Package Code", DATABASE::"Dimension Value");
                            ConfigPackageMgt.InitPackageRecord(ConfigPackageRecordDim, ConfigPackageTableDim."Package Code", ConfigPackageTableDim."Table ID");
                            ConfigPackageMgt.InsertPackageData(ConfigPackageDataDim[4],
                              ConfigPackageRecordDim."Package Code", ConfigPackageRecordDim."Table ID", ConfigPackageRecordDim."No.",
                              DimValue.FIELDNO("Dimension Code"), ConfigPackageField."Field Name", FALSE);
                            ConfigPackageMgt.InsertPackageData(ConfigPackageDataDim[4],
                              ConfigPackageRecordDim."Package Code", ConfigPackageRecordDim."Table ID", ConfigPackageRecordDim."No.",
                              DimValue.FIELDNO(Code), ConfigPackageData.Value, FALSE);
                        END;
                END;
            UNTIL ConfigPackageData.NEXT = 0;
    end;

    local procedure IsBlankDim(Value: Text[250]): Boolean
    begin
        EXIT(UPPERCASE(Value) = UPPERCASE(BlankTxt));
    end;

    local procedure GetKeyFieldsOrder(RecRef: RecordRef; PackageCode: Code[20]; var TempConfigPackageField: Record "Config. Package Field" temporary)
    var
        ConfigPackageField: Record "Config. Package Field";
        KeyRef: KeyRef;
        FieldRef: FieldRef;
        KeyFieldCount: Integer;
    begin
        KeyRef := RecRef.KEYINDEX(1);
        FOR KeyFieldCount := 1 TO KeyRef.FIELDCOUNT DO BEGIN
            FieldRef := KeyRef.FIELDINDEX(KeyFieldCount);
            ValidationFieldID := FieldRef.NUMBER;

            IF ConfigPackageField.GET(PackageCode, RecRef.NUMBER, FieldRef.NUMBER) THEN;

            TempConfigPackageField.INIT;
            TempConfigPackageField."Package Code" := PackageCode;
            TempConfigPackageField."Table ID" := RecRef.NUMBER;
            TempConfigPackageField."Field ID" := FieldRef.NUMBER;
            TempConfigPackageField."Processing Order" := ConfigPackageField."Processing Order";
            TempConfigPackageField.INSERT;
        END;
    end;

    local procedure GetFieldsMarkedAsPrimaryKey(PackageCode: Code[20]; TableID: Integer; var TempConfigPackageField: Record "Config. Package Field" temporary)
    var
        ConfigPackageField: Record "Config. Package Field";
    begin
        ConfigPackageField.SETRANGE("Package Code", PackageCode);
        ConfigPackageField.SETRANGE("Table ID", TableID);
        ConfigPackageField.FILTERGROUP(-1);
        ConfigPackageField.SETRANGE("Primary Key", TRUE);
        ConfigPackageField.SETRANGE(AutoIncrement, TRUE);
        ConfigPackageField.FILTERGROUP(0);
        IF ConfigPackageField.FINDSET THEN
            REPEAT
                TempConfigPackageField.TRANSFERFIELDS(ConfigPackageField);
                IF TempConfigPackageField.INSERT THEN;
            UNTIL ConfigPackageField.NEXT = 0;
    end;

    [Scope('Personalization')]
    procedure GetFieldsOrder(RecRef: RecordRef; PackageCode: Code[20]; var TempConfigPackageField: Record "Config. Package Field" temporary)
    var
        ConfigPackageField: Record "Config. Package Field";
        FieldRef: FieldRef;
        FieldCount: Integer;
    begin
        FOR FieldCount := 1 TO RecRef.FIELDCOUNT DO BEGIN
            FieldRef := RecRef.FIELDINDEX(FieldCount);

            IF ConfigPackageField.GET(PackageCode, RecRef.NUMBER, FieldRef.NUMBER) THEN;

            TempConfigPackageField.INIT;
            TempConfigPackageField."Package Code" := PackageCode;
            TempConfigPackageField."Table ID" := RecRef.NUMBER;
            TempConfigPackageField."Field ID" := FieldRef.NUMBER;
            TempConfigPackageField."Processing Order" := ConfigPackageField."Processing Order";
            TempConfigPackageField.INSERT;
        END;
    end;

    local procedure UpdateValueUsingMapping(var ConfigPackageData: Record "Config. Package Data"; ConfigPackageField: Record "Config. Package Field"; PackageCode: Code[20])
    var
        ConfigFieldMapping: Record "Config. Field Map";
        NewValue: Text[250];
    begin

        ConfigFieldMapping.Reset();
        ConfigFieldMapping.SetRange("Package Code", ConfigPackageData."Package Code");
        ConfigFieldMapping.SetRange("Table ID", ConfigPackageField."Table ID");
        ConfigFieldMapping.SetRange("Field ID", ConfigPackageField."Field ID");
        ConfigFieldMapping.SetRange("Old Value", ConfigPackageData.Value);
        IF ConfigFieldMapping.FindFirst() THEN
            NewValue := ConfigFieldMapping."New Value";

        IF (NewValue = '') AND (ConfigPackageField."Relation Table ID" <> 0) THEN
            NewValue := GetMappingFromPKOfRelatedTable(ConfigPackageField, ConfigPackageData.Value);

        IF NewValue <> '' THEN BEGIN
            ConfigPackageData.VALIDATE(Value, NewValue);
            ConfigPackageData.MODIFY;
        END;

        IF ConfigPackageField."Create Missing Codes" THEN
            CreateMissingCodes(ConfigPackageData, ConfigPackageField."Relation Table ID", PackageCode);
    end;

    local procedure InsertRecord(var RecRef: RecordRef; ConfigPackageRecord: Record "Config. Package Record"): Boolean
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigInsertWithValidation: Codeunit "Config. Insert With Validation";
    begin
        ConfigPackageTable.GET(ConfigPackageRecord."Package Code", ConfigPackageRecord."Table ID");
        IF ConfigPackageTable."Skip Table Triggers" THEN
            RecRef.INSERT
        ELSE BEGIN
            COMMIT;
            ConfigInsertWithValidation.SetInsertParameters(RecRef);
            IF NOT ConfigInsertWithValidation.RUN THEN BEGIN
                CLEARLASTERROR;
                EXIT(TRUE);
            END;
        END;
        EXIT(FALSE);
    end;

    local procedure ApplyTemplate(ConfigPackageTable: Record "Config. Package Table"; var RecRef: RecordRef)
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
    begin
        IF ConfigTemplateHeader.GET(ConfigPackageTable."Data Template") THEN BEGIN
            ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
            InsertDimensionsFromTemplates(ConfigPackageTable."Table ID", ConfigTemplateHeader, RecRef);
        END;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnModifyRecordDataFieldsOnBeforeFindConfigPackageField(var ConfigPackageField: Record "Config. Package Field"; ConfigPackageRecord: Record "Config. Package Record"; RecRef: RecordRef; DoModify: Boolean; DelayedInsert: Boolean)
    begin
    end;

    [Scope('Personalization')]
    procedure SetFieldFilter(var "Field": Record "Field"; TableID: Integer; FieldID: Integer)
    begin
        Field.RESET;
        IF TableID > 0 THEN
            Field.SETRANGE(TableNo, TableID);
        IF FieldID > 0 THEN
            Field.SETRANGE("No.", FieldID);
        Field.SETRANGE(Class, Field.Class::Normal);
        Field.SETRANGE(Enabled, TRUE);
        Field.SETFILTER(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
    end;

    [Scope('Personalization')]
    procedure SetupProcessingOrder(var ConfigPackageTable: Record "Config. Package Table")
    var
        ConfigPackageTableLoop: Record "Config. Package Table";
        TempConfigPackageTable: Record "Config. Package Table" temporary;
        Flag: Integer;
    begin
        ConfigPackageTableLoop.COPYFILTERS(ConfigPackageTable);
        IF NOT ConfigPackageTableLoop.FINDSET(TRUE) THEN
            EXIT;

        Flag := -1; // flag for all selected records: record processing order no was not initialized

        REPEAT
            ConfigPackageTableLoop."Processing Order" := Flag;
            ConfigPackageTableLoop.MODIFY;
        UNTIL ConfigPackageTableLoop.NEXT = 0;

        ConfigPackageTable.FINDSET(TRUE);
        REPEAT
            IF ConfigPackageTable."Processing Order" = Flag THEN BEGIN
                SetupTableProcessingOrder(ConfigPackageTable."Package Code", ConfigPackageTable."Table ID", TempConfigPackageTable, 1);
                TempConfigPackageTable.RESET;
                TempConfigPackageTable.DELETEALL;
            END;
        UNTIL ConfigPackageTable.NEXT = 0;
    end;

    local procedure SetupTableProcessingOrder(PackageCode: Code[20]; TableId: Integer; var CheckedConfigPackageTable: Record "Config. Package Table"; StackLevel: Integer): Integer
    var
        ConfigPackageTable: Record "Config. Package Table";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        KeyRef: KeyRef;
        I: Integer;
        ProcessingOrder: Integer;
    begin
        IF CheckedConfigPackageTable.GET(PackageCode, TableId) THEN
            ERROR(ProcessingOrderErr, TableId);

        CheckedConfigPackageTable.INIT;
        CheckedConfigPackageTable."Package Code" := PackageCode;
        CheckedConfigPackageTable."Table ID" := TableId;
        // level to cleanup temptable from field branch checking history for case with multiple field branches
        CheckedConfigPackageTable."Processing Order" := StackLevel;
        CheckedConfigPackageTable.INSERT;

        RecRef.OPEN(TableId);
        KeyRef := RecRef.KEYINDEX(1);

        ProcessingOrder := 1;

        FOR I := 1 TO KeyRef.FIELDCOUNT DO BEGIN
            FieldRef := KeyRef.FIELDINDEX(I);
            IF (FieldRef.RELATION <> 0) AND (FieldRef.RELATION <> TableId) THEN
                IF ConfigPackageTable.GET(PackageCode, FieldRef.RELATION) THEN BEGIN
                    ProcessingOrder :=
                      MaxInt(
                        SetupTableProcessingOrder(PackageCode, FieldRef.RELATION, CheckedConfigPackageTable, StackLevel + 1) + 1, ProcessingOrder);
                    ClearFieldBranchCheckingHistory(PackageCode, CheckedConfigPackageTable, StackLevel);
                END;
        END;

        IF ConfigPackageTable.GET(PackageCode, TableId) THEN BEGIN
            ConfigPackageTable."Processing Order" := ProcessingOrder;
            AdjustProcessingOrder(ConfigPackageTable);
            ConfigPackageTable.MODIFY;
        END;

        EXIT(ProcessingOrder);
    end;

    local procedure IsTemplateField(TemplateCode: Code[20]; FieldNo: Integer): Boolean
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateLine: Record "Config. Template Line";
    begin
        IF TemplateCode = '' THEN
            EXIT(FALSE);

        IF NOT ConfigTemplateHeader.GET(TemplateCode) THEN
            EXIT(FALSE);

        ConfigTemplateLine.SETRANGE("Data Template Code", ConfigTemplateHeader.Code);
        ConfigTemplateLine.SETRANGE("Field ID", FieldNo);
        ConfigTemplateLine.SETRANGE(Type, ConfigTemplateLine.Type::Field);
        IF NOT ConfigTemplateLine.ISEMPTY THEN
            EXIT(TRUE);

        ConfigTemplateLine.SETRANGE("Field ID");
        ConfigTemplateLine.SETRANGE(Type, ConfigTemplateLine.Type::Template);
        IF ConfigTemplateLine.FINDSET THEN
            REPEAT
                IF IsTemplateField(ConfigTemplateLine."Template Code", FieldNo) THEN
                    EXIT(TRUE);
            UNTIL ConfigTemplateLine.NEXT = 0;
        EXIT(FALSE);
    end;

    local procedure GetCachedConfigPackageField(ConfigPackageData: Record "Config. Package Data")
    var
        "Field": Record "Field";
    begin
        WITH TempConfigPackageFieldCache DO
            IF NOT GET(ConfigPackageData."Package Code", ConfigPackageData."Table ID", ConfigPackageData."Field ID") THEN BEGIN
                INIT;
                "Package Code" := ConfigPackageData."Package Code";
                "Table ID" := ConfigPackageData."Table ID";
                "Field ID" := ConfigPackageData."Field ID";
                IF TypeHelper.GetField("Table ID", "Field ID", Field) THEN
                    "Processing Order" := Field.Type;
                INSERT;
            END;
    end;

    [Scope('Personalization')]
    procedure IsBLOBField(TableId: Integer; FieldId: Integer): Boolean
    var
        "Field": Record "Field";
    begin
        IF TypeHelper.GetField(TableId, FieldId, Field) THEN
            EXIT(Field.Type = Field.Type::BLOB);
        EXIT(FALSE);
    end;

    local procedure IsBLOBFieldInternal(FieldType: Integer): Boolean
    var
        "Field": Record "Field";
    begin
        EXIT(FieldType = Field.Type::BLOB);
    end;

    local procedure EvaluateBLOBToFieldRef(var ConfigPackageData: Record "Config. Package Data"; var FieldRef: FieldRef)
    begin
        ConfigPackageData.CALCFIELDS("BLOB Value");
        FieldRef.VALUE := ConfigPackageData."BLOB Value";
    end;

    local procedure ImportMediaSetFiles(var ConfigPackageData: Record "Config. Package Data"; var FieldRef: FieldRef; DoModify: Boolean)
    var
        TempConfigMediaBuffer: Record "Config. Media Buffer" temporary;
        MediaSetIDConfigPackageData: Record "Config. Package Data";
        BlobMediaSetConfigPackageData: Record "Config. Package Data";
        BlobInStream: InStream;
        MediaSetID: Text;
    begin
        IF NOT CanImportMediaField(ConfigPackageData, FieldRef, DoModify, MediaSetID) THEN
            EXIT;

        MediaSetIDConfigPackageData.SETRANGE("Package Code", ConfigPackageData."Package Code");
        MediaSetIDConfigPackageData.SETRANGE("Table ID", DATABASE::"Config. Media Buffer");
        MediaSetIDConfigPackageData.SETRANGE("Field ID", TempConfigMediaBuffer.FIELDNO("Media Set ID"));
        MediaSetIDConfigPackageData.SETRANGE(Value, MediaSetID);

        IF NOT MediaSetIDConfigPackageData.FINDSET THEN
            EXIT;

        TempConfigMediaBuffer.INIT;
        TempConfigMediaBuffer.INSERT;
        BlobMediaSetConfigPackageData.SETAUTOCALCFIELDS("BLOB Value");

        REPEAT
            BlobMediaSetConfigPackageData.GET(
              MediaSetIDConfigPackageData."Package Code", MediaSetIDConfigPackageData."Table ID", MediaSetIDConfigPackageData."No.",
              TempConfigMediaBuffer.FIELDNO("Media Blob"));
            BlobMediaSetConfigPackageData."BLOB Value".CREATEINSTREAM(BlobInStream);
            TempConfigMediaBuffer."Media Set".IMPORTSTREAM(BlobInStream, '');
            TempConfigMediaBuffer.MODIFY;
        UNTIL MediaSetIDConfigPackageData.NEXT = 0;

        FieldRef.VALUE := FORMAT(TempConfigMediaBuffer."Media Set");
    end;

    [Scope('Personalization')]
    procedure IsMediaSetField(TableId: Integer; FieldId: Integer): Boolean
    var
        "Field": Record "Field";
    begin
        IF TypeHelper.GetField(TableId, FieldId, Field) THEN
            EXIT(Field.Type = Field.Type::MediaSet);
        EXIT(FALSE);
    end;

    local procedure IsMediaSetFieldInternal(FieldType: Integer): Boolean
    var
        "Field": Record "Field";
    begin
        EXIT(FieldType = Field.Type::MediaSet);
    end;

    [Scope('Personalization')]
    procedure IsMediaField(TableId: Integer; FieldId: Integer): Boolean
    var
        "Field": Record "Field";
    begin
        IF TypeHelper.GetField(TableId, FieldId, Field) THEN
            EXIT(Field.Type = Field.Type::Media);
        EXIT(FALSE);
    end;

    local procedure IsMediaFieldInternal(FieldType: Integer): Boolean
    var
        "Field": Record "Field";
    begin
        EXIT(FieldType = Field.Type::Media);
    end;

    local procedure ImportMediaFiles(var ConfigPackageData: Record "Config. Package Data"; var FieldRef: FieldRef; DoModify: Boolean)
    var
        TempConfigMediaBuffer: Record "Config. Media Buffer" temporary;
        MediaIDConfigPackageData: Record "Config. Package Data";
        BlobMediaConfigPackageData: Record "Config. Package Data";
        BlobInStream: InStream;
        MediaID: Text;
    begin
        IF NOT CanImportMediaField(ConfigPackageData, FieldRef, DoModify, MediaID) THEN
            EXIT;

        MediaIDConfigPackageData.SETRANGE("Package Code", ConfigPackageData."Package Code");
        MediaIDConfigPackageData.SETRANGE("Table ID", DATABASE::"Config. Media Buffer");
        MediaIDConfigPackageData.SETRANGE("Field ID", TempConfigMediaBuffer.FIELDNO("Media ID"));
        MediaIDConfigPackageData.SETRANGE(Value, MediaID);

        IF NOT MediaIDConfigPackageData.FINDFIRST THEN
            EXIT;

        BlobMediaConfigPackageData.SETAUTOCALCFIELDS("BLOB Value");

        BlobMediaConfigPackageData.GET(
          MediaIDConfigPackageData."Package Code", MediaIDConfigPackageData."Table ID", MediaIDConfigPackageData."No.",
          TempConfigMediaBuffer.FIELDNO("Media Blob"));
        BlobMediaConfigPackageData."BLOB Value".CREATEINSTREAM(BlobInStream);

        TempConfigMediaBuffer.INIT;
        TempConfigMediaBuffer.Media.IMPORTSTREAM(BlobInStream, '');
        TempConfigMediaBuffer.INSERT;

        FieldRef.VALUE := FORMAT(TempConfigMediaBuffer.Media);
    end;

    local procedure CanImportMediaField(var ConfigPackageData: Record "Config. Package Data"; var FieldRef: FieldRef; DoModify: Boolean; var MediaID: Text): Boolean
    var
        RecRef: RecordRef;
        DummyNotInitializedGuid: Guid;
    begin
        IF NOT DoModify THEN
            EXIT(FALSE);

        RecRef := FieldRef.RECORD;
        IF RecRef.NUMBER = DATABASE::"Config. Media Buffer" THEN
            EXIT(FALSE);

        MediaID := FORMAT(ConfigPackageData.Value);
        IF (MediaID = FORMAT(DummyNotInitializedGuid)) OR (MediaID = '') THEN
            EXIT(FALSE);

        EXIT(TRUE);
    end;

    local procedure GetMappingFromPKOfRelatedTable(ConfigPackageField: Record "Config. Package Field"; MappingOldValue: Text[250]): Text[250]
    var
        ConfigPackageField2: Record "Config. Package Field";
        ConfigFieldMapping: Record "Config. Field Map";
    begin
        ConfigPackageField2.SETRANGE("Package Code", ConfigPackageField."Package Code");
        ConfigPackageField2.SETRANGE("Table ID", ConfigPackageField."Relation Table ID");
        ConfigPackageField2.SETRANGE("Primary Key", TRUE);
        IF ConfigPackageField2.FINDFIRST THEN begin
            ConfigFieldMapping.Reset();
            ConfigFieldMapping.SetRange("Package Code", ConfigPackageField2."Package Code");
            ConfigFieldMapping.SetRange("Table ID", ConfigPackageField2."Table ID");
            ConfigFieldMapping.SetRange("Field ID", ConfigPackageField2."Field ID");
            ConfigFieldMapping.SetRange("Old Value", MappingOldValue);
            IF ConfigFieldMapping.FindFirst() THEN
                EXIT(ConfigFieldMapping."New Value");
        end;
    end;

    local procedure CreateMissingCodes(var ConfigPackageData: Record "Config. Package Data"; RelationTableID: Integer; PackageCode: Code[20])
    var
        RecRef: RecordRef;
        KeyRef: KeyRef;
        FieldRef: array[16] of FieldRef;
        i: Integer;
    begin
        RecRef.OPEN(RelationTableID);
        KeyRef := RecRef.KEYINDEX(1);
        FOR i := 1 TO KeyRef.FIELDCOUNT DO BEGIN
            FieldRef[i] := KeyRef.FIELDINDEX(i);
            FieldRef[i].VALUE(RelatedKeyFieldValue(ConfigPackageData, RelationTableID, FieldRef[i].NUMBER));
        END;

        // even "Create Missing Codes" is marked we should not create for blank account numbers and blank/zero account categories should not be created
        IF ConfigPackageData."Table ID" <> 15 THEN BEGIN
            IF RecRef.INSERT THEN;
        END ELSE
            IF (ConfigPackageData.Value <> '') AND ((ConfigPackageData.Value <> '0') AND (ConfigPackageData."Field ID" = 80)) OR
               ((PackageCode <> QBPackageCodeTxt) AND (PackageCode <> MSGPPackageCodeTxt))
            THEN
                IF RecRef.INSERT THEN;
    end;

    [Scope('Personalization')]
    procedure CleanPackageErrors(PackageCode: Code[20]; TableFilter: Text)
    var
        ConfigPackageError: Record "Config. Package Error";
    begin
        ConfigPackageError.SETRANGE("Package Code", PackageCode);
        IF TableFilter <> '' THEN
            ConfigPackageError.SETFILTER("Table ID", TableFilter);

        ConfigPackageError.DELETEALL;
    end;

    local procedure InsertDimensionsFromTemplates(TableID: Integer; ConfigTemplateHeader: Record "Config. Template Header"; var RecRef: RecordRef)
    var
        DimensionsTemplate: Record "Dimensions Template";
        KeyRef: KeyRef;
        FieldRef: FieldRef;
    begin
        KeyRef := RecRef.KEYINDEX(1);
        IF KeyRef.FIELDCOUNT = 1 THEN BEGIN
            FieldRef := KeyRef.FIELDINDEX(1);
            IF FORMAT(FieldRef.VALUE) <> '' THEN
                DimensionsTemplate.InsertDimensionsFromTemplates(
                  ConfigTemplateHeader, FORMAT(FieldRef.VALUE), TableID);
        END;
    end;

    local procedure IsTableErrorsExists(ConfigPackageTable: Record "Config. Package Table"): Boolean
    var
        ConfigPackageError: Record "Config. Package Error";
    begin
        IF ConfigPackageTable."Table ID" = 27 THEN BEGIN
            ConfigPackageError.SETRANGE("Package Code", ConfigPackageTable."Package Code");
            ConfigPackageError.SETRANGE("Table ID", ConfigPackageTable."Table ID");
            IF ConfigPackageError.FIND('-') THEN
                REPEAT
                    IF STRPOS(ConfigPackageError."Error Text", 'is a duplicate item number') > 0 THEN
                        EXIT(NOT ConfigPackageError.ISEMPTY);
                UNTIL ConfigPackageError.NEXT = 0;
        END
    end;

    local procedure RelatedKeyFieldValue(var ConfigPackageData: Record "Config. Package Data"; TableID: Integer; FieldNo: Integer): Text[250]
    var
        ConfigPackageDataOtherFields: Record "Config. Package Data";
        TableRelationsMetadata: Record "Table Relations Metadata";
    begin
        TableRelationsMetadata.SETRANGE("Table ID", ConfigPackageData."Table ID");
        TableRelationsMetadata.SETRANGE("Related Table ID", TableID);
        TableRelationsMetadata.SETRANGE("Related Field No.", FieldNo);
        IF TableRelationsMetadata.FINDFIRST THEN BEGIN
            ConfigPackageDataOtherFields.GET(
              ConfigPackageData."Package Code", ConfigPackageData."Table ID", ConfigPackageData."No.", TableRelationsMetadata."Field No.");
            EXIT(ConfigPackageDataOtherFields.Value);
        END;

        TableRelationsMetadata.SETRANGE("Table ID", TableID);
        TableRelationsMetadata.SETRANGE("Field No.", FieldNo);
        TableRelationsMetadata.SETRANGE("Related Table ID", ConfigPackageData."Table ID");
        TableRelationsMetadata.SETRANGE("Related Field No.");
        IF TableRelationsMetadata.FINDFIRST THEN BEGIN
            ConfigPackageDataOtherFields.GET(
              ConfigPackageData."Package Code", ConfigPackageData."Table ID",
              ConfigPackageData."No.", TableRelationsMetadata."Related Field No.");
            EXIT(ConfigPackageDataOtherFields.Value);
        END;

        EXIT(ConfigPackageData.Value);
    end;

    procedure ApplyCurrencyExchangeRates(CompanyCode: Text[30])
    var
        ExchangeRateMaster: Record "Exchange Rate Master";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        GLSetup: Record "General Ledger Setup";
        LCYCode: Code[10];
    begin
        GLSetup.ChangeCompany(CompanyCode);
        GLSetup.Get();
        LCYCode := GLSetup."LCY Code";

        ExchangeRateMaster.Reset();
        ExchangeRateMaster.SetRange("Relational Currency Code", LCYCode);
        if ExchangeRateMaster.FindSet() then
            repeat
                CurrencyExchangeRate.ChangeCompany(CompanyCode);
                CurrencyExchangeRate.Reset();
                CurrencyExchangeRate.SetRange("Starting Date", ExchangeRateMaster."Starting Date");
                CurrencyExchangeRate.SetRange("Currency Code", ExchangeRateMaster."Currency Code");
                if CurrencyExchangeRate.FindFirst() then begin
                    if CurrencyExchangeRate."Exchange Rate Amount" <> ExchangeRateMaster."Exchange Rate Amount" then
                        CurrencyExchangeRate.Validate("Exchange Rate Amount", ExchangeRateMaster."Exchange Rate Amount");
                    if CurrencyExchangeRate."Relational Exch. Rate Amount" <> ExchangeRateMaster."Relational Exch. Rate Amount" then
                        CurrencyExchangeRate.Validate("Relational Exch. Rate Amount", ExchangeRateMaster."Relational Exch. Rate Amount");
                    if CurrencyExchangeRate."Adjustment Exch. Rate Amount" <> ExchangeRateMaster."Adjustment Exch. Rate Amount" then
                        CurrencyExchangeRate.Validate("Adjustment Exch. Rate Amount", ExchangeRateMaster."Adjustment Exch. Rate Amount");
                    if CurrencyExchangeRate."Relational Adjmt Exch Rate Amt" <> ExchangeRateMaster."Relational Adjmt Exch Rate Amt" then
                        CurrencyExchangeRate.Validate("Relational Adjmt Exch Rate Amt", ExchangeRateMaster."Relational Adjmt Exch Rate Amt");
                    CurrencyExchangeRate.Modify(true);
                end
                else begin
                    CurrencyExchangeRate.ChangeCompany(CompanyCode);
                    CurrencyExchangeRate.Init();
                    CurrencyExchangeRate.TransferFields(ExchangeRateMaster);
                    CurrencyExchangeRate.Validate("Relational Currency Code", '');
                    CurrencyExchangeRate.Insert();
                end;
            until ExchangeRateMaster.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    procedure OnPreProcessPackage(var ConfigRecordForProcessing: Record "Config. Record For Processing"; var Subscriber: Variant)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnPostProcessPackage()
    begin
    end;

    procedure FunHideDialog()
    begin
        HideDialog := true;
    end;


}

