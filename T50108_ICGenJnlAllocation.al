table 50108 "IC Gen. Jnl. Allocation"
{
    Caption = 'Gen. Jnl. Allocation';

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Gen. Journal Template";
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Journal Template Name"));
        }
        field(3; "Journal Line No."; Integer)
        {
            Caption = 'Journal Line No.';
            TableRelation = "Gen. Journal Line"."Line No." WHERE("Journal Template Name" = FIELD("Journal Template Name"),
                                                                  "Journal Batch Name" = FIELD("Journal Batch Name"));
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }

        field(5; Amount; Decimal)
        {
            Caption = 'Amount';

            trigger OnValidate()
            begin

            end;
        }

        field(6; "Bal. Dimension Set ID"; Integer)
        {
            Caption = 'Bal. Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions();
            end;

            trigger OnValidate()
            begin
                DimMgt.UpdateGlobalDimFromDimSetID("Bal. Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            end;
        }
        field(7; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
                Modify;
            end;
        }
        field(8; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
                Modify;
            end;
        }
    }

    keys
    {
        key(Key1; "Journal Template Name", "Journal Batch Name", "Journal Line No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        Validate(Amount, 0);
    end;

    trigger OnInsert()
    begin
        ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
        ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
    end;

    var
        Text000: Label '%1 cannot be used in allocations when they are completed on the general journal line.';
        GLAcc: Record "G/L Account";
        GenJnlLine: Record "Gen. Journal Line";
        DimMgt: Codeunit DimensionManagement;


    // procedure CreateDim(Type1: Integer; No1: Code[20])
    // var
    //     TableID: array[10] of Integer;
    //     No: array[10] of Code[20];
    // begin
    //     TableID[1] := Type1;
    //     No[1] := No1;
    //     "Shortcut Dimension 1 Code" := '';
    //     "Shortcut Dimension 2 Code" := '';
    //     "Bal. Dimension Set ID" :=
    //       DimMgt.GetRecDefaultDimID(Rec, CurrFieldNo, TableID, No, '', "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);
    // end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Bal. Dimension Set ID");
    end;

    procedure LookupShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.LookupDimValueCode(FieldNumber, ShortcutDimCode);
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Bal. Dimension Set ID");
    end;

    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
    begin
        DimMgt.GetShortcutDimensions("Bal. Dimension Set ID", ShortcutDimCode);
    end;

    procedure ShowDimensions()
    begin
        "Bal. Dimension Set ID" :=
          DimMgt.EditDimensionSet("Bal. Dimension Set ID",
            StrSubstNo('%1 %2 %3', "Journal Template Name", "Journal Batch Name", "Journal Line No."));

    end;

}

