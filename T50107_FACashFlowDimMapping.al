table 50107 "FA Cash Flow Dimension Mapping"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "FA Posting Type"; Enum "Gen. Journal Line FA Posting Type")
        {
            Caption = 'FA Posting Type';
        }

        field(2; "FA Movement Dimension"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code where("Dimension Code" = const('FIXEDASSETMOVEMENT'));
        }

        field(3; "Cash Flow Dimension"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code where("Dimension Code" = const('CASHFLOW'));
        }
    }

    keys
    {
        key(Key1; "FA Posting Type", "FA Movement Dimension")
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