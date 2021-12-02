table 50105 "IC Transaction Path Details"
{
    DataClassification = ToBeClassified;
    DataPerCompany = false;

    fields
    {
        field(1; "Path Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "IC Transaction Path"."Path Code";

        }
        field(2; "Sequence"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "To Company"; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = Company.Name;
        }
    }

    keys
    {
        key(Key1; "Path Code", Sequence)
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
    var
        ICTransDefaultDim: Record "IC Trans. Default Dim.";
    begin
        ICTransDefaultDim.SetRange("Table ID", Database::"IC Transaction Path Details");
        ICTransDefaultDim.SetRange("Key 1", "Path Code");
        ICTransDefaultDim.SetRange("Key 2", Sequence);
        ICTransDefaultDim.DeleteAll(true);
    end;

    trigger OnRename()
    begin

    end;

}