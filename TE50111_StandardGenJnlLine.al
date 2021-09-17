tableextension 50111 "Stand. Gen. Jnl. Line Ext" extends "Standard General Journal Line"
{
    fields
    {
        // Add changes to table fields here
        field(50103; "IC Path Code"; Code[20]) //G014
        {
            DataClassification = ToBeClassified;
            TableRelation = "IC Transaction Path"."Path Code";
        }
    }

    var
        myInt: Integer;
}