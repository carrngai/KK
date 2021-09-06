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
        field(8; ID; Integer)
        {
            AutoIncrement = true;
            Caption = 'ID';
            NotBlank = true;
        }
    }

    keys
    {
        key(Key1; ID)
        {
            Clustered = true;
        }
        key(Key2; "Path Code", "Account Type", "Account No.", "Bal. Account Type", "Bal. Account No.")
        {
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

}