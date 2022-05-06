codeunit 50100 "General Function"
{
    Permissions = TableData "Dimension Set Entry" = rim, //G014
                  TableData "Dimension Set Tree Node" = rim, //G014
                  tabledata "G/L Entry" = rim;

    trigger OnRun()
    begin

    end;

    //G019++ 
    //20200422 Map CF Movement to CF Nature
    //Edit in Dimension Set Entry
    [EventSubscriber(ObjectType::Table, 480, 'OnBeforeGetDimensionSetID', '', false, false)]
    local procedure OnBeforeGetDimensionSetID(var DimensionSetEntry: Record "Dimension Set Entry")
    var
        CashFlowDimMapping: Record "Cash Flow Dimension Mapping";
        CashFlowNatureDim: Code[20];
        DimVal: Record "Dimension Value";
    begin
        //Get Current Dimension Set Entry
        if DimensionSetEntry.Get(DimensionSetEntry."Dimension Set ID", 'CASH FLOW MOVEMENT') then begin

            //Find Any Mapping for selected CF Movement
            if CashFlowDimMapping.Get(DimensionSetEntry."Dimension Value Code") then
                CashFlowNatureDim := CashFlowDimMapping."CF Nature Dimension";

            if CashFlowNatureDim <> '' then begin
                //Delete current CF Nature
                if DimensionSetEntry.Get(DimensionSetEntry."Dimension Set ID", 'CASH FLOW NATURE') then
                    if DimensionSetEntry."Dimension Value Code" <> CashFlowNatureDim then
                        DimensionSetEntry.Delete();
                //Insert CF Nature 
                DimVal.Get('CASH FLOW NATURE', CashFlowNatureDim);
                DimensionSetEntry.Init();
                DimensionSetEntry."Dimension Set ID" := DimensionSetEntry."Dimension Set ID";
                DimensionSetEntry."Dimension Code" := DimVal."Dimension Code";
                DimensionSetEntry."Dimension Value Code" := DimVal.Code;
                DimensionSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
                if DimensionSetEntry.Insert() then;
            end;
        end;
    end;

    //Edit in Journal Shortcut Dimension
    [EventSubscriber(ObjectType::Codeunit, Codeunit::DimensionManagement, 'OnAfterValidateShortcutDimValues', '', false, false)]
    local procedure OnAfterValidateShortcutDimValues(FieldNumber: Integer; var ShortcutDimCode: Code[20]; var DimSetID: Integer)
    var
        DimMgt: Codeunit DimensionManagement;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        CashFlowDimMapping: Record "Cash Flow Dimension Mapping";
        CashFlowNatureDim: Code[20];
        DimVal: Record "Dimension Value";
    begin
        //Get Current Dimension Set Entry
        DimMgt.GetDimensionSet(TempDimSetEntry, DimSetID);
        if TempDimSetEntry.Get(TempDimSetEntry."Dimension Set ID", 'CASH FLOW MOVEMENT') then begin

            //Find Any Mapping for selected CF Movement
            if CashFlowDimMapping.Get(TempDimSetEntry."Dimension Value Code") then
                CashFlowNatureDim := CashFlowDimMapping."CF Nature Dimension";

            if CashFlowNatureDim <> '' then begin
                //Delete current CF Nature
                if TempDimSetEntry.Get(TempDimSetEntry."Dimension Set ID", 'CASH FLOW NATURE') then
                    if TempDimSetEntry."Dimension Value Code" <> CashFlowNatureDim then
                        TempDimSetEntry.Delete();
                //Insert CF Nature 
                DimVal.Get('CASH FLOW NATURE', CashFlowNatureDim);
                TempDimSetEntry.Init();
                TempDimSetEntry."Dimension Code" := DimVal."Dimension Code";
                TempDimSetEntry."Dimension Value Code" := DimVal.Code;
                TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
                if TempDimSetEntry.Insert() then;

                DimSetID := DimMgt.GetDimensionSetID(TempDimSetEntry);
            end;
        end;
    end;

    //Update Shortcut Dimension 7 CASH FLOW NATURE on Journal Page
    [EventSubscriber(ObjectType::Page, Page::"General Journal", 'OnAfterValidateShortcutDimCode', '', false, false)]
    local procedure OnAfterValidateShortcutDimCode_GJ(var GenJournalLine: Record "Gen. Journal Line"; var ShortcutDimCode: array[8] of Code[20]; DimIndex: Integer)
    var
        DimMgt: Codeunit DimensionManagement;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        DimMgt.GetDimensionSet(TempDimSetEntry, GenJournalLine."Dimension Set ID");
        if TempDimSetEntry.Get(TempDimSetEntry."Dimension Set ID", 'CASH FLOW NATURE') then begin
            ShortcutDimCode[7] := TempDimSetEntry."Dimension Value Code";
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Journal", 'OnAfterValidateShortcutDimCode', '', false, false)]
    local procedure OnAfterValidateShortcutDimCode_SJ(var GenJournalLine: Record "Gen. Journal Line"; var ShortcutDimCode: array[8] of Code[20]; DimIndex: Integer)
    var
        DimMgt: Codeunit DimensionManagement;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        DimMgt.GetDimensionSet(TempDimSetEntry, GenJournalLine."Dimension Set ID");
        if TempDimSetEntry.Get(TempDimSetEntry."Dimension Set ID", 'CASH FLOW NATURE') then begin
            ShortcutDimCode[7] := TempDimSetEntry."Dimension Value Code";
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Journal", 'OnAfterValidateShortcutDimCode', '', false, false)]
    local procedure OnAfterValidateShortcutDimCode_PJ(var GenJournalLine: Record "Gen. Journal Line"; var ShortcutDimCode: array[8] of Code[20]; DimIndex: Integer)
    var
        DimMgt: Codeunit DimensionManagement;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        DimMgt.GetDimensionSet(TempDimSetEntry, GenJournalLine."Dimension Set ID");
        if TempDimSetEntry.Get(TempDimSetEntry."Dimension Set ID", 'CASH FLOW NATURE') then begin
            ShortcutDimCode[7] := TempDimSetEntry."Dimension Value Code";
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Cash Receipt Journal", 'OnAfterValidateShortcutDimCode', '', false, false)]
    local procedure OnAfterValidateShortcutDimCode_CRJ(var GenJournalLine: Record "Gen. Journal Line"; var ShortcutDimCode: array[8] of Code[20]; DimIndex: Integer)
    var
        DimMgt: Codeunit DimensionManagement;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        DimMgt.GetDimensionSet(TempDimSetEntry, GenJournalLine."Dimension Set ID");
        if TempDimSetEntry.Get(TempDimSetEntry."Dimension Set ID", 'CASH FLOW NATURE') then begin
            ShortcutDimCode[7] := TempDimSetEntry."Dimension Value Code";
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Payment Journal", 'OnAfterValidateShortcutDimCode', '', false, false)]
    local procedure OnAfterValidateShortcutDimCode_VPJ(var GenJournalLine: Record "Gen. Journal Line"; var ShortcutDimCode: array[8] of Code[20]; DimIndex: Integer)
    var
        DimMgt: Codeunit DimensionManagement;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        DimMgt.GetDimensionSet(TempDimSetEntry, GenJournalLine."Dimension Set ID");
        if TempDimSetEntry.Get(TempDimSetEntry."Dimension Set ID", 'CASH FLOW NATURE') then begin
            ShortcutDimCode[7] := TempDimSetEntry."Dimension Value Code";
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Fixed Asset G/L Journal", 'OnAfterValidateShortcutDimCode', '', false, false)]
    local procedure OnAfterValidateShortcutDimCode_FAGL(var GenJournalLine: Record "Gen. Journal Line"; var ShortcutDimCode: array[8] of Code[20]; DimIndex: Integer)
    var
        DimMgt: Codeunit DimensionManagement;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        DimMgt.GetDimensionSet(TempDimSetEntry, GenJournalLine."Dimension Set ID");
        if TempDimSetEntry.Get(TempDimSetEntry."Dimension Set ID", 'CASH FLOW NATURE') then begin
            ShortcutDimCode[7] := TempDimSetEntry."Dimension Value Code";
        end;
    end;
    //G019--

    //G017++
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitGLEntry', '', true, true)]
    local procedure OnAfterInitGLEntry_NewFieldsMapping(var GLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        GLEntry."Conso. Exch. Adj." := GenJournalLine."Conso. Exch. Adj."; //G017
        GLEntry."Netting Source No." := GenJournalLine."Netting Source No."; //G025
        GLEntry."IC Path Code" := GenJournalLine."IC Path Code"; //G014
        GLEntry."IC Source Document No." := GenJournalLine."IC Source Document No."; //G014
        GLEntry."IC Source Company" := GenJournalLine."IC Source Company"; //G014
        GLEntry."Pre-Assigned No." := GenJournalLine."Pre-Assigned No."; //G014
        GLEntry."Description 2" := GenJournalLine."Description 2";
        GLEntry."Conso. Base Amount" := GenJournalLine."Conso. Base Amount";
        GLEntry."Conso. Exch. Adj. Entry" := GenJournalLine."Conso. Exch. Adj. Entry";
        GLEntry."Conso. Exchange Rate" := GenJournalLine."Conso. Exchange Rate";
    end;
    //G017--

    //Carry Invoice/Cr. Memo No. to CLE++
    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeModifyEvent', '', true, true)] //cannot update from RenumberDocNo
    local procedure OnBeforeModifyEvent_InvNotoCLE(var REC: Record "Gen. Journal Line"; xRec: record "Gen. Journal Line"; RunTrigger: Boolean)
    begin
        REC."Pre-Assigned No." := REC."Document No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeRenumberDocNoOnLines', '', true, true)]
    local procedure OnBeforeRenumberDocNoOnLines(var DocNo: Code[20]; var GenJnlLine2: Record "Gen. Journal Line"; var IsHandled: Boolean)
    begin
        with GenJnlLine2 do begin
            GenJnlLine2."Pre-Assigned No." := DocNo;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitCustLedgEntry', '', true, true)]
    local procedure OnAfterInitCustLedgEntry_InvNotoCLE(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        if (GenJournalLine."Document Type" = GenJournalLine."Document Type"::Invoice) OR (GenJournalLine."Document Type" = GenJournalLine."Document Type"::"Credit Memo") then
            CustLedgerEntry."Pre-Assigned No." := GenJournalLine."Pre-Assigned No.";
    end;
    //Carry Invoice/Cr. Memo No. to CLE--

    //G014++
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnBeforeProcessLines', '', true, true)]
    local procedure OnBeforeProcessLines_CheckICTrans(var GenJournalLine: Record "Gen. Journal Line"; PreviewMode: Boolean; CommitIsSuppressed: Boolean)
    var
        ICAllocation: Record "IC Gen. Jnl. Allocation";
        TotalAllocatedAmt: Decimal;
        ICTransPath: Record "IC Transaction Path";
        ICTransPathDetail: Record "IC Transaction Path Details";
        ICTransPathDetail2: Record "IC Transaction Path Details";
        l_GenJnlLine: Record "Gen. Journal Line";
        FromCompany: Code[50];
        AtCompany: Code[50];
        NextCompany: Code[50];
        ICPartner: Record "IC Partner";
        DimMgt: Codeunit DimensionManagement;
        DimVal: Record "Dimension Value";
        tempDimSetEntry1: Record "Dimension Set Entry" temporary;
        ICTransDefaultDim: Record "IC Trans. Default Dim.";

    begin
        with GenJournalLine do begin
            SetCurrentKey("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");
            Find('-');
            repeat
                if (GenJournalLine."IC Path Code" <> '') then begin
                    // //Check Document Type
                    // if (GenJournalLine."Document Type" <> GenJournalLine."Document Type"::Invoice) AND (GenJournalLine."Document Type" <> GenJournalLine."Document Type"::"Credit Memo") then
                    //     Error('Line No. %1 : Document Type must be Invoice or Credit Memo', GenJournalLine."Line No.");

                    //Check Allocated Amount
                    TotalAllocatedAmt := 0;
                    ICAllocation.Reset();
                    ICAllocation.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
                    ICAllocation.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
                    ICAllocation.SetRange("Journal Line No.", GenJournalLine."Line No.");
                    if ICAllocation.FindSet() then begin
                        repeat
                            TotalAllocatedAmt := TotalAllocatedAmt + ICAllocation.Amount;
                        until ICAllocation.Next() = 0;
                        if TotalAllocatedAmt <> GenJournalLine.Amount then
                            Error('Line No. %1 : Allocated Amount(%2) is not equal to Journal Line Amount(%3).', GenJournalLine."Line No.", TotalAllocatedAmt, GenJournalLine.Amount);
                    end;

                    //Check Dimension same as setup
                    tempDimSetEntry1.DeleteAll();
                    DimMgt.GetDimensionSet(tempDimSetEntry1, GenJournalLine."Dimension Set ID");
                    ICTransDefaultDim.Reset();
                    ICTransDefaultDim.SetRange("Table ID", Database::"IC Transaction Path");
                    ICTransDefaultDim.SetRange("Key 1", GenJournalLine."IC Path Code");
                    ICTransDefaultDim.SetRange("Key 2", 0);
                    ICTransDefaultDim.SetRange(Type, ICTransDefaultDim.Type::"Dimension");
                    if ICTransDefaultDim.FindSet() then
                        repeat
                            tempDimSetEntry1.Reset();
                            tempDimSetEntry1.SetRange("Dimension Code", ICTransDefaultDim."Dimension Code");
                            tempDimSetEntry1.SetRange("Dimension Value Code", ICTransDefaultDim."Dimension Value Code");
                            if not tempDimSetEntry1.FindSet() then
                                Error('Line No. %1 : Dimension %2 and Dimension Value %3 must be selected.', GenJournalLine."Line No.", ICTransDefaultDim."Dimension Code", ICTransDefaultDim."Dimension Value Code");
                        until ICTransDefaultDim.Next() = 0;

                    //Check Bal. Account and Dimension same as setup
                    ICTransPath.Get(GenJournalLine."IC Path Code");
                    l_GenJnlLine.Reset();
                    l_GenJnlLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
                    l_GenJnlLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
                    l_GenJnlLine.SetRange("Document No.", GenJournalLine."Document No.");
                    l_GenJnlLine.SetRange("Account Type", ICTransPath."Bal. Account Type");
                    l_GenJnlLine.SetRange("Account No.", ICTransPath."Bal. Account No.");
                    if l_GenJnlLine.FindFirst() then begin
                        tempDimSetEntry1.DeleteAll();
                        DimMgt.GetDimensionSet(tempDimSetEntry1, l_GenJnlLine."Dimension Set ID");
                        ICTransDefaultDim.Reset();
                        ICTransDefaultDim.SetRange("Table ID", Database::"IC Transaction Path");
                        ICTransDefaultDim.SetRange("Key 1", GenJournalLine."IC Path Code");
                        ICTransDefaultDim.SetRange("Key 2", 0);
                        ICTransDefaultDim.SetRange(Type, ICTransDefaultDim.Type::"Bal. Dimension");
                        if ICTransDefaultDim.FindSet() then
                            repeat
                                tempDimSetEntry1.Reset();
                                tempDimSetEntry1.SetRange("Dimension Code", ICTransDefaultDim."Dimension Code");
                                tempDimSetEntry1.SetRange("Dimension Value Code", ICTransDefaultDim."Dimension Value Code");
                                if not tempDimSetEntry1.FindSet() then
                                    Error('Line No. %1 : Dimension %2 and Dimension Value %3 must be selected.', l_GenJnlLine."Line No.", ICTransDefaultDim."Dimension Code", ICTransDefaultDim."Dimension Value Code");
                            until ICTransDefaultDim.Next() = 0;
                    end else
                        Error('Document No. %1: %2 %3 must be the balance account for IC Path %4', GenJournalLine."Document No.", ICTransPath."Bal. Account Type", ICTransPath."Bal. Account No.", GenJournalLine."IC Path Code");

                    //Check IC Partner Setup Exists
                    FromCompany := ICTransPath."From Company";
                    ICTransPathDetail.Reset();
                    ICTransPathDetail.SetRange("Path Code", ICTransPath."Path Code");
                    if ICTransPathDetail.FindSet() then begin
                        repeat
                            AtCompany := ICTransPathDetail."To Company";

                            //From Company
                            ICPartner.ChangeCompany(AtCompany);
                            ICPartner.SetRange("Inbox Details", FromCompany);
                            if not ICPartner.FindFirst() then
                                Error('IC Partner Setup does not exist for %1 in Company %2', FromCompany, AtCompany)
                            else
                                if (ICPartner."Vendor No." = '') or (ICPartner."Customer No." = '') then
                                    Error('Vendor No. /Customer No. in IC Partner Setup for %1 in Company %2 cannot be blank', FromCompany, AtCompany);

                            //To Company
                            ICTransPathDetail2.CopyFilters(ICTransPathDetail);
                            ICTransPathDetail2.SetFilter(Sequence, '%1..', ICTransPathDetail.Sequence + 1);
                            if ICTransPathDetail2.FindFirst() then begin
                                NextCompany := ICTransPathDetail2."To Company";
                                ICPartner.SetRange("Inbox Details", NextCompany);
                                if not ICPartner.FindFirst() then
                                    Error('IC Partner Setup does not exist for %1 in Company %2', NextCompany, AtCompany)
                                else
                                    if (ICPartner."Vendor No." = '') or (ICPartner."Customer No." = '') then
                                        Error('Vendor No. /Customer No. in IC Partner Setup for %1 in Company %2 cannot be blank', NextCompany, AtCompany);
                            end;

                            FromCompany := AtCompany;
                        until ICTransPathDetail.Next() = 0;

                    end else
                        Error('IC Transaction Path Detail does not exist for IC Transaction Path %1.', ICTransPath."Path Code");

                    //Check Allocation Dimension Value Exists in Last IC Partner
                    // ICTransPathDetail.Reset();
                    // ICTransPathDetail.SetRange("Path Code", ICTransPath."Path Code");
                    // if ICTransPathDetail.FindLast() then begin
                    //     ICAllocation.Reset();
                    //     ICAllocation.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
                    //     ICAllocation.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
                    //     ICAllocation.SetRange("Journal Line No.", GenJournalLine."Line No.");
                    //     if ICAllocation.FindSet() then begin
                    //         repeat
                    //             tempDimSetEntry1.DeleteAll();
                    //             DimMgt.GetDimensionSet(tempDimSetEntry1, ICAllocation."Bal. Dimension Set ID");
                    //             if tempDimSetEntry1.FindSet() then
                    //                 repeat
                    //                     DimVal.ChangeCompany(AtCompany);
                    //                     if not DimVal.Get(tempDimSetEntry1."Dimension Code", tempDimSetEntry1."Dimension Value Code") then
                    //                         Error('Dimension %1 Dimension Value %2 not found in %3', tempDimSetEntry1."Dimension Code", tempDimSetEntry1."Dimension Value Code", AtCompany);
                    //                 until tempDimSetEntry1.Next() = 0;
                    //         until ICAllocation.Next() = 0;
                    //     end;
                    // end;

                end;
            until Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnAfterProcessLines', '', true, true)]
    local procedure OnAfterProcessLines_CreateICTrans(var TempGenJournalLine: Record "Gen. Journal Line" temporary)
    var
        ICTransPathDetail: Record "IC Transaction Path Details";
        ICTransPathDetail2: Record "IC Transaction Path Details";
        ICAllocation: Record "IC Gen. Jnl. Allocation";
        ICTransMapping: Record "IC Transaction Account Mapping";
        ICPartner: Record "IC Partner";
        AtCompany: Code[50];
        FromCompany: Code[50];
        NextCompany: Code[50];
        ICEliminate: Boolean;
        l_ICTransDefaultDim: Record "IC Trans. Default Dim.";
        DimMgt: Codeunit DimensionManagement;
        DimVal: Record "Dimension Value";
        tempDimSetEntry1: Record "Dimension Set Entry" temporary;
        GenJnlLine_AtCompany: Record "Gen. Journal Line";
        LastDocNo: Code[20];
    begin
        FromCompany := CompanyName;
        with TempGenJournalLine do begin

            SetCurrentKey("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");
            Find('-');
            repeat
                if (TempGenJournalLine."IC Path Code" <> '') then begin
                    LastDocNo := TempGenJournalLine."Document No.";
                    ICTransPathDetail.Reset();
                    ICTransPathDetail.SetRange("Path Code", TempGenJournalLine."IC Path Code");
                    if ICTransPathDetail.FindSet() then begin
                        repeat
                            AtCompany := ICTransPathDetail."To Company";

                            ICTransPathDetail2.CopyFilters(ICTransPathDetail);
                            ICTransPathDetail2.SetFilter(Sequence, '%1..', ICTransPathDetail.Sequence + 1);
                            if ICTransPathDetail2.FindFirst() then begin
                                NextCompany := ICTransPathDetail2."To Company";
                                //If there is NextCompenay >> IC ARAP
                                //IC_Line1
                                ICPartner.ChangeCompany(AtCompany);
                                ICPartner.SetRange("Inbox Details", FromCompany);
                                if ICPartner.FindFirst() then begin
                                    //get IC Trasn. Default Dimension set ID
                                    TempDimSetEntry1.DeleteAll();
                                    l_ICTransDefaultDim.Reset();
                                    l_ICTransDefaultDim.SetRange("Table ID", Database::"IC Transaction Path Details");
                                    l_ICTransDefaultDim.SetRange("Key 1", ICTransPathDetail."Path Code");
                                    l_ICTransDefaultDim.SetRange("Key 2", ICTransPathDetail.Sequence);
                                    l_ICTransDefaultDim.SetRange(Type, l_ICTransDefaultDim.Type::"Dimension");
                                    if l_ICTransDefaultDim.FindSet() then
                                        repeat
                                            DimVal.Get(l_ICTransDefaultDim."Dimension Code", l_ICTransDefaultDim."Dimension Value Code");
                                            TempDimSetEntry1.Init();
                                            TempDimSetEntry1."Dimension Code" := DimVal."Dimension Code";
                                            TempDimSetEntry1."Dimension Value Code" := DimVal.Code;
                                            TempDimSetEntry1."Dimension Value ID" := DimVal."Dimension Value ID";
                                            TempDimSetEntry1."Global Dimension No." := DimVal."Global Dimension No.";
                                            if TempDimSetEntry1.Insert() then;
                                        until l_ICTransDefaultDim.Next() = 0;

                                    if TempGenJournalLine."Account Type" = TempGenJournalLine."Account Type"::Customer then
                                        InsertGenJnlLine_Company(TempGenJournalLine, TempGenJournalLine."Account Type"::Vendor, ICPartner."Vendor No.", -TempGenJournalLine.Amount, DimMgt.GetDimensionSetID(tempDimSetEntry1), false, true, LastDocNo, AtCompany)
                                    else
                                        InsertGenJnlLine_Company(TempGenJournalLine, TempGenJournalLine."Account Type"::Customer, ICPartner."Customer No.", -TempGenJournalLine.Amount, DimMgt.GetDimensionSetID(tempDimSetEntry1), false, true, LastDocNo, AtCompany);
                                end;
                                //IC_Line2
                                ICPartner.SetRange("Inbox Details", NextCompany);
                                if ICPartner.FindFirst() then begin
                                    //get IC Trasn. Default Dimension set ID
                                    TempDimSetEntry1.DeleteAll();
                                    l_ICTransDefaultDim.Reset();
                                    l_ICTransDefaultDim.SetRange("Table ID", Database::"IC Transaction Path Details");
                                    l_ICTransDefaultDim.SetRange("Key 1", ICTransPathDetail."Path Code");
                                    l_ICTransDefaultDim.SetRange("Key 2", ICTransPathDetail.Sequence);
                                    l_ICTransDefaultDim.SetRange(Type, l_ICTransDefaultDim.Type::"Bal. Dimension");
                                    if l_ICTransDefaultDim.FindSet() then
                                        repeat
                                            DimVal.Get(l_ICTransDefaultDim."Dimension Code", l_ICTransDefaultDim."Dimension Value Code");
                                            TempDimSetEntry1.Init();
                                            TempDimSetEntry1."Dimension Code" := DimVal."Dimension Code";
                                            TempDimSetEntry1."Dimension Value Code" := DimVal.Code;
                                            TempDimSetEntry1."Dimension Value ID" := DimVal."Dimension Value ID";
                                            TempDimSetEntry1."Global Dimension No." := DimVal."Global Dimension No.";
                                            if TempDimSetEntry1.Insert() then;
                                        until l_ICTransDefaultDim.Next() = 0;

                                    if TempGenJournalLine."Account Type" = TempGenJournalLine."Account Type"::Customer then
                                        InsertGenJnlLine_Company(TempGenJournalLine, TempGenJournalLine."Account Type"::Customer, ICPartner."Customer No.", TempGenJournalLine.Amount, DimMgt.GetDimensionSetID(tempDimSetEntry1), false, false, LastDocNo, AtCompany)
                                    else
                                        InsertGenJnlLine_Company(TempGenJournalLine, TempGenJournalLine."Account Type"::Vendor, ICPartner."Vendor No.", TempGenJournalLine.Amount, DimMgt.GetDimensionSetID(tempDimSetEntry1), false, false, LastDocNo, AtCompany);
                                end;

                                //Update Document No., Schedule Post
                                LastDocNo := EnqueueGenJrnlLine_Company(TempGenJournalLine, AtCompany, true);

                                FromCompany := AtCompany;

                            end else begin
                                //If there is NO NextCompenay >>Last Line
                                //Last IC_Line1
                                ICPartner.ChangeCompany(AtCompany);
                                ICPartner.SetRange("Inbox Details", FromCompany);
                                if ICPartner.FindFirst() then begin
                                    //get IC Trasn. Default Dimension set ID
                                    TempDimSetEntry1.DeleteAll();
                                    l_ICTransDefaultDim.Reset();
                                    l_ICTransDefaultDim.SetRange("Table ID", Database::"IC Transaction Path Details");
                                    l_ICTransDefaultDim.SetRange("Key 1", ICTransPathDetail."Path Code");
                                    l_ICTransDefaultDim.SetRange("Key 2", ICTransPathDetail.Sequence);
                                    l_ICTransDefaultDim.SetRange(Type, l_ICTransDefaultDim.Type::"Dimension");
                                    if l_ICTransDefaultDim.FindSet() then
                                        repeat
                                            DimVal.Get(l_ICTransDefaultDim."Dimension Code", l_ICTransDefaultDim."Dimension Value Code");
                                            TempDimSetEntry1.Init();
                                            TempDimSetEntry1."Dimension Code" := DimVal."Dimension Code";
                                            TempDimSetEntry1."Dimension Value Code" := DimVal.Code;
                                            TempDimSetEntry1."Dimension Value ID" := DimVal."Dimension Value ID";
                                            TempDimSetEntry1."Global Dimension No." := DimVal."Global Dimension No.";
                                            if TempDimSetEntry1.Insert() then;
                                        until l_ICTransDefaultDim.Next() = 0;

                                    if TempGenJournalLine."Account Type" = TempGenJournalLine."Account Type"::Customer then
                                        InsertGenJnlLine_Company(TempGenJournalLine, TempGenJournalLine."Account Type"::Vendor, ICPartner."Vendor No.", -TempGenJournalLine.Amount, DimMgt.GetDimensionSetID(tempDimSetEntry1), false, true, LastDocNo, AtCompany)
                                    else
                                        InsertGenJnlLine_Company(TempGenJournalLine, TempGenJournalLine."Account Type"::Customer, ICPartner."Customer No.", -TempGenJournalLine.Amount, DimMgt.GetDimensionSetID(tempDimSetEntry1), false, true, LastDocNo, AtCompany);
                                end;

                                //Last IC_Allocation Line         
                                ICAllocation.Reset();
                                ICAllocation.SetRange("Journal Template Name", TempGenJournalLine."Journal Template Name");
                                ICAllocation.SetRange("Journal Batch Name", TempGenJournalLine."Journal Batch Name");
                                ICAllocation.SetRange("Journal Line No.", TempGenJournalLine."Line No.");
                                if ICAllocation.FindSet() then begin
                                    repeat
                                        InsertGenJnlLine_Company(TempGenJournalLine, ICAllocation."IC Bal. Account Type", ICAllocation."IC Bal. Account No.", ICAllocation.Amount, ICAllocation."Bal. Dimension Set ID", false, false, LastDocNo, AtCompany);
                                    until ICAllocation.Next() = 0;
                                    ICAllocation.DeleteAll();
                                end;

                                //Update Document No. , not schedule post
                                LastDocNo := EnqueueGenJrnlLine_Company(TempGenJournalLine, AtCompany, false);

                                // Message('IC Entries all set');
                            end;

                        until ICTransPathDetail.Next() = 0;
                    end;
                end;
            until Next() = 0;
        end;
    end;

    local procedure InsertGenJnlLine_Company(var SourceGenJnLine: Record "Gen. Journal Line"; AccType: Enum "Gen. Journal Account Type"; AccNo: Code[20]; LineAmount: decimal; DimSetID: integer; ELIMINATION: boolean; NewDoc: Boolean; LastDocNo: code[20]; AtCompany: Text[30])
    var
        ICGenBatch: Record "Gen. Journal Batch";
        ICGenJnlLine: Record "Gen. Journal Line";
        NextLineNo: Integer;
        DimVal: Record "Dimension Value";
        TempDimSetEntry1: Record "Dimension Set Entry" temporary;
        TempDimSetEntry2: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
        DefaultDim: Record "Default Dimension";
        GLSetup1: Record "General Ledger Setup";
        GLSetup2: Record "General Ledger Setup";
        CurrExchRate2: Record "Currency Exchange Rate";
    // NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        ICGenBatch.ChangeCompany(AtCompany);
        ICGenJnlLine.ChangeCompany(AtCompany);
        TempDimSetEntry2.ChangeCompany(AtCompany);
        DefaultDim.ChangeCompany(AtCompany);
        DimVal.ChangeCompany(AtCompany);
        GLSetup2.ChangeCompany(AtCompany);
        CurrExchRate2.ChangeCompany(AtCompany);

        GLSetup1.Get();
        GLSetup2.Get();

        CASE SourceGenJnLine."Document Type" OF
            SourceGenJnLine."Document Type"::Invoice:
                begin
                    ICGenBatch.Reset();
                    ICGenBatch.SetRange("Journal Template Name", 'GENERAL');
                    ICGenBatch.SetRange(Name, 'IC-INV');
                    if not ICGenBatch.FindSet() then begin
                        ICGenBatch.Init();
                        ICGenBatch."Journal Template Name" := 'GENERAL';
                        ICGenBatch.Name := 'IC-INV';
                        ICGenBatch."No. Series" := 'S-INV';
                        ICGenBatch."Posting No. Series" := 'GJNL-GEN';
                        ICGenBatch.Insert();
                    end;
                    ICGenJnlLine.Reset();
                    ICGenJnlLine.SetRange("Journal Template Name", 'GENERAL');
                    ICGenJnlLine.SetRange("Journal Batch Name", 'IC-INV');
                    if ICGenJnlLine.FindLast() then
                        NextLineNo := ICGenJnlLine."Line No." + 10000
                    else
                        NextLineNo := 10000;
                end;

            SourceGenJnLine."Document Type"::"Credit Memo":
                begin
                    ICGenBatch.Reset();
                    ICGenBatch.SetRange("Journal Template Name", 'GENERAL');
                    ICGenBatch.SetRange(Name, 'IC-CR');
                    if not ICGenBatch.FindSet() then begin
                        ICGenBatch.Init();
                        ICGenBatch."Journal Template Name" := 'GENERAL';
                        ICGenBatch.Name := 'IC-CR';
                        ICGenBatch."No. Series" := 'S-CR';
                        ICGenBatch."Posting No. Series" := 'GJNL-GEN';
                        ICGenBatch.Insert();
                    end;
                    ICGenJnlLine.Reset();
                    ICGenJnlLine.SetRange("Journal Template Name", 'GENERAL');
                    ICGenJnlLine.SetRange("Journal Batch Name", 'IC-CR');
                    if ICGenJnlLine.FindLast() then
                        NextLineNo := ICGenJnlLine."Line No." + 10000
                    else
                        NextLineNo := 10000;
                end;

            ELSE //Repayment
                begin
                    ICGenBatch.Reset();
                    ICGenBatch.SetRange("Journal Template Name", 'GENERAL');
                    ICGenBatch.SetRange(Name, 'IC-JV');
                    if not ICGenBatch.FindSet() then begin
                        ICGenBatch.Init();
                        ICGenBatch."Journal Template Name" := 'GENERAL';
                        ICGenBatch.Name := 'IC-JV';
                        ICGenBatch."No. Series" := '';
                        ICGenBatch."Posting No. Series" := 'GJNL-GEN';
                        ICGenBatch.Insert();
                    end;
                    ICGenJnlLine.Reset();
                    ICGenJnlLine.SetRange("Journal Template Name", 'GENERAL');
                    ICGenJnlLine.SetRange("Journal Batch Name", 'IC-JV');
                    if ICGenJnlLine.FindLast() then
                        NextLineNo := ICGenJnlLine."Line No." + 10000
                    else
                        NextLineNo := 10000;
                end;
        END;

        ICGenJnlLine.Init();
        ICGenJnlLine."Journal Template Name" := 'GENERAL';
        IF SourceGenJnLine."Document Type" = SourceGenJnLine."Document Type"::Invoice then
            ICGenJnlLine."Journal Batch Name" := 'IC-INV'
        else
            if SourceGenJnLine."Document Type" = SourceGenJnLine."Document Type"::"Credit Memo" then
                ICGenJnlLine."Journal Batch Name" := 'IC-CR'
            else //Repayment
                ICGenJnlLine."Journal Batch Name" := 'IC-JV';

        ICGenJnlLine."Line No." := NextLineNo;
        ICGenJnlLine."IC Source Document No." := SourceGenJnLine."Document No.";
        ICGenJnlLine."IC Source Company" := CompanyName();
        ICGenJnlLine."Posting Date" := SourceGenJnLine."Posting Date";
        ICGenJnlLine."Document Type" := SourceGenJnLine."Document Type";
        ICGenJnlLine."Document No." := SourceGenJnLine."Document No.";
        ICGenJnlLine."External Document No." := LastDocNo;
        ICGenJnlLine."Posting No. Series" := ICGenBatch."Posting No. Series";
        // ICGenJnlLine."Print Posted Documents" := true;
        ICGenJnlLine.Insert();
        ICGenJnlLine."Account Type" := AccType;
        ICGenJnlLine."Account No." := AccNo;
        ICGenJnlLine.Description := SourceGenJnLine.Description;
        ICGenJnlLine."Source Code" := SourceGenJnLine."Source Code";
        if GLSetup1."LCY Code" = GLSetup2."LCY Code" then begin
            ICGenJnlLine."Currency Code" := SourceGenJnLine."Currency Code";
            ICGenJnlLine."Currency Factor" := SourceGenJnLine."Currency Factor";
            ICGenJnlLine.Validate(Amount, LineAmount);
        end else begin
            ICGenJnlLine."Currency Code" := SourceGenJnLine."Currency Code";
            CurrExchRate2.Reset();
            CurrExchRate2.SetRange("Currency Code", SourceGenJnLine."Currency Code");
            CurrExchRate2.SetRange("Starting Date", 0D, SourceGenJnLine."Posting Date");
            if CurrExchRate2.FindLast() then
                if CurrExchRate2."Relational Currency Code" = '' then
                    ICGenJnlLine."Currency Factor" := CurrExchRate2."Exchange Rate Amount" / CurrExchRate2."Relational Exch. Rate Amount";
            ICGenJnlLine.Validate(Amount, LineAmount);
        end;

        //Line Dimension
        //1. From Master Default Dimension
        DefaultDim.Reset();
        case AccType of
            AccType::"G/L Account":
                DefaultDim.SetRange("Table ID", 15);
            AccType::Customer:
                DefaultDim.SetRange("Table ID", 18);
            AccType::Vendor:
                DefaultDim.SetRange("Table ID", 23);
            AccType::"Bank Account":
                DefaultDim.SetRange("Table ID", 270);
        end;
        DefaultDim.SetRange("No.", AccNo);
        DefaultDim.SetFilter("Dimension Value Code", '<>%1', '');
        if DefaultDim.FindSet() then
            repeat
                DimVal.Get(DefaultDim."Dimension Code", DefaultDim."Dimension Value Code");
                TempDimSetEntry2.Init();
                TempDimSetEntry2."Dimension Code" := DimVal."Dimension Code";
                TempDimSetEntry2."Dimension Value Code" := DimVal.Code;
                TempDimSetEntry2."Dimension Value ID" := DimVal."Dimension Value ID";
                TempDimSetEntry2."Global Dimension No." := DimVal."Global Dimension No.";
                if TempDimSetEntry2.Insert() then;
            until DefaultDim.Next() = 0;

        //2. Add Line dimension to Master Default Dimension
        if DimSetID <> 0 then begin
            DimMgt.GetDimensionSet(tempDimSetEntry1, DimSetID);
            if tempDimSetEntry1.FindSet() then
                repeat
                    TempDimSetEntry2.SetRange("Dimension Code", tempDimSetEntry1."Dimension Code");
                    if TempDimSetEntry2.FindSet() then begin
                        DimVal.Get(tempDimSetEntry1."Dimension Code", tempDimSetEntry1."Dimension Value Code");
                        TempDimSetEntry2."Dimension Value Code" := DimVal.Code;
                        TempDimSetEntry2."Dimension Value ID" := DimVal."Dimension Value ID";
                        TempDimSetEntry2."Global Dimension No." := DimVal."Global Dimension No.";
                        TempDimSetEntry2.Modify();
                    end else begin
                        DimVal.Get(tempDimSetEntry1."Dimension Code", tempDimSetEntry1."Dimension Value Code");
                        TempDimSetEntry2.Init();
                        TempDimSetEntry2."Dimension Code" := DimVal."Dimension Code";
                        TempDimSetEntry2."Dimension Value Code" := DimVal.Code;
                        TempDimSetEntry2."Dimension Value ID" := DimVal."Dimension Value ID";
                        TempDimSetEntry2."Global Dimension No." := DimVal."Global Dimension No.";
                        if TempDimSetEntry2.Insert() then;
                    end;
                until TempDimSetEntry1.Next() = 0;
        end;

        // if ELIMINATION then begin
        //     TempDimSetEntry2.Init();
        //     TempDimSetEntry2."Dimension Code" := 'ELIMINATION';
        //     TempDimSetEntry2."Dimension Value Code" := 'ELIMINATION';
        //     DimVal.Get('ELIMINATION', 'ELIMINATION');
        //     TempDimSetEntry2."Dimension Value ID" := DimVal."Dimension Value ID";
        //     TempDimSetEntry2.Insert();
        // end;

        ICGenJnlLine."Dimension Set ID" := GetDimensionSetID_Company(TempDimSetEntry2, AtCompany);

        TempDimSetEntry2.SetFilter("Global Dimension No.", '1');
        if TempDimSetEntry2.FindSet() then
            ICGenJnlLine."Shortcut Dimension 1 Code" := TempDimSetEntry2."Dimension Value Code";

        TempDimSetEntry2.SetFilter("Global Dimension No.", '2');
        if TempDimSetEntry2.FindSet() then
            ICGenJnlLine."Shortcut Dimension 2 Code" := TempDimSetEntry2."Dimension Value Code";

        ICGenJnlLine.Modify();

    end;


    local procedure EnqueueGenJrnlLine_Company(var GenJrnlLine: Record "Gen. Journal Line"; AtCompany: Text[30]; "Scheduled for Posting": Boolean): Code[20]
    var
        // JobQueueID: Guid;
        l_GenJnlLine: Record "Gen. Journal Line";
        l_GenJnlLine2: Record "Gen. Journal Line";
        l_GenJnlBatch: Record "Gen. Journal Batch";
        l_NoSeriesLine: Record "No. Series Line";
        DocNo: Code[20];
        JobQueueEntry: Record "Job Queue Entry";
        GeneralLedgerSetup: Record "General Ledger Setup";
        PostAndPrintDescription: Label 'Post and print journal lines for journal template %1, journal batch %2, document no. %3.';

    begin
        l_GenJnlLine.ChangeCompany(AtCompany);
        l_GenJnlLine2.ChangeCompany(AtCompany);
        l_GenJnlBatch.ChangeCompany(AtCompany);
        l_NoSeriesLine.ChangeCompany(AtCompany);

        l_GenJnlLine.Reset();
        l_GenJnlLine.SetRange("Journal Template Name", 'GENERAL');
        if GenJrnlLine."Document Type" = GenJrnlLine."Document Type"::Invoice then
            l_GenJnlLine.SetRange("Journal Batch Name", 'IC-INV')
        else
            if GenJrnlLine."Document Type" = GenJrnlLine."Document Type"::"Credit Memo" then
                l_GenJnlLine.SetRange("Journal Batch Name", 'IC-CR')
            else //Repayment
                l_GenJnlLine.SetRange("Journal Batch Name", 'IC-JV');

        l_GenJnlLine.SetRange("IC Source Document No.", GenJrnlLine."Document No.");
        if l_GenJnlLine.FindSet() then begin

            GeneralLedgerSetup.ChangeCompany(AtCompany);
            GeneralLedgerSetup.Get();

            l_GenJnlBatch.Get(l_GenJnlLine."Journal Template Name", l_GenJnlLine."Journal Batch Name");

            if l_GenJnlBatch."No. Series" <> '' then begin
                l_GenJnlLine2.Reset();
                l_GenJnlLine2.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
                l_GenJnlLine2.SetRange("Journal Template Name", l_GenJnlLine."Journal Template Name");
                l_GenJnlLine2.SetRange("Journal Batch Name", l_GenJnlLine."Journal Batch Name");
                l_GenJnlLine2.SetRange("Posting Date", CalcDate('<D1>', l_GenJnlLine."Posting Date"), CalcDate('<CM>', l_GenJnlLine."Posting Date"));
                if l_GenJnlLine2.FindLast() then
                    DocNo := IncStr(l_GenJnlLine2."Document No.")
                else begin
                    l_NoSeriesLine.Reset();
                    l_NoSeriesLine.SetCurrentKey("Series Code", "Starting Date");
                    l_NoSeriesLine.SetRange("Series Code", l_GenJnlBatch."No. Series");
                    l_NoSeriesLine.SetRange("Starting Date", 0D, l_GenJnlLine."Posting Date");
                    if l_NoSeriesLine.FindLast() then begin
                        l_NoSeriesLine.SetRange("Starting Date", l_NoSeriesLine."Starting Date");
                        l_NoSeriesLine.SetRange(Open, true);
                    end;
                    DocNo := IncStr(l_NoSeriesLine."Last No. Used");
                    if DocNo = '' then
                        DocNo := l_NoSeriesLine."Starting No.";
                end;

                l_GenJnlLine.ModifyAll("Document No.", DocNo);
            end else
                DocNo := l_GenJnlLine."Document No.";

            if "Scheduled for Posting" then begin
                JobQueueEntry.ChangeCompany(AtCompany);
                JobQueueEntry.Init();
                Clear(JobQueueEntry.ID);
                // Message(format(l_GenJnlLine.RecordId) + format(l_GenJnlLine."Line No."));
                JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
                JobQueueEntry."Object ID to Run" := CODEUNIT::"Gen. Jnl.-Post via Job Queue";
                JobQueueEntry."Record ID to Process" := l_GenJnlLine.RecordId;
                JobQueueEntry."Notify On Success" := GeneralLedgerSetup."Notify On Success";
                JobQueueEntry."Job Queue Category Code" := GeneralLedgerSetup."Job Queue Category Code";
                JobQueueEntry.Description := PostAndPrintDescription;
                JobQueueEntry.Description := CopyStr(StrSubstNo(JobQueueEntry.Description, l_GenJnlLine."Journal Template Name", l_GenJnlLine."Journal Batch Name", l_GenJnlLine."Document No."), 1, MaxStrLen(JobQueueEntry.Description));
                JobQueueEntry."User Session Started" := 0DT;
                JobQueueEntry."Earliest Start Date/Time" := CurrentDateTime + 100; //0.1Sec
                JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
                if IsNullGuid(JobQueueEntry.ID) then
                    JobQueueEntry.Insert(true);

                l_GenJnlLine.ModifyAll("Job Queue Status", l_GenJnlLine."Job Queue Status"::"Scheduled for Posting");
                l_GenJnlLine.ModifyAll("Job Queue Entry ID", JobQueueEntry.ID);

                JobQueueEntry.SetStatus(JobQueueEntry.Status::Ready);
            end;
        end;

        exit(DocNo);
    end;

    local procedure GetDimensionSetID_Company(var DimSetEntry: Record "Dimension Set Entry"; AtCompany: Text[30]): Integer
    var
        DimSetEntry2: Record "Dimension Set Entry";
        DimSetTreeNode: Record "Dimension Set Tree Node";
        Found: Boolean;
    begin
        DimSetEntry2.ChangeCompany(AtCompany);
        DimSetTreeNode.ChangeCompany(AtCompany);

        DimSetEntry2.Copy(DimSetEntry);

        if DimSetEntry."Dimension Set ID" > 0 then
            DimSetEntry.SetRange("Dimension Set ID", DimSetEntry."Dimension Set ID");

        DimSetEntry.SetCurrentKey("Dimension Value ID");
        DimSetEntry.SetFilter("Dimension Code", '<>%1', '');
        DimSetEntry.SetFilter("Dimension Value Code", '<>%1', '');

        if not DimSetEntry.FindSet then begin
            DimSetEntry.Copy(DimSetEntry2);
            exit(0);
        end;

        Found := true;
        DimSetTreeNode."Dimension Set ID" := 0;
        repeat
            DimSetEntry.TestField("Dimension Value ID");
            if Found then
                if not DimSetTreeNode.Get(DimSetTreeNode."Dimension Set ID", DimSetEntry."Dimension Value ID") then begin
                    Found := false;
                    DimSetTreeNode.LockTable();
                end;

            if not Found then begin
                DimSetTreeNode."Parent Dimension Set ID" := DimSetTreeNode."Dimension Set ID";
                DimSetTreeNode."Dimension Value ID" := DimSetEntry."Dimension Value ID";
                DimSetTreeNode."Dimension Set ID" := 0;
                DimSetTreeNode."In Use" := false;
                if not DimSetTreeNode.Insert(true) then
                    DimSetTreeNode.Get(DimSetTreeNode."Parent Dimension Set ID", DimSetTreeNode."Dimension Value ID");
            end;
        until DimSetEntry.Next() = 0;
        if not DimSetTreeNode."In Use" then begin
            if Found then begin
                DimSetTreeNode.LockTable();
                DimSetTreeNode.Get(DimSetTreeNode."Parent Dimension Set ID", DimSetTreeNode."Dimension Value ID");
            end;
            DimSetTreeNode."In Use" := true;
            DimSetTreeNode.Modify();
            InsertDimSetEntries_Company(DimSetEntry, DimSetTreeNode."Dimension Set ID", AtCompany);
        end;

        DimSetEntry.Copy(DimSetEntry2);

        exit(DimSetTreeNode."Dimension Set ID");
    end;

    local procedure InsertDimSetEntries_Company(var DimSetEntry: Record "Dimension Set Entry"; NewID: Integer; AtCompany: Text[30])
    var
        DimSetEntry2: Record "Dimension Set Entry";
    begin
        DimSetEntry2.ChangeCompany(AtCompany);
        DimSetEntry2.LockTable();
        if DimSetEntry.FindSet then
            repeat
                DimSetEntry2 := DimSetEntry;
                DimSetEntry2."Dimension Set ID" := NewID;
                DimSetEntry2."Global Dimension No." := DimSetEntry2.GetGlobalDimNo();
                DimSetEntry2.Insert();
            until DimSetEntry.Next() = 0;
    end;


    [EventSubscriber(ObjectType::Table, 750, 'OnAfterCopyGenJnlFromStdJnl', '', true, true)]
    local procedure OnAfterCopyGenJnlFromStdJnl_ValidateICPathCode(var GenJournalLine: Record "Gen. Journal Line"; StdGenJournalLine: Record "Standard General Journal Line")
    begin
        GenJournalLine.Validate("IC Path Code");
    end;

    //G014--

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostFixedAssetOnBeforeInsertGLEntry', '', true, true)]
    local procedure OnPostFixedAssetOnBeforeInsertGLEntry(var GenJournalLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry"; var IsHandled: Boolean; var TempFAGLPostBuf: Record "FA G/L Posting Buffer" temporary; GLEntry2: Record "G/L Entry")
    var
        FAPostingGr: Record "FA Posting Group";
        FA: Record "Fixed Asset";
        GLAccNo: code[20];
        DimMgt: Codeunit DimensionManagement;
        DimSetEntry: Record "Dimension Set Entry";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimVal: Record "Dimension Value";
        DimensionSetID: Integer;
    begin
        if not (GenJournalLine."FA Posting Type" = GenJournalLine."FA Posting Type"::Disposal) then
            exit;

        if not (GenJournalLine."Source Type" = GenJournalLine."Source Type"::"Fixed Asset") then
            exit;

        FA.Get(GenJournalLine."Source No.");
        FAPostingGr.Reset();
        FAPostingGr.GetPostingGroup(FA."FA Posting Group", GenJournalLine."Depreciation Book Code");

        GLAccNo := FAPostingGr.GetAccumDepreciationAccountOnDisposal();

        if (GLEntry."G/L Account No." <> GLAccNo) then
            exit;

        DimMgt.GetDimensionSet(TempDimSetEntry, GLEntry."Dimension Set ID");
        FAPostingGr.TestField("Accum Depr Acc on Disposal Dim");
        TempDimSetEntry.reset;
        TempDimSetEntry.SetRange("Dimension Code", 'FIXED ASSET MOVEMENT');
        if TempDimSetEntry.findfirst() then begin
            TempDimSetEntry.Validate("Dimension Value Code", FAPostingGr."Accum Depr Acc on Disposal Dim");
            TempDimSetEntry.Modify();
        end
        else begin
            DimVal.Get(TempDimSetEntry."Dimension Code", FAPostingGr."Accum Depr Acc on Disposal Dim");
            TempDimSetEntry.Init();
            TempDimSetEntry."Dimension Code" := 'FIXED ASSET MOVEMENT';
            TempDimSetEntry."Dimension Value Code" := FAPostingGr."Accum Depr Acc on Disposal Dim";
            TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
            TempDimSetEntry."Global Dimension No." := DimVal."Global Dimension No.";
            if TempDimSetEntry.Insert() then;
        end;

        DimensionSetID := GetDimensionSetID_Company(TempDimSetEntry, CompanyName);
        if DimensionSetID <> GenJournalLine."Dimension Set ID" then begin
            GLEntry."Dimension Set ID" := DimensionSetID;
            // GLEntry.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Format Address", 'OnBeforeFormatAddress', '', true, true)]
    local procedure OnBeforeFormatAddress_AddATTN(Country: Record "Country/Region"; var AddrArray: array[8] of Text[100]; var Name: Text[100]; var Name2: Text[100]; var Contact: Text[100]; var Addr: Text[100]; var Addr2: Text[50]; var City: Text[50]; var PostCode: Code[20]; var County: Text[50]; var CountryCode: Code[10]; NameLineNo: Integer; Name2LineNo: Integer; AddrLineNo: Integer; Addr2LineNo: Integer; ContLineNo: Integer; PostCodeCityLineNo: Integer; CountyLineNo: Integer; CountryLineNo: Integer; var Handled: Boolean)
    begin
        if (Contact <> '') and (StrLen(Contact) <= 94) then
            Contact := 'Attn: ' + Contact;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ReportManagement, 'OnAfterSubstituteReport', '', false, false)] //G008
    local procedure OnSubstituteReport_StandardStatement(ReportId: Integer; var NewReportId: Integer)
    begin
        if ReportId = Report::"Standard Statement" then
            NewReportId := Report::"Standard Statement Ext";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ReportManagement, 'OnAfterSubstituteReport', '', false, false)] //G009
    local procedure OnSubstituteReport_Reminder(ReportId: Integer; var NewReportId: Integer)
    begin
        if ReportId = Report::Reminder then
            NewReportId := Report::"Reminder Ext";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ReportManagement, 'OnAfterSubstituteReport', '', false, false)] //G010
    local procedure OnSubstituteReport_AgedAR(ReportId: Integer; var NewReportId: Integer)
    begin
        if ReportId = Report::"Aged Accounts Receivable" then
            NewReportId := Report::"Aged Accounts Receivable Ext";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ReportManagement, 'OnAfterSubstituteReport', '', false, false)] //G010
    local procedure OnSubstituteReport_AgedAP(ReportId: Integer; var NewReportId: Integer)
    begin
        if ReportId = Report::"Aged Accounts Payable" then
            NewReportId := Report::"Aged Accounts Payable Ext";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ReportManagement, 'OnAfterSubstituteReport', '', false, false)] //G002
    local procedure OnSubstituteReport_TestReport(ReportId: Integer; var NewReportId: Integer)
    begin
        if ReportId = Report::"General Journal - Test" then
            NewReportId := Report::"General Journal - Test Ext";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ReportManagement, 'OnAfterSubstituteReport', '', false, false)] //G003
    local procedure OnSubstituteReport_GLRegister(ReportId: Integer; var NewReportId: Integer)
    begin
        if ReportId = Report::"G/L Register" then
            // NewReportId := Report::"G/L Register Ext";
            NewReportId := Report::"G/L Register Ext IC";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ReportManagement, 'OnAfterSubstituteReport', '', false, false)] //G004
    local procedure OnSubstituteReport_BankAccStatement(ReportId: Integer; var NewReportId: Integer)
    begin
        if ReportId = Report::"Bank Account Statement" then
            NewReportId := Report::"Bank Account Statement Ext";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Batch Posting Print Mgt.", 'OnBeforeGLRegPostingReportPrint', '', false, false)]
    local procedure OnBeforeGLRegPostingReportPrint(var ReportID: Integer; ReqWindow: Boolean; SystemPrinter: Boolean; var GLRegister: Record "G/L Register"; var Handled: Boolean)
    var
        PrintSalesDoc: Boolean;
        l_GLE: Record "G/L Entry";
        l_TransPathDetail: Record "IC Transaction Path Details";
        WaitSec: Integer;
        l_CLE: Record "Cust. Ledger Entry";
        l_GLRegister: Record "G/L Register";
        GLSalesDocReport: Report "G/L Sales Document IC";
        RecRef: RecordRef;
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin

        l_GLE.Reset();
        l_GLE.SetRange("Entry No.", GLRegister."From Entry No.", GLRegister."To Entry No.");
        l_GLE.SetFilter("IC Path Code", '<>%1', '');
        if l_GLE.FindFirst() then begin
            l_TransPathDetail.Reset();
            l_TransPathDetail.SetRange("Path Code", l_GLE."IC Path Code");
            WaitSec := 2000 * l_TransPathDetail.Count();
            // Message('Wait Print: ' + format(WaitSec));
            Sleep(WaitSec);
            Commit();
        end;

        l_CLE.Reset();
        l_CLE.SetRange("Entry No.", GLRegister."From Entry No.", GLRegister."To Entry No.");
        if l_CLE.FindFirst() then begin
            if (l_CLE."Document Type" = l_CLE."Document Type"::Invoice) or (l_CLE."Document Type" = l_CLE."Document Type"::"Credit Memo") then begin
                PrintSalesDoc := true;
            end;
        end;
        if PrintSalesDoc then begin
            // Commit();
            l_GLRegister.CopyFilters(GLRegister);
            l_GLRegister.FindFirst();
            l_GLRegister.SetRecFilter();
            //RecRef.GetTable(l_GLRegister);
            //GLSalesDocReport.Execute('', RecRef);
            //GLSalesDocReport.SaveAs()
            GeneralLedgerSetup.Get();
            if GeneralLedgerSetup."Post & Print with Job Queue" then
                SchedulePrintJobQueueEntry(GLRegister, 50113, GeneralLedgerSetup."Report Output Type")
            else begin
                GLSalesDocReport.SetTableView(l_GLRegister);
                GLSalesDocReport.UseRequestPage(true);
                GLSalesDocReport.Run();
            end;
        end;
    end;

    local procedure SchedulePrintJobQueueEntry(RecVar: Variant; ReportId: Integer; ReportOutputType: Option)
    var
        JobQueueEntry: Record "Job Queue Entry";
        RecRefToPrint: RecordRef;
    begin
        RecRefToPrint.GetTable(RecVar);
        with JobQueueEntry do begin
            Clear(ID);
            "Object Type to Run" := "Object Type to Run"::Report;
            "Object ID to Run" := ReportId;
            "Report Output Type" := ReportOutputType;
            "Record ID to Process" := RecRefToPrint.RecordId;
            Description := Format("Report Output Type");
            CODEUNIT.Run(CODEUNIT::"Job Queue - Enqueue", JobQueueEntry);
            Commit();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Consolidate", 'OnBeforeGenJnlPostLine', '', false, false)]
    local procedure OnBeforeGenJnlPostLine(var GenJnlLine: Record "Gen. Journal Line")
    var
        Text013: Label 'adjusted from';
        Text017: Label 'at exchange rate';
        Text018: Label 'on';
        Description: Text;
        ConsolidAmount: Decimal;
        ExchangeRate: Decimal;
    begin
        Description := GenJnlLine.Description;
        if (Description.IndexOf(Text013) >= 1) then
            GenJnlLine."Conso. Exch. Adj. Entry" := true;

        if (Description.IndexOf(Text017) < 1) then
            exit;
        Evaluate(ConsolidAmount, Description.Substring(1, Description.IndexOf(Text017) - 1));
        Evaluate(ExchangeRate, Description.Substring(Description.IndexOf(Text017) + StrLen(Text017) + 1, Description.IndexOf(Text018) - (Description.IndexOf(Text017) + StrLen(Text017) + 1)));
        GenJnlLine."Conso. Base Amount" := ConsolidAmount;
        GenJnlLine."Conso. Exchange Rate" := ExchangeRate;
    end;
}