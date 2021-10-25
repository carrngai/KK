table 50113 "PMS Import Log"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
        }
        field(2; "User ID"; Code[20])
        {
            TableRelation = User;
        }
        field(3; "Start Date Time"; DateTime)
        {
        }
        field(4; "End Date Time"; DateTime)
        {
        }
        field(5; "Job"; Code[20])
        {
        }
        field(6; "Status"; Enum "PMS Import Log Status")
        {
        }
        field(7; "Description"; Text[50])
        {
        }
        field(8; "Line No."; Integer)
        {
        }
        field(9; "Error Message"; Text[250])
        {
        }
        field(10; "Error Message 2"; Text[250])
        {
        }
        field(11; "Error Message 3"; Text[250])
        {
        }
        field(12; "Error Message 4"; Text[250])
        {
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }


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