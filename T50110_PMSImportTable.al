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

        }
        field(3; "Account Number"; Code[20])
        {

        }
        field(4; "Account Description"; Text[150])
        {

        }
        field(5; Description; Text[150])
        {

        }
        field(6; "Base Amount"; Decimal)
        {

        }
        field(7; "Native Amount"; Decimal)
        {

        }
        field(8; "Currency"; Code[10])
        {

        }
        field(9; "Entry Memo"; Text[150])
        {
        }
        field(10; "GL Name"; Text[150])
        {

        }
        field(11; "Entry Source"; Text[150])
        {

        }
        field(12; "GL Entry Id"; code[20])
        {

        }
        field(13; "GL Distribution Line"; code[20])
        {

        }
        field(14; "ISIN"; Text[150])
        {

        }
        field(15; "BB Yellow Key"; Text[150])
        {

        }
        field(16; "Custodian Account Display Name"; Text[150])
        {

        }
        field(17; "Custodian"; Text[150])
        {

        }
        field(18; Status; Enum "PMS Import Status")
        {

        }
        field(19; "Row No."; Integer)
        {

        }
        field(20; "File Name"; Text[250])
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