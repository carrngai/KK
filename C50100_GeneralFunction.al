codeunit 50100 "General Function"
{
    trigger OnRun()
    begin

    end;

    //G019++
    [EventSubscriber(ObjectType::Table, 81, 'OnAfterValidateEvent', 'FA Posting Type', false, false)]
    local procedure OnAfterValidateEvent_GenJnlLine_FAPostingType(VAR Rec: Record "Gen. Journal Line"; VAR xRec: Record "Gen. Journal Line")
    var
    begin
        UpdateCashFlowDimension(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 81, 'OnAfterValidateEvent', 'Dimension Set ID', false, false)]
    local procedure OnAfterValidateEvent_GenJnlLine_DimensionSetID(VAR Rec: Record "Gen. Journal Line"; VAR xRec: Record "Gen. Journal Line")
    var
    begin
        UpdateCashFlowDimension(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 5628, 'OnAfterActionEvent', 'Dimensions', false, false)]
    local procedure OnAfterActionEvent_FAGLJournal_Dimension(var Rec: Record "Gen. Journal Line")
    begin
        Rec.Validate("Dimension Set ID");
    end;

    local procedure UpdateCashFlowDimension(VAR GenJnlLine: Record "Gen. Journal Line")
    var
        FACashFlowDimMapping: Record "FA Cash Flow Dimension Mapping";
        CashFlowDim: Code[20];
        DimSetID: Integer;
        DimSetEntry: Record "Dimension Set Entry";
        DimVal: Record "Dimension Value";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
    begin
        if (GenJnlLine."Journal Template Name" <> 'ASSETS') then
            exit;

        if DimSetEntry.Get(GenJnlLine."Dimension Set ID", 'FIXED ASSET MOVEMENT') then begin
            clear(CashFlowDim);
            if FACashFlowDimMapping.Get(GenJnlLine."FA Posting Type", DimSetEntry."Dimension Value Code") then
                CashFlowDim := FACashFlowDimMapping."Cash Flow Dimension";
            if CashFlowDim <> '' then begin
                DimMgt.GetDimensionSet(TempDimSetEntry, GenJnlLine."Dimension Set ID");
                DimVal.GET('CASH FLOW', CashFlowDim);
                TempDimSetEntry.SetRange("Dimension Code", 'CASH FLOW');
                if TempDimSetEntry.FindFirst() then begin
                    TempDimSetEntry."Dimension Value Code" := CashFlowDim;
                    TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
                    TempDimSetEntry.Modify();
                end
                else begin
                    TempDimSetEntry.Init();
                    TempDimSetEntry."Dimension Code" := 'CASH FLOW';
                    TempDimSetEntry."Dimension Value Code" := CashFlowDim;
                    TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
                    TempDimSetEntry.Insert();
                end;
                DimSetID := DimMgt.GetDimensionSetID(TempDimSetEntry);
                if DimSetID <> GenJnlLine."Dimension Set ID" then begin
                    GenJnlLine.Validate("Dimension Set ID", DimSetID);

                end;
            end;
        end;
    end;
    //G019--
}