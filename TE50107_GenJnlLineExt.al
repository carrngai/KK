tableextension 50107 "Gen. Journal Line Ext" extends "Gen. Journal Line"
{
    fields
    {
        // Add changes to table fields here
        field(50100; "Conso. Exch. Adj."; Boolean) //G017
        {
            DataClassification = ToBeClassified;

        }
        field(50101; "IC Path Code"; Code[20]) //G014
        {
            DataClassification = ToBeClassified;
            TableRelation = "IC Transaction Path"."Path Code";

            trigger OnValidate()
            begin
                InsertICAllocation(Rec);
            end;
        }
        field(50106; "Netting Source No."; Code[20])
        {
            Caption = 'Netting Source No.';
            TableRelation = Customer;
        }
        field(50107; "Description 2"; Text[250]) { }
        field(50108; "Pre-Assigned No."; Code[20]) { }
    }


    procedure CheckICPathCode(var Rec: Record "Gen. Journal Line"): Boolean
    var
        l_Cust: Record Customer;
        l_Vend: Record Vendor;
        l_ICGenJnlAlloc: Record "IC Gen. Jnl. Allocation";
    begin

        if Rec."IC Path Code" = '' then begin
            l_ICGenJnlAlloc.Reset();
            l_ICGenJnlAlloc.SetRange("Journal Template Name", Rec."Journal Template Name");
            l_ICGenJnlAlloc.SetRange("Journal Batch Name", Rec."Journal Batch Name");
            l_ICGenJnlAlloc.SetRange("Journal Line No.", "Line No.");
            if l_ICGenJnlAlloc.FindSet() then
                if Confirm('Do you want to clear IC Path Code? Exisiting Allocation will be deleted.') then
                    l_ICGenJnlAlloc.DeleteAll()
                else begin
                    Rec := xRec;
                    exit(false);
                end;
        end;

        if (Rec."IC Path Code" <> '') AND (Rec."IC Path Code" <> xRec."IC Path Code") then begin

            if (Rec."Account Type" = Rec."Account Type"::Customer) or (Rec."Account Type" = Rec."Account Type"::Vendor) then begin
                if (Rec."Account Type" = Rec."Account Type"::Customer) then begin
                    l_Cust.get(Rec."Account No.");
                    if l_Cust."IC Partner Code" = '' then begin
                        Error('Customer Account %1 is not an IC Partner', Rec."Account No.");
                        exit(false);
                    end;
                end;

                if Rec."Account Type" = Rec."Account Type"::Vendor then begin
                    l_Vend.get(Rec."Account No.");
                    if l_Vend."IC Partner Code" = '' then begin
                        Error('Vendor Account %1 is not an IC Partner', Rec."Account No.");
                        exit(false);
                    end;
                end;

                l_ICGenJnlAlloc.Reset();
                l_ICGenJnlAlloc.SetRange("Journal Template Name", Rec."Journal Template Name");
                l_ICGenJnlAlloc.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                l_ICGenJnlAlloc.SetRange("Journal Line No.", "Line No.");
                if l_ICGenJnlAlloc.FindSet() then
                    if Confirm('Do you want to change IC Path Code? Exisiting Allocation will be deleted.') then
                        l_ICGenJnlAlloc.DeleteAll()
                    else begin
                        Rec := xRec;
                        exit(false);
                    end;
                exit(true);
            end else begin
                Error('Account Type must be Customer / Vendor.');
                exit(false);
            end;
        end else
            exit(false);
    end;

    procedure InsertICDefaultLine(var Rec: Record "Gen. Journal Line")
    var
        l_ICTransPath: Record "IC Transaction Path";
        l_GenJnlLine: Record "Gen. Journal Line";
        NextLineNo: Integer;
    begin
        //Insert Sales Account in Next line    
        if l_ICTransPath.Get(Rec."IC Path Code") then begin
            l_GenJnlLine.Init();
            l_GenJnlLine."Journal Template Name" := Rec."Journal Template Name";
            l_GenJnlLine."Journal Batch Name" := Rec."Journal Batch Name";
            l_GenJnlLine."Line No." := Rec."Line No." + 10000;
            l_GenJnlLine."Posting Date" := Rec."Posting Date";
            l_GenJnlLine."Document Type" := Rec."Document Type";
            l_GenJnlLine."Document No." := Rec."Document No.";
            l_GenJnlLine.validate("Account Type", l_ICTransPath."Account Type");
            l_GenJnlLine.Validate("Account No.", l_ICTransPath."Account No.");
            l_GenJnlLine.Insert();
        end;
    end;

    procedure InsertICAllocation(var Rec: Record "Gen. Journal Line")
    var
        l_ICTransAccMapping: Record "IC Transaction Account Mapping";
        l_ICTransAccMappingDim: Record "IC Trans. Account Mapping Dim.";
        l_ICGenJnlAlloc: Record "IC Gen. Jnl. Allocation";
        NextLineNo: Integer;
        DimMgmt: Codeunit DimensionManagement;
        DimVal: Record "Dimension Value";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        l_ICTransPath: Record "IC Transaction Path";
        l_GenJnlLine: Record "Gen. Journal Line";
    begin
        //Create Allocation
        l_ICTransAccMapping.Reset();
        l_ICTransAccMapping.SetRange("Path Code", Rec."IC Path Code");
        if l_ICTransAccMapping.FindSet() then begin
            repeat
                l_ICGenJnlAlloc.Init();
                l_ICGenJnlAlloc."Journal Template Name" := Rec."Journal Template Name";
                l_ICGenJnlAlloc."Journal Batch Name" := Rec."Journal Batch Name";
                l_ICGenJnlAlloc."Journal Line No." := Rec."Line No.";
                l_ICGenJnlAlloc."Line No." := NextLineNo;
                l_ICGenJnlAlloc."IC Bal. Account Type" := l_ICTransAccMapping."Bal. Account Type";
                l_ICGenJnlAlloc."IC Bal. Account No." := l_ICTransAccMapping."Bal. Account No.";
                l_ICGenJnlAlloc.Insert();

                TempDimSetEntry.DeleteAll();
                l_ICTransAccMappingDim.Reset();
                l_ICTransAccMappingDim.SetRange(ID, l_ICTransAccMapping.ID);
                if l_ICTransAccMappingDim.FindSet() then
                    repeat
                        TempDimSetEntry.Init();
                        TempDimSetEntry."Dimension Code" := l_ICTransAccMappingDim."Dimension Code";
                        TempDimSetEntry."Dimension Value Code" := l_ICTransAccMappingDim."Dimension Value Code";
                        DimVal.Get(l_ICTransAccMappingDim."Dimension Code", l_ICTransAccMappingDim."Dimension Value Code");
                        TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
                        TempDimSetEntry.Insert();
                    until l_ICTransAccMappingDim.Next() = 0;

                l_ICGenJnlAlloc.validate("Bal. Dimension Set ID", DimMgmt.GetDimensionSetID(TempDimSetEntry));
                l_ICGenJnlAlloc.Modify();

                NextLineNo += 10000;

            until l_ICTransAccMapping.Next() = 0;
        end;
    end;

    trigger OnDelete()
    var
        ICGenJnlAlloc: Record "IC Gen. Jnl. Allocation";
    begin
        ICGenJnlAlloc.SetRange("Journal Template Name", "Journal Template Name");
        ICGenJnlAlloc.SetRange("Journal Batch Name", "Journal Batch Name");
        ICGenJnlAlloc.SetRange("Journal Line No.", "Line No.");
        if not ICGenJnlAlloc.IsEmpty() then
            ICGenJnlAlloc.DeleteAll();
    end;
}