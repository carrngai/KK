tableextension 50103 VendBankAccountExt extends "Vendor Bank Account"
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