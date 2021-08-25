table 50110 PMSImportTable
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {

        }
        field(2; "Transaction Date"; Date)
        {
            DataClassification = ToBeClassified;

        }
        field(3; "Account Number"; Text[20])
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