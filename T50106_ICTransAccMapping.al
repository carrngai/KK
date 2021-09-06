table 50106 "IC Transaction Account Mapping"
{
    DataClassification = ToBeClassified;
    DataPerCompany = false;

    fields
    {
        field(1; "Path Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "IC Transaction Path"."Path Code";
        }
        field(2; "Account Type"; Enum "Gen. Journal Account Type")
        {
            DataClassification = ToBeClassified;
            ValuesAllowed = 0, 3;
        }
        field(3; "Account No."; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnLookup()
            var
                ICPath: Record "IC Transaction Path";
                Company2: Code[50];
                GLAcc2: Record "G/L Account";
                GLList2: Page "G/L Account List";
                BankAcc2: Record "Bank Account";
                BankList2: Page "Bank Account List";
            begin
                ICPath.Reset();
                ICPath.SetRange("Path Code", "Path Code");
                if ICPath.FindFirst() then
                    Company2 := ICPath."From Company"
                else
                    Error('IC Path Detail not found');

                IF "Account Type" = "Account Type"::"Bank Account" then begin
                    BankAcc2.ChangeCompany(Company2);
                    BankList2.ChangeToCompany(Company2);
                    BankList2.SetTableView(BankAcc2);
                    BankList2.Editable := false;
                    BankList2.LookupMode := true;
                    if BankList2.RunModal() = Action::LookupOK then begin
                        BankList2.GetRecord(BankAcc2);
                        "Account No." := BankAcc2."No.";
                    end;
                end;

                IF "Account Type" = "Account Type"::"G/L Account" then begin
                    GLAcc2.ChangeCompany(Company2);
                    GLAcc2.SetRange("Account Type", GLAcc2."Account Type"::Posting);
                    GLAcc2.SetRange("Direct Posting", true);
                    GLList2.ChangeToCompany(Company2);
                    GLList2.Editable := false;
                    GLList2.SetTableView(GLAcc2);
                    GLList2.LookupMode := true;
                    if GLList2.RunModal() = Action::LookupOK then begin
                        GLList2.GetRecord(GLAcc2);
                        "Account No." := GLAcc2."No.";
                    end;
                end;
            end;
        }
        field(4; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
            trigger OnLookup()
            begin
                ShowDimensions();
            end;
        }
        field(5; "Bal. Account Type"; Enum "Gen. Journal Account Type")
        {
            DataClassification = ToBeClassified;
            ValuesAllowed = 0, 3;
        }
        field(6; "Bal. Account No."; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnLookup()
            var
                ICPathDetail: Record "IC Transaction Path Details";
                Company2: Code[50];
                GLAcc2: Record "G/L Account";
                GLList2: Page "G/L Account List";
                BankAcc2: Record "Bank Account";
                BankList2: Page "Bank Account List";
            begin
                ICPathDetail.Reset();
                ICPathDetail.SetRange("Path Code", "Path Code");
                if ICPathDetail.FindLast() then
                    Company2 := ICPathDetail."To Company"
                else
                    Error('IC Path Detail not found');

                IF "Bal. Account Type" = "Bal. Account Type"::"Bank Account" then begin
                    BankAcc2.ChangeCompany(Company2);
                    BankList2.ChangeToCompany(Company2);
                    BankList2.SetTableView(BankAcc2);
                    BankList2.Editable := false;
                    BankList2.LookupMode := true;
                    if BankList2.RunModal() = Action::LookupOK then begin
                        BankList2.GetRecord(BankAcc2);
                        "Bal. Account No." := BankAcc2."No.";
                    end;
                end;

                IF "Bal. Account Type" = "Bal. Account Type"::"G/L Account" then begin
                    GLAcc2.ChangeCompany(Company2);
                    GLAcc2.SetRange("Account Type", GLAcc2."Account Type"::Posting);
                    GLAcc2.SetRange("Direct Posting", true);
                    GLList2.ChangeToCompany(Company2);
                    GLList2.Editable := false;
                    GLList2.SetTableView(GLAcc2);
                    GLList2.LookupMode := true;
                    if GLList2.RunModal() = Action::LookupOK then begin
                        GLList2.GetRecord(GLAcc2);
                        "Bal. Account No." := GLAcc2."No.";
                    end;
                end;
            end;
        }
        field(7; "Bal. Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
            trigger OnLookup()
            begin
                ShowDimensions2();
            end;
        }
        // field(8; "Elimination"; Boolean)
        // {
        //     DataClassification = ToBeClassified;
        // }
    }

    keys
    {
        key(Key1; "Path Code", "Account Type", "Account No.", "Dimension Set ID", "Bal. Account Type", "Bal. Account No.", "Bal. Dimension Set ID")
        {
            Clustered = true;
        }
    }

    var
        DimMgt: Codeunit DimensionManagement;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    procedure ShowDimensions()
    begin
        "Dimension Set ID" :=
          EditDimensionSet_Company(
            "Dimension Set ID", StrSubstNo('%1 %2 %3', 'MASTER COMPANY', "Account Type", "Account No."), 'MASTER COMPANY');
    end;

    procedure ShowDimensions2()
    begin
        "Bal. Dimension Set ID" :=
          EditDimensionSet_Company(
            "Bal. Dimension Set ID", StrSubstNo('%1 %2 %3', 'MASTER COMPANY', "Bal. Account Type", "Bal. Account No."), 'MASTER COMPANY');
    end;

    local procedure EditDimensionSet_Company(DimSetID: Integer; NewCaption: Text[250]; AtCompany: Text[30]): Integer
    var
        DimSetEntry: Record "Dimension Set Entry";
        EditDimSetEntries: Page "Edit Dimension Set Entries";
        NewDimSetID: Integer;
    begin
        DimSetEntry.ChangeCompany(AtCompany);

        NewDimSetID := DimSetID;
        DimSetEntry.Reset();
        DimSetEntry.FilterGroup(2);
        DimSetEntry.SetRange("Dimension Set ID", DimSetID);
        DimSetEntry.FilterGroup(0);
        EditDimSetEntries.SetTableView(DimSetEntry);
        EditDimSetEntries.SetFormCaption(NewCaption);
        EditDimSetEntries.RunModal();
        NewDimSetID := GetDimensionSetID_Company(DimSetEntry, AtCompany);
        exit(NewDimSetID);
    end;

    local procedure GetDimensionSetID_Company(var DimSetEntry: Record "Dimension Set Entry"; AtCompany: Text[30]): Integer
    var
        DimSetEntry2: Record "Dimension Set Entry";
        DimSetTreeNode: Record "Dimension Set Tree Node";
        Found: Boolean;
    begin
        DimSetEntry2.ChangeCompany(AtCompany);
        DimSetTreeNode.ChangeCompany(AtCompany);

        DimSetEntry2.Copy(DimSetEntry);

        if DimSetEntry."Dimension Set ID" > 0 then
            DimSetEntry.SetRange("Dimension Set ID", DimSetEntry."Dimension Set ID");

        DimSetEntry.SetCurrentKey("Dimension Value ID");
        DimSetEntry.SetFilter("Dimension Code", '<>%1', '');
        DimSetEntry.SetFilter("Dimension Value Code", '<>%1', '');

        if not DimSetEntry.FindSet then begin
            DimSetEntry.Copy(DimSetEntry2);
            exit(0);
        end;

        Found := true;
        DimSetTreeNode."Dimension Set ID" := 0;
        repeat
            DimSetEntry.TestField("Dimension Value ID");
            if Found then
                if not DimSetTreeNode.Get(DimSetTreeNode."Dimension Set ID", DimSetEntry."Dimension Value ID") then begin
                    Found := false;
                    DimSetTreeNode.LockTable();
                end;

            if not Found then begin
                DimSetTreeNode."Parent Dimension Set ID" := DimSetTreeNode."Dimension Set ID";
                DimSetTreeNode."Dimension Value ID" := DimSetEntry."Dimension Value ID";
                DimSetTreeNode."Dimension Set ID" := 0;
                DimSetTreeNode."In Use" := false;
                if not DimSetTreeNode.Insert(true) then
                    DimSetTreeNode.Get(DimSetTreeNode."Parent Dimension Set ID", DimSetTreeNode."Dimension Value ID");
            end;
        until DimSetEntry.Next() = 0;
        if not DimSetTreeNode."In Use" then begin
            if Found then begin
                DimSetTreeNode.LockTable();
                DimSetTreeNode.Get(DimSetTreeNode."Parent Dimension Set ID", DimSetTreeNode."Dimension Value ID");
            end;
            DimSetTreeNode."In Use" := true;
            DimSetTreeNode.Modify();
            InsertDimSetEntries_Company(DimSetEntry, DimSetTreeNode."Dimension Set ID", AtCompany);
        end;

        DimSetEntry.Copy(DimSetEntry2);

        exit(DimSetTreeNode."Dimension Set ID");
    end;

    local procedure InsertDimSetEntries_Company(var DimSetEntry: Record "Dimension Set Entry"; NewID: Integer; AtCompany: Text[30])
    var
        DimSetEntry2: Record "Dimension Set Entry";
    begin
        DimSetEntry2.ChangeCompany(AtCompany);
        DimSetEntry2.LockTable();
        if DimSetEntry.FindSet then
            repeat
                DimSetEntry2 := DimSetEntry;
                DimSetEntry2."Dimension Set ID" := NewID;
                DimSetEntry2."Global Dimension No." := DimSetEntry2.GetGlobalDimNo();
                DimSetEntry2.Insert();
            until DimSetEntry.Next() = 0;
    end;

}