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


    //G0017++
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitGLEntry', '', true, true)]
    local procedure OnAfterInitGLEntry(var GLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        GLEntry."Conso. Exch. Adj." := GenJournalLine."Conso. Exch. Adj."
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::Consolidate,'OnBeforeGenJnlPostLine', '', true, true)]
    // local procedure OnBeforeGenJnlPostLine_InsertExchAdj(var GenJnlLine: Record "Gen. Journal Line")
    // var
    //     BU: Record "Business Unit";
    //     ConsoGLAcc: Record "G/L Account";
    //     BU_GLAcc: Record "G/L Account";    
    //     OpeningExchRateAdj: Decimal;   
    // begin
    //     clear(OpeningExchRateAdj);

    //     BU.Reset();
    //     if BU.FindSet() then begin
    //         repeat
    //             ConsoGLAcc.Reset();
    //             ConsoGLAcc.SetRange("Business Unit Filter", BU.Code);
    //             ConsoGLAcc.SetRange("Income/Balance", ConsoGLAcc."Income/Balance"::"Balance Sheet");
    //             ConsoGLAcc.SetRange("Consol. Translation Method",ConsoGLAcc."Consol. Translation Method"::"Average Rate (Manual)");
    //             ConsoGLAcc.CalcFields("Balance at Date");
    //             if ConsoGLAcc.FindSet() then 
    //             begin
    //                 BU_GLAcc.Reset();
    //                 BU_GLAcc.ChangeCompany(BU."Company Name");
    //                 BU_GLAcc.SetRange("No.", ConsoGLAcc."No.");
    //                 if BU_GLAcc.FindFirst() then begin
    //                     BU_GLAcc.CalcFields("Balance at Date");
    //                     OpeningExchRateAdj := ((BU_GLAcc."Balance at Date" * BU."Income Currency Factor") - ConsoGLAcc."Balance at Date");
    //                     Message(Format(OpeningExchRateAdj));
    //                     if OpeningExchRateAdj <> 0 then begin
    //                         GenJnlLine.Init();
    //                         GenJnlLine."Business Unit Code" := BU.Code;
    //                         GenJnlLine."Document No." := 'EXCHADJ';
    //                         GenJnlLine."Account No." := ConsoGLAcc."No.";
    //                         GenJnlLine.Amount := OpeningExchRateAdj;
    //                         GenJnlLine.Insert();                            
    //                     end;
    //                 end;
    //             end;
    //         until BU.Next()=0;
    //     end;    
    // end;

    //G0017--
}