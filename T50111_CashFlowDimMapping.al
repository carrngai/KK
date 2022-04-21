table 50111 "Cash Flow Dimension Mapping"
{
    //20200422 G019 Map CF Movement to CF Nature

    DataClassification = ToBeClassified;

    fields
    {
        // field(1; "FA Posting Type"; Enum "Gen. Journal Line FA Posting Type")
        // {
        //     Caption = 'FA Posting Type';
        // }

        field(2; "CF Movement Dimension"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code where("Dimension Code" = const('CASH FLOW MOVEMENT'));
        }

        field(3; "CF Nature Dimension"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code where("Dimension Code" = const('CASH FLOW NATURE'));
        }
    }

    keys
    {
        key(Key1; "CF Movement Dimension")
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