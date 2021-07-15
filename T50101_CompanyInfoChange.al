table 50101 "Company Information Change"
{
    DataClassification = ToBeClassified;
    DataPerCompany = false;

    fields
    {
        field(1; "Company"; Text[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = Company.Name;
        }
        field(2; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Company Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Former Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Date of Reg. as non-HK company"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Date of Registration as non-HK company under CO';
        }
        field(6; "Company Secretary"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Business Nature"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Year-end Date"; Text[10])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Auditor"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Tax representative"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "IRD File Number"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; Company, "Start Date")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}