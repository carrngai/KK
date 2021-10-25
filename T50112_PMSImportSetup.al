table 50112 "PMS Import Setup"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "PMS Account No."; Code[20])
        {

        }
        field(2; "Instrument Type"; Text[150])
        {

        }
        field(3; "G/L Account No."; code[20])
        {
            TableRelation = "G/L Account";
        }
        field(4; "Dimension Set Id"; Integer)
        {
            TableRelation = "Dimension Set Entry";
        }
    }

    keys
    {
        key(Key1; "PMS Account No.", "Instrument Type")
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