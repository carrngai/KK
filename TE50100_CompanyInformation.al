tableextension 50100 CompanyInformationExt extends "Company Information"
{
    fields
    {
        // Add changes to table fields here
        field(50100; "Sort Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50101; "Place of Incorporation"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50102; "Date of Incorporation"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(50103; "Company Number"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50104; "B.R. Number"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50105; "Ledger Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(50106; "Remarks"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(50107; "Consolidate Company"; Text[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = Company.Name;
        }
    }

    var
        myInt: Integer;
}