tableextension 50107 "Gen. Journal Line Ext" extends "Gen. Journal Line"
{
    fields
    {
        // Add changes to table fields here
        field(50100; "Conso. Exch. Adj."; Boolean) //G017
        {
            DataClassification = ToBeClassified;

        }
        field(50102; "Netting Source No."; Code[20])
        {
            Caption = 'Netting Source No.';
            TableRelation = Customer;
        }
        field(50103; "IC Path Code"; Code[20]) //G014
        {
            DataClassification = ToBeClassified;
            TableRelation = "IC Transaction Path"."Path Code";

            trigger OnValidate()
            begin
                InsertICAllocation(Rec);
            end;
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
        l_GenJnlLine2: Record "Gen. Journal Line";
    begin
        //Insert Sales Account in Next line    
        if l_ICTransPath.Get(Rec."IC Path Code") then begin
            l_GenJnlLine.Init();
            l_GenJnlLine."Journal Template Name" := Rec."Journal Template Name";
            l_GenJnlLine."Journal Batch Name" := Rec."Journal Batch Name";

            l_GenJnlLine2.Reset();
            l_GenJnlLine2.SetRange("Journal Template Name", Rec."Journal Template Name");
            l_GenJnlLine2.SetRange("Journal Batch Name", Rec."Journal Batch Name");
            l_GenJnlLine2.SetFilter("Line No.", '%1..', Rec."Line No." + 1);
            if l_GenJnlLine2.FindFirst() then
                l_GenJnlLine."Line No." := (Rec."Line No." + l_GenJnlLine2."Line No.") div 2
            else
                l_GenJnlLine."Line No." := Rec."Line No." + 10000;

            l_GenJnlLine."Posting Date" := Rec."Posting Date";
            l_GenJnlLine."Document Type" := Rec."Document Type";
            l_GenJnlLine."Document No." := Rec."Document No.";
            l_GenJnlLine."Posting No. Series" := Rec."Posting No. Series"; //20211129
            l_GenJnlLine.validate("Account Type", l_ICTransPath."Account Type");
            l_GenJnlLine.Validate("Account No.", l_ICTransPath."Account No.");

            if (l_GenJnlLine2."Document No." = Rec."Document No.") and (l_GenJnlLine2."Account No." <> l_ICTransPath."Account No.") then
                l_GenJnlLine.Insert()
            else
                if (l_GenJnlLine2."Document No." <> Rec."Document No.") then
                    l_GenJnlLine.Insert();

        end;
    end;

    procedure InsertICAllocation(var Rec: Record "Gen. Journal Line")
    var
        l_ICTransAccMapping: Record "IC Transaction Account Mapping";
        l_ICTransDefaultDim: Record "IC Trans. Default Dim.";
        l_ICGenJnlAlloc: Record "IC Gen. Jnl. Allocation";
        NextLineNo: Integer;
        DimMgmt: Codeunit DimensionManagement;
        DimVal: Record "Dimension Value";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        l_ICTransPath: Record "IC Transaction Path";
        l_GenJnlLine: Record "Gen. Journal Line";
        LineCount: Integer;
    begin
        //Create Allocation
        l_ICTransAccMapping.Reset();
        l_ICTransAccMapping.SetRange("Path Code", Rec."IC Path Code");
        if l_ICTransAccMapping.FindSet() then begin

            LineCount := l_ICTransAccMapping.Count;

            repeat
                l_ICGenJnlAlloc.Init();
                l_ICGenJnlAlloc."Journal Template Name" := Rec."Journal Template Name";
                l_ICGenJnlAlloc."Journal Batch Name" := Rec."Journal Batch Name";
                l_ICGenJnlAlloc."Journal Line No." := Rec."Line No.";
                l_ICGenJnlAlloc."Line No." := NextLineNo;
                l_ICGenJnlAlloc."IC Bal. Account Type" := l_ICTransAccMapping."Bal. Account Type";
                l_ICGenJnlAlloc."IC Bal. Account No." := l_ICTransAccMapping."Bal. Account No.";
                if LineCount = 1 then
                    l_ICGenJnlAlloc.Amount := Rec.Amount;
                l_ICGenJnlAlloc.Insert();

                TempDimSetEntry.DeleteAll();
                l_ICTransDefaultDim.Reset();
                l_ICTransDefaultDim.SetRange("Table ID", Database::"IC Transaction Account Mapping");
                l_ICTransDefaultDim.SetRange("Key 1", '');
                l_ICTransDefaultDim.SetRange("Key 2", l_ICTransAccMapping.ID);
                l_ICTransDefaultDim.SetRange(Type, l_ICTransDefaultDim.Type::"Bal. Dimension");
                if l_ICTransDefaultDim.FindSet() then
                    repeat
                        TempDimSetEntry.Init();
                        TempDimSetEntry."Dimension Code" := l_ICTransDefaultDim."Dimension Code";
                        TempDimSetEntry."Dimension Value Code" := l_ICTransDefaultDim."Dimension Value Code";
                        DimVal.Get(l_ICTransDefaultDim."Dimension Code", l_ICTransDefaultDim."Dimension Value Code");
                        TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
                        TempDimSetEntry.Insert();
                    until l_ICTransDefaultDim.Next() = 0;

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