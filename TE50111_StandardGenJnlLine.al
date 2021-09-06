tableextension 50111 "Stand. Gen. Jnl. Line Ext" extends "Standard General Journal Line"
{
    fields
    {
        // Add changes to table fields here
        field(50101; "IC Path Code"; Code[20]) //G014
        {
            DataClassification = ToBeClassified;
            TableRelation = "IC Transaction Path"."Path Code";

            trigger OnLookup()
            var
                ICPath: Record "IC Transaction Path";
                ICPath_: Page "IC Transaction Path";
            begin
                ICPath.SetFilter("From Company", CompanyName);
                ICPath_.SetTableView(ICPath);
                ICPath_.LookupMode := true;
                if ICPath_.RunModal() = Action::LookupOK then begin
                    ICPath_.GetRecord(ICPath);

                    if ICPath."Path Code" <> xRec."IC Path Code" then
                        "IC Bal. Account No." := '';

                    "IC Path Code" := ICPath."Path Code";
                end;
            end;

            trigger OnValidate()
            begin
                if "IC Path Code" <> xRec."IC Path Code" then
                    "IC Bal. Account No." := '';
            end;
        }
        field(50102; "IC Bal. Account Type"; Enum "Gen. Journal Account Type") //G014
        {
            DataClassification = ToBeClassified;
            ValuesAllowed = 0, 3;

            trigger OnValidate()
            begin
                if "IC Bal. Account Type" <> xRec."IC Bal. Account Type" then
                    "IC Bal. Account No." := '';
            end;
        }
        field(50103; "IC Bal. Account No."; Code[20]) //G014
        {
            DataClassification = ToBeClassified;
            TableRelation =
            IF ("IC Bal. Account Type" = CONST("G/L Account")) "G/L Account" WHERE("Account Type" = CONST(Posting), Blocked = CONST(false), "Direct Posting" = const(true))
            ELSE
            IF ("IC Bal. Account Type" = CONST("Bank Account")) "Bank Account";

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
                ICPathDetail.SetRange("Path Code", "IC Path Code");
                if ICPathDetail.FindLast() then
                    Company2 := ICPathDetail."To Company"
                else
                    Error('IC Path Detail not found');

                IF "IC Bal. Account Type" = "IC Bal. Account Type"::"Bank Account" then begin
                    BankAcc2.ChangeCompany(Company2);
                    BankList2.ChangeToCompany(Company2);
                    BankList2.SetTableView(BankAcc2);
                    BankList2.Editable := false;
                    BankList2.LookupMode := true;
                    if BankList2.RunModal() = Action::LookupOK then begin
                        BankList2.GetRecord(BankAcc2);
                        "IC Bal. Account No." := BankAcc2."No.";
                    end;
                end;

                IF "IC Bal. Account Type" = "IC Bal. Account Type"::"G/L Account" then begin
                    GLAcc2.ChangeCompany(Company2);
                    GLAcc2.SetRange("Account Type", GLAcc2."Account Type"::Posting);
                    GLAcc2.SetRange("Direct Posting", true);
                    GLList2.ChangeToCompany(Company2);
                    GLList2.Editable := false;
                    GLList2.SetTableView(GLAcc2);
                    GLList2.LookupMode := true;
                    if GLList2.RunModal() = Action::LookupOK then begin
                        GLList2.GetRecord(GLAcc2);
                        "IC Bal. Account No." := GLAcc2."No.";
                    end;
                end;
            end;
        }
    }

    var
        myInt: Integer;
}