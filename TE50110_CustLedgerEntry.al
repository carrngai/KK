tableextension 50110 "Cust. Ledger Entry Ext" extends "Cust. Ledger Entry"
{
    fields
    {
        // Add changes to table fields here
        field(50100; "Pre-Assigned No."; Code[20]) //Sales Journal Invoice/Cr. Memo No.
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}