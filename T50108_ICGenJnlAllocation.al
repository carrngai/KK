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
        field(5; "IC Bal. Account Type"; Enum "Gen. Journal Account Type") //G014
        {
            DataClassification = ToBeClassified;
            ValuesAllowed = 0, 3;

            trigger OnValidate()
            begin
                if "IC Bal. Account Type" <> xRec."IC Bal. Account Type" then
                    "IC Bal. Account No." := '';
            end;
        }
        field(6; "IC Bal. Account No."; Code[20]) //G014
        {
            DataClassification = ToBeClassified;
            // TableRelation =
            // IF ("IC Bal. Account Type" = CONST("G/L Account")) "G/L Account" WHERE("Account Type" = CONST(Posting), Blocked = CONST(false), "Direct Posting" = const(true))
            // ELSE
            // IF ("IC Bal. Account Type" = CONST("Bank Account")) "Bank Account";

            trigger OnLookup()
            var
                ICPathDetail: Record "IC Transaction Path Details";
                l_GenJnlLine: Record "Gen. Journal Line";
                Company2: Code[50];
                GLAcc2: Record "G/L Account";
                GLList2: Page "G/L Account List";
                BankAcc2: Record "Bank Account";
                BankList2: Page "Bank Account List";
            begin
                l_GenJnlLine.Get("Journal Template Name", "Journal Batch Name", "Journal Line No.");

                ICPathDetail.Reset();
                ICPathDetail.SetRange("Path Code", l_GenJnlLine."IC Path Code");
                if ICPathDetail.FindLast() then
                    Company2 := ICPathDetail."To Company"
                else
                    Error('IC Path Detail not found');

                IF Rec."IC Bal. Account Type" = Rec."IC Bal. Account Type"::"Bank Account" then begin
                    BankAcc2.ChangeCompany(Company2);
                    BankList2.ChangeToCompany(Company2);
                    BankList2.SetTableView(BankAcc2);
                    BankList2.Editable := false;
                    BankList2.LookupMode := true;
                    if BankList2.RunModal() = Action::LookupOK then begin
                        BankList2.GetRecord(BankAcc2);
                        Rec."IC Bal. Account No." := BankAcc2."No.";
                    end;
                end;

                IF Rec."IC Bal. Account Type" = Rec."IC Bal. Account Type"::"G/L Account" then begin
                    GLAcc2.ChangeCompany(Company2);
                    GLAcc2.SetRange("Account Type", GLAcc2."Account Type"::Posting);
                    GLAcc2.SetRange("Direct Posting", true);
                    GLList2.ChangeToCompany(Company2);
                    GLList2.Editable := false;
                    GLList2.SetTableView(GLAcc2);
                    GLList2.LookupMode := true;
                    if GLList2.RunModal() = Action::LookupOK then begin
                        GLList2.GetRecord(GLAcc2);
                        Rec."IC Bal. Account No." := GLAcc2."No.";
                    end;
                end;
            end;

            trigger OnValidate()
            var
                ICPathDetail: Record "IC Transaction Path Details";
                l_GenJnlLine: Record "Gen. Journal Line";
                Company2: Code[50];
                GLAcc2: Record "G/L Account";
                BankAcc2: Record "Bank Account";

            begin
                l_GenJnlLine.Get("Journal Template Name", "Journal Batch Name", "Journal Line No.");

                ICPathDetail.Reset();
                ICPathDetail.SetRange("Path Code", l_GenJnlLine."IC Path Code");
                if ICPathDetail.FindLast() then
                    Company2 := ICPathDetail."To Company"
                else
                    Error('IC Path Detail not found');

                IF Rec."IC Bal. Account Type" = Rec."IC Bal. Account Type"::"Bank Account" then begin
                    BankAcc2.ChangeCompany(Company2);
                    if NOT BankAcc2.Get(Rec."IC Bal. Account No.") then
                        Error('Bank Account %1 does not exisit in Company %2', Rec."IC Bal. Account No.", Company2)
                end;

                IF Rec."IC Bal. Account Type" = Rec."IC Bal. Account Type"::"G/L Account" then begin
                    GLAcc2.ChangeCompany(Company2);
                    if NOT GLAcc2.Get(Rec."IC Bal. Account No.") then
                        Error('G/L Account %1 does not exisit in Company %2', Rec."IC Bal. Account No.", Company2);
                end;
            end;
        }
        field(7; Amount; Decimal)
        {
            Caption = 'Amount';

            trigger OnValidate()
            begin

            end;
        }

        field(8; "Bal. Dimension Set ID"; Integer)
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
        field(9; "Shortcut Dimension 1 Code"; Code[20])
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
        field(10; "Shortcut Dimension 2 Code"; Code[20])
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

