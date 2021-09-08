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

            trigger OnLookup()
            var
                ICPath: Record "IC Transaction Path";
                ICPath_: Page "IC Transaction Path";
            begin
                ICPath.SetFilter("From Company", CompanyName);
                ICPath_.SetTableView(ICPath);
                ICPath_.LookupMode := true;
                if ICPath_.RunModal() = Action::LookupOK then begin
                    ICPath_.GetRecord(ICPath);
                    "IC Path Code" := ICPath."Path Code";
                    CreateJnlAllocation;
                end;
            end;

            trigger OnValidate()
            begin
                CreateJnlAllocation;
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

    local procedure CreateJnlAllocation()
    var
        l_Cust: Record Customer;
        l_Vend: Record Vendor;
        l_ICTransAccMapping: Record "IC Transaction Account Mapping";
        l_ICTransAccMappingDim: Record "IC Trans. Account Mapping Dim.";
        l_ICGenJnlAlloc: Record "IC Gen. Jnl. Allocation";
        NextLineNo: Integer;
        DimMgmt: Codeunit DimensionManagement;
        DimVal: Record "Dimension Value";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        if Rec."Account Type" = Rec."Account Type"::Customer then begin
            l_Cust.get(Rec."Account No.");
            if l_Cust."IC Partner Code" = '' then Error('Customer Account %1 is not an IC Partner', Rec."Account No.");
        end;
        if Rec."Account Type" = Rec."Account Type"::Vendor then begin
            l_Vend.get(Rec."Account No.");
            if l_Vend."IC Partner Code" = '' then Error('Vendor Account %1 is not an IC Partner', Rec."Account No.");
        end;

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
                    exit;
                end;
        end;

        if (Rec."IC Path Code" <> '') AND (Rec."IC Path Code" <> xRec."IC Path Code") then begin

            l_ICGenJnlAlloc.Reset();
            l_ICGenJnlAlloc.SetRange("Journal Template Name", Rec."Journal Template Name");
            l_ICGenJnlAlloc.SetRange("Journal Batch Name", Rec."Journal Batch Name");
            l_ICGenJnlAlloc.SetRange("Journal Line No.", "Line No.");
            if l_ICGenJnlAlloc.FindSet() then
                if Confirm('Do you want to change IC Path Code? Exisiting Allocation will be deleted.') then
                    l_ICGenJnlAlloc.DeleteAll()
                else begin
                    Rec := xRec;
                    exit;
                end;
        end;

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
}