table 50100 "Tax Return"
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
        field(2; "Year End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Year of Assessment"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Tax Return Submitted"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","Yes","No","N/A";
        }
        field(5; "Tax Return Filing Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Audit Fin. Stmt. Submitted"; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Audit Financial Statement Submitted';
            OptionMembers = " ","Yes","No","N/A";
        }
        field(7; "Audit Fin. Stmt. Subm. Date"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Audit Financial Statement Submission Date';
        }
        field(8; "BIR51"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "IRC1812"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "IRC1937"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "IRC1811"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "IRC1931"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "IRC1902"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Others"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Remarks"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Company", "Year End Date")
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
        if ("Audit Fin. Stmt. Submitted" = "Audit Fin. Stmt. Submitted"::Yes) and ("Audit Fin. Stmt. Subm. Date" = 0D) then
            Error('Audit Financial Statement Submission Date must have a value');
    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}