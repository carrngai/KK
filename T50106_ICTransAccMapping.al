table 50106 "IC Transaction Account Mapping"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Path Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "IC Transaction Path"."Path Code";
        }
        field(2; "Account Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "G/L Account","Bank Account";
        }
        field(3; "Account No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation =
            IF ("Account Type" = CONST("G/L Account")) "G/L Account" WHERE("Account Type" = CONST(Posting), Blocked = CONST(false))
            ELSE
            IF ("Account Type" = CONST("Bank Account")) "Bank Account";
        }
        field(4; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
        field(5; "Bal. Account Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "G/L Account","Bank Account";
        }
        field(6; "Bal. Account No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation =
            IF ("Account Type" = CONST("G/L Account")) "G/L Account" WHERE("Account Type" = CONST(Posting), Blocked = CONST(false))
            ELSE
            IF ("Account Type" = CONST("Bank Account")) "Bank Account";
        }
        field(7; "Bal. Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
        field(8; "Elimination"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Path Code", "Account Type", "Account No.", "Dimension Set ID", "Bal. Account Type", "Bal. Account No.", "Bal. Dimension Set ID")
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

    procedure ShowDimensions()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        if IsHandled then
            exit;

        "Dimension Set ID" :=
          DimMgt.EditDimensionSet(
            "Dimension Set ID", StrSubstNo('%1 %2', "Account Type", "Account No."));
    end;

    procedure ShowDimensions2()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        if IsHandled then
            exit;

        "Bal. Dimension Set ID" :=
          DimMgt.EditDimensionSet(
            "Bal. Dimension Set ID", StrSubstNo('%1 %2', "Bal. Account Type", "Bal. Account No."));
    end;

}