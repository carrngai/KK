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
    }


    var
        myInt: Integer;
}