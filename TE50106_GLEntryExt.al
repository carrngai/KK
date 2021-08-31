tableextension 50106 "G/L Entry Ext" extends "G/L Entry"
{
    fields
    {
        // Add changes to table fields here
        field(50100; "Conso. Exch. Adj."; Boolean) //G017
        {
            DataClassification = ToBeClassified;
        }

        // field(50101; "Netting Source Type"; Enum "Gen. Journal Source Type")
        // {
        //     DataClassification = ToBeClassified;
        // }
        field(50102; "Netting Source No."; Code[20])
        {
            Caption = 'Netting Source No.';
            TableRelation = IF ("Source Type" = CONST(Customer)) Customer
            ELSE
            IF ("Source Type" = CONST(Vendor)) Vendor;
        }
        field(50107; "Description 2"; Text[250])
        {

        }
    }

    var
        myInt: Integer;
}