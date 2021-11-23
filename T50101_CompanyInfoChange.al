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

            trigger OnValidate()
            var
                l_company: Record Company;
            begin
                if l_company.Get(Company) then
                    "Company Name" := l_company."Display Name";
            end;
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
        // field(5; "Date of Reg. as non-HK company"; Date) //20211122
        field(5; "Date of Reg. as non-HK company"; Boolean)
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
        field(8; "Year-end Month"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ",JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT,NOV,DEC;
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
        field(12; "Holding Company/Investor Chg."; Boolean)
        {
            Caption = 'Holding Company/Investor Change';
            FieldClass = FlowField;
            CalcFormula = exist("Holding Company/Investor" where(Company = field("Company"), "Start Date" = field("Start Date")));
            Editable = false;
        }

        field(13; "List of Director Change"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("List of Director" where(Company = field("Company"), "Start Date" = field("Start Date")));
            Editable = false;
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