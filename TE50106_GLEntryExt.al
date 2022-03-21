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
        field(50108; "Pre-Assigned No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(50109; "Conso. Exch. Adj. Entry"; Boolean) { } //The Exchange Rate Converted Entry generated when the current exchange rate is different from the last period exchange rate
        field(50110; "Conso. Base Amount"; Decimal) { }
        field(50111; "Conso. Exchange Rate"; Decimal) { }
        field(50112; "Business Unit Name"; Text[100])
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup("Business Unit".Name where("Code" = field("Business Unit Code")));
        }
    }

    var
        myInt: Integer;
}