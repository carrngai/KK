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

    //G017++
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitGLEntry', '', true, true)]
    local procedure OnAfterInitGLEntry(var GLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        GLEntry."Conso. Exch. Adj." := GenJournalLine."Conso. Exch. Adj."
    end;
    //G017--

    //G014++
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnAfterProcessLines', '', true, true)]
    local procedure OnAfterCode(var TempGenJournalLine: Record "Gen. Journal Line" temporary)
    var
        ICTransMapping: Record "IC Transaction Account Mapping";
        ICTransPathD: Record "IC Transaction Path Details";
        DimMgt: Codeunit DimensionManagement;
        DimVal: Record "Dimension Value";
        DimSetEntry: Record "Dimension Set Entry";
        tempDimSetEntry: Record "Dimension Set Entry" temporary;
        tempDimSetEntry2: Record "Dimension Set Entry" temporary;
        NoOfSeq: Integer;
        ICGenJnlLine: Record "Gen. Journal Line";
        FromCompany: Code[50];
        NextLineNo: Integer;
        ICPartner: Record "IC Partner";
        ICAllocation: Record "IC Gen. Jnl. Allocation";
    begin
        FromCompany := CompanyName;
        with TempGenJournalLine do begin
            SetCurrentKey("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");
            Find('-');
            repeat
                if (TempGenJournalLine."IC Path Code" <> '') then begin
                    ICTransPathD.Reset();
                    ICTransPathD.SetRange("Path Code", TempGenJournalLine."IC Path Code");
                    if ICTransPathD.FindSet() then begin
                        NoOfSeq := ICTransPathD.Count;
                        repeat
                            if ICTransPathD.Sequence = NoOfSeq then begin
                                ICPartner.ChangeCompany(ICTransPathD."To Company");
                                ICPartner.SetRange("Inbox Details", FromCompany);
                                if ICPartner.FindFirst() then begin
                                    //Get Line No.
                                    ICGenJnlLine.ChangeCompany(ICTransPathD."To Company");
                                    ICGenJnlLine.SetRange("Journal Template Name", 'GENERAL');
                                    ICGenJnlLine.SetRange("Journal Batch Name", 'DEFAULT');
                                    if ICGenJnlLine.FindLast() then
                                        NextLineNo := ICGenJnlLine."Line No." + 10000
                                    else
                                        NextLineNo := 10000;

                                    //First Line
                                    ICGenJnlLine.Init();
                                    ICGenJnlLine."Journal Template Name" := 'GENERAL';
                                    ICGenJnlLine."Journal Batch Name" := 'DEFAULT';
                                    ICGenJnlLine."Line No." := NextLineNo;
                                    ICGenJnlLine."Posting Date" := TempGenJournalLine."Posting Date";
                                    ICGenJnlLine."External Document No." := TempGenJournalLine."Document No.";
                                    ICGenJnlLine."Account Type" := TempGenJournalLine."Account Type"::Vendor;
                                    ICGenJnlLine."Account No." := ICPartner."Vendor No.";
                                    ICGenJnlLine."Currency Code" := TempGenJournalLine."Currency Code";
                                    ICGenJnlLine."Currency Factor" := TempGenJournalLine."Currency Factor";

                                    ICGenJnlLine.Insert();

                                    ICGenJnlLine.Validate(Amount, -TempGenJournalLine.Amount);

                                    // DimVal.Get('ELIMINATION', 'TRUE');
                                    // DimMgt.GetDimensionSet(tempDimSetEntry, TempGenJournalLine."Dimension Set ID");
                                    // TempDimSetEntry.Init();
                                    // TempDimSetEntry."Dimension Code" := 'ELIMINATION';
                                    // TempDimSetEntry."Dimension Value Code" := 'TRUE';
                                    // TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
                                    // TempDimSetEntry.Insert();
                                    // tempDimSetEntry2.ChangeCompany(ICTransPathD."To Company");
                                    // tempDimSetEntry2 := tempDimSetEntry;
                                    // ICGenJnlLine.Validate("Dimension Set ID", DimMgt.GetDimensionSetID(TempDimSetEntry2));

                                    ICGenJnlLine.Modify();

                                    //Allocation Line         
                                    ICAllocation.Reset();
                                    ICAllocation.SetRange("Journal Template Name", TempGenJournalLine."Journal Template Name");
                                    ICAllocation.SetRange("Journal Batch Name", TempGenJournalLine."Journal Batch Name");
                                    ICAllocation.SetRange("Journal Line No.", TempGenJournalLine."Line No.");
                                    if ICAllocation.FindSet() then begin
                                        repeat
                                            NextLineNo := ICGenJnlLine."Line No." + 10000;
                                            ICGenJnlLine.Init();
                                            ICGenJnlLine."Journal Template Name" := 'GENERAL';
                                            ICGenJnlLine."Journal Batch Name" := 'DEFAULT';
                                            ICGenJnlLine."Line No." := NextLineNo;
                                            ICGenJnlLine."Posting Date" := TempGenJournalLine."Posting Date";
                                            ICGenJnlLine."External Document No." := TempGenJournalLine."Document No.";
                                            ICGenJnlLine."Account Type" := TempGenJournalLine."IC Bal. Account Type";
                                            ICGenJnlLine."Account No." := TempGenJournalLine."IC Bal. Account No.";
                                            ICGenJnlLine."Currency Code" := TempGenJournalLine."Currency Code";
                                            ICGenJnlLine."Currency Factor" := TempGenJournalLine."Currency Factor";
                                            ICGenJnlLine.Insert();
                                            ICGenJnlLine.Validate(Amount, ICAllocation.Amount);
                                            //ICGenJnlLine.validate("Dimension Set ID", ICAllocation."Bal. Dimension Set ID");
                                            //need to add elimintaion dimenison
                                            // ICTransMapping.Reset();
                                            // ICTransMapping.SetRange("Path Code",GenJnlLine."IC Path Code");
                                            // ICTransMapping.SetRange("Account Type", GenJnlLine."Account Type");
                                            // ICTransMapping.SetRange("Account No.", GenJnlLine."Account No.");
                                            // ICTransMapping.SetRange("Dimension Set ID", GenJnlLine."Dimension Set ID");    
                                            // ICTransMapping.SetRange("Bal. Dimension Set ID",ICAllocation."Bal. Dimension Set ID");
                                            // if ICTransMapping.FindFirst() then begin
                                            // end;  
                                            ICGenJnlLine.Modify();

                                        until ICAllocation.Next() = 0;
                                    end;
                                    //need to delet IC allocation
                                end;
                            end
                            else begin

                            end;

                        until ICTransPathD.Next() = 0;

                    end;
                end;
            until Next() = 0;
        end;
    end;
    //G014--

}