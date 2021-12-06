tableextension 50106 "G/L Entry Ext" extends "G/L Entry"
{
    fields
    {
        // Add changes to table fields here
        field(50100; "Conso. Exch. Adj."; Boolean) //G017
        {
            DataClassification = ToBeClassified;
        }
        field(50102; "Netting Source No."; Code[20])
        {
            Caption = 'Netting Source No.';
            TableRelation = IF ("Source Type" = CONST(Customer)) Customer
            ELSE
            IF ("Source Type" = CONST(Vendor)) Vendor;
        }
        field(50103; "IC Path Code"; Code[20]) //G014
        {
            DataClassification = ToBeClassified;
            TableRelation = "IC Transaction Path"."Path Code";
        }
        field(50104; "IC Source Document No."; Code[20]) //G014
        {
            DataClassification = ToBeClassified;
        }
        field(50107; "Description 2"; Text[250])
        {
        }

    }

    var
        myInt: Integer;
}