tableextension 50101 BankAccountExt extends "Bank Account"
{
    fields
    {
        field(50100; "Sort Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}