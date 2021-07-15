tableextension 50102 CustBankAccountExt extends "Customer Bank Account"
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