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
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions();
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

    end;

    var
        Text000: Label '%1 cannot be used in allocations when they are completed on the general journal line.';
        GLAcc: Record "G/L Account";
        GenJnlLine: Record "Gen. Journal Line";
        GenBusPostingGrp: Record "Gen. Business Posting Group";
        GenProdPostingGrp: Record "Gen. Product Posting Group";
        DimMgt: Codeunit DimensionManagement;



    procedure ShowDimensions()
    begin
        "Bal. Dimension Set ID" :=
          DimMgt.EditDimensionSet("Bal. Dimension Set ID",
            StrSubstNo('%1 %2 %3', "Journal Template Name", "Journal Batch Name", "Journal Line No."));

    end;

}

