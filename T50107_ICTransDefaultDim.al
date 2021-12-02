table 50107 "IC Trans. Default Dim."
{
    DataClassification = ToBeClassified;
    DataPerCompany = false;

    fields
    {

        field(50100; "Table ID"; Integer)
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(50101; "Key 1"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50102; "Key 2"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(50103; Type; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Dimension,"Bal. Dimension";
        }
        field(50104; "Dimension Code"; Code[20])
        {
            Caption = 'Dimension Code';
            NotBlank = true;
            TableRelation = Dimension;

            trigger OnValidate()
            begin
                CheckDimension("Dimension Code");
                if "Dimension Code" <> xRec."Dimension Code" then
                    Validate("Dimension Value Code", '');
            end;
        }
        field(50105; "Dimension Value Code"; Code[20])
        {
            Caption = 'Dimension Value Code';
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = FIELD("Dimension Code"));

            trigger OnValidate()
            begin
                CheckDimensionValue("Dimension Code", "Dimension Value Code");
            end;
        }
    }

    keys
    {
        key(Key1; "Table ID", "Key 1", "Key 2", "Type", "Dimension Code")
        {
            Clustered = true;
        }
    }

    var
        DimMgt: Codeunit DimensionManagement;

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

    local procedure CheckDimension(DimensionCode: Code[20])
    begin
        if not DimMgt.CheckDim(DimensionCode) then
            Error(DimMgt.GetDimErr);
    end;

    local procedure CheckDimensionValue(DimensionCode: Code[20]; DimensionValueCode: Code[20])
    begin
        if not DimMgt.CheckDimValue(DimensionCode, DimensionValueCode) then
            Error(DimMgt.GetDimErr);
    end;
}