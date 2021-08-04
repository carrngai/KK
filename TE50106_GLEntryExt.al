tableextension 50106 "G/L Entry Ext" extends "G/L Entry"
{
    fields
    {
        // Add changes to table fields here
        field(50100; "Conso. Exch. Adj."; Boolean) //G017
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}