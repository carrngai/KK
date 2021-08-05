tableextension 50107 "Gen. Journal Line Ext" extends "Gen. Journal Line"
{
    fields
    {
        // Add changes to table fields here
        field(50100; "Conso. Exch. Adj."; Boolean) //G017
        {
            DataClassification = ToBeClassified;
        }
        field(50101; "IC Path Code"; Code[20]) //G014
        {
            DataClassification = ToBeClassified;
            TableRelation = "IC Transaction Path"."Path Code";
        }
        field(50102; "IC Bal. Account Type"; Enum "Gen. Journal Account Type") //G014
        {
            DataClassification = ToBeClassified;
            ValuesAllowed = 0, 3;
        }
        field(50103; "IC Bal. Account No."; Code[20]) //G014
        {
            DataClassification = ToBeClassified;
            TableRelation =
            IF ("Account Type" = CONST("G/L Account")) "G/L Account" WHERE("Account Type" = CONST(Posting), Blocked = CONST(false))
            ELSE
            IF ("Account Type" = CONST("Bank Account")) "Bank Account";
        }
    }

    var
        myInt: Integer;
}