table 50104 "IC Transaction Path"
{
    DataClassification = ToBeClassified;
    DataPerCompany = false;

    fields
    {
        field(1; "Path Code"; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(2; "Description"; Text[50])
        {
            DataClassification = ToBeClassified;

        }
        field(3; "From Company"; Text[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = Company.Name;
        }
        field(4; "Account Type"; Enum "Gen. Journal Account Type")
        {
            DataClassification = ToBeClassified;
            ValuesAllowed = 0, 3;
        }
        field(5; "Account No."; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnLookup()
            var
                GLAcc2: Record "G/L Account";
                GLList2: Page "G/L Account List";
                BankAcc2: Record "Bank Account";
                BankList2: Page "Bank Account List";
            begin
                IF "Account Type" = "Account Type"::"Bank Account" then begin
                    BankAcc2.ChangeCompany("From Company");
                    BankList2.ChangeToCompany("From Company");
                    BankList2.SetTableView(BankAcc2);
                    BankList2.Editable := false;
                    BankList2.LookupMode := true;
                    if BankList2.RunModal() = Action::LookupOK then begin
                        BankList2.GetRecord(BankAcc2);
                        "Account No." := BankAcc2."No.";
                    end;
                end;

                IF "Account Type" = "Account Type"::"G/L Account" then begin
                    GLAcc2.ChangeCompany("From Company");
                    GLAcc2.SetRange("Account Type", GLAcc2."Account Type"::Posting);
                    GLAcc2.SetRange("Direct Posting", true);
                    GLList2.ChangeToCompany("From Company");
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
    }

    keys
    {
        key(Key1; "Path Code")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

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