codeunit 50100 "General Function"
{
    Permissions = TableData "Dimension Set Entry" = rim, //G014
                  TableData "Dimension Set Tree Node" = rim; //G014

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
    local procedure OnAfterInitGLEntry_NewFieldsMapping(var GLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        GLEntry."Conso. Exch. Adj." := GenJournalLine."Conso. Exch. Adj."; //G017
        GLEntry."Netting Source No." := GenJournalLine."Netting Source No."; //G025
        GLEntry."Description 2" := GenJournalLine."Description 2";
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
        l_GenJnlLine: Record "Gen. Journal Line";
    begin
        with GenJournalLine do begin
            SetCurrentKey("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");
            Find('-');
            repeat
                //Check IC Bal. Account No.
                if (GenJournalLine."IC Path Code" <> '') AND ("IC Bal. Account No." = '') then
                    Error('Line No. %1 : IC Bal. Account No. must have a value.', GenJournalLine."Line No.");

                //Check Allocated Amount
                TotalAllocatedAmt := 0;
                if (GenJournalLine."IC Path Code" <> '') then begin
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
                    end; // there can be no allocation
                end;

                //Check IC direction
                if (GenJournalLine."IC Path Code" <> '') then begin
                    l_GenJnlLine.Reset();
                    l_GenJnlLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
                    l_GenJnlLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
                    l_GenJnlLine.SetRange("Document No.", GenJournalLine."Document No.");
                    l_GenJnlLine.SetFilter("Line No.", '<>%1', GenJournalLine."Line No.");
                    if l_GenJnlLine.FindFirst() then
                        if (l_GenJnlLine."Account Type" = l_GenJnlLine."Account Type"::Customer) then begin
                            GenJournalLine."IC From Customer" := true;
                            GenJournalLine.Modify();
                        end else
                            if (l_GenJnlLine."Account Type" = l_GenJnlLine."Account Type"::Vendor) then begin
                                GenJournalLine."IC From Customer" := false;
                                GenJournalLine.Modify();
                            end else
                                Error('Line No. %1 : Account Type must be Customer/Vendor.', l_GenJnlLine."Line No.");
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
        FromCompany: Code[50];
        AtCompany: Code[50];
        NextCompany: Code[50];
        ICEliminate: Boolean;

    begin
        FromCompany := CompanyName;
        with TempGenJournalLine do begin
            SetCurrentKey("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");
            Find('-');
            repeat
                if (TempGenJournalLine."IC Path Code" <> '') then begin

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
                                if ICPartner.FindFirst() then
                                    if TempGenJournalLine."IC From Customer" then
                                        InsertGenJnlLine_Company(TempGenJournalLine, TempGenJournalLine."Account Type"::Vendor, ICPartner."Vendor No.", -TempGenJournalLine.Amount, 0, true, AtCompany)
                                    else
                                        InsertGenJnlLine_Company(TempGenJournalLine, TempGenJournalLine."Account Type"::Customer, ICPartner."Customer No.", -TempGenJournalLine.Amount, 0, true, AtCompany);
                                //IC_Line2
                                ICPartner.SetRange("Inbox Details", NextCompany);
                                if ICPartner.FindFirst() then
                                    if TempGenJournalLine."IC From Customer" then
                                        InsertGenJnlLine_Company(TempGenJournalLine, TempGenJournalLine."Account Type"::Customer, ICPartner."Customer No.", TempGenJournalLine.Amount, 0, true, AtCompany)
                                    else
                                        InsertGenJnlLine_Company(TempGenJournalLine, TempGenJournalLine."Account Type"::Vendor, ICPartner."Vendor No.", TempGenJournalLine.Amount, 0, true, AtCompany);

                                FromCompany := AtCompany;
                            end else begin
                                //If there is NO NextCompenay >>Last Line
                                //Last IC Line
                                ICPartner.ChangeCompany(AtCompany);
                                ICPartner.SetRange("Inbox Details", FromCompany);
                                if ICPartner.FindFirst() then
                                    if TempGenJournalLine."IC From Customer" then
                                        InsertGenJnlLine_Company(TempGenJournalLine, TempGenJournalLine."Account Type"::Vendor, ICPartner."Vendor No.", -TempGenJournalLine.Amount, 0, true, AtCompany)
                                    else
                                        InsertGenJnlLine_Company(TempGenJournalLine, TempGenJournalLine."Account Type"::Customer, ICPartner."Customer No.", -TempGenJournalLine.Amount, 0, true, AtCompany);

                                //Allocation Line         
                                ICAllocation.Reset();
                                ICAllocation.SetRange("Journal Template Name", TempGenJournalLine."Journal Template Name");
                                ICAllocation.SetRange("Journal Batch Name", TempGenJournalLine."Journal Batch Name");
                                ICAllocation.SetRange("Journal Line No.", TempGenJournalLine."Line No.");
                                if ICAllocation.FindSet() then begin
                                    repeat
                                        ICEliminate := false;
                                        // If ICTransMapping.Get(TempGenJournalLine."IC Path Code",
                                        //                         TempGenJournalLine."Account Type",
                                        //                         TempGenJournalLine."Account No.",
                                        //                         TempGenJournalLine."Dimension Set ID",
                                        //                         TempGenJournalLine."IC Bal. Account Type",
                                        //                         TempGenJournalLine."IC Bal. Account No.",
                                        //                         ICAllocation."Bal. Dimension Set ID") then
                                        //     ICEliminate := ICTransMapping.Elimination;

                                        InsertGenJnlLine_Company(TempGenJournalLine, TempGenJournalLine."IC Bal. Account Type", TempGenJournalLine."IC Bal. Account No.", ICAllocation.Amount, ICAllocation."Bal. Dimension Set ID", ICEliminate, AtCompany);
                                    until ICAllocation.Next() = 0;
                                    ICAllocation.DeleteAll();
                                end else begin
                                    //If there is no allocation
                                    ICEliminate := false;
                                    // If ICTransMapping.Get(TempGenJournalLine."IC Path Code",
                                    //                         TempGenJournalLine."Account Type",
                                    //                         TempGenJournalLine."Account No.",
                                    //                         TempGenJournalLine."Dimension Set ID",
                                    //                         TempGenJournalLine."IC Bal. Account Type",
                                    //                         TempGenJournalLine."IC Bal. Account No.",
                                    //                         TempGenJournalLine."Dimension Set ID") then
                                    //     ICEliminate := ICTransMapping.Elimination;

                                    InsertGenJnlLine_Company(TempGenJournalLine, TempGenJournalLine."IC Bal. Account Type", TempGenJournalLine."IC Bal. Account No.", TempGenJournalLine.Amount, TempGenJournalLine."Dimension Set ID", ICEliminate, AtCompany);
                                end;
                            end;
                        until ICTransPathDetail.Next() = 0;
                    end;
                end;
            until Next() = 0;
        end;
    end;

    local procedure InsertGenJnlLine_Company(var SourceGenJnLine: Record "Gen. Journal Line"; AccType: Enum "Gen. Journal Account Type"; AccNo: Code[20]; LineAmount: decimal; DimSetID: integer; ELIMINATION: boolean; AtCompany: Text[30])
    var
        ICGenBatch: Record "Gen. Journal Batch";
        ICGenJnlLine: Record "Gen. Journal Line";
        NextLineNo: Integer;
        DimVal: Record "Dimension Value";
        TempDimSetEntry1: Record "Dimension Set Entry" temporary;
        TempDimSetEntry2: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
        DefaultDim: Record "Default Dimension";

    begin
        ICGenBatch.ChangeCompany(AtCompany);
        ICGenJnlLine.ChangeCompany(AtCompany);
        TempDimSetEntry2.ChangeCompany(AtCompany);
        DefaultDim.ChangeCompany(AtCompany);
        DimVal.ChangeCompany(AtCompany);

        ICGenBatch.Reset();
        ICGenBatch.SetRange("Journal Template Name", 'GENERAL');
        ICGenBatch.SetRange(Name, 'ICTRANS');
        if not ICGenBatch.FindSet() then begin
            ICGenBatch.Init();
            ICGenBatch."Journal Template Name" := 'GENERAL';
            ICGenBatch.Name := 'ICTRANS';
            ICGenBatch."Posting No. Series" := 'GJNL-GEN';
            ICGenBatch.Insert();
        end;

        ICGenJnlLine.Reset();
        ICGenJnlLine.SetRange("Journal Template Name", 'GENERAL');
        ICGenJnlLine.SetRange("Journal Batch Name", 'ICTRANS');
        if ICGenJnlLine.FindLast() then
            NextLineNo := ICGenJnlLine."Line No." + 10000
        else
            NextLineNo := 10000;

        ICGenJnlLine.Init();
        ICGenJnlLine."Journal Template Name" := 'GENERAL';
        ICGenJnlLine."Journal Batch Name" := 'ICTRANS';
        ICGenJnlLine."Line No." := NextLineNo;
        ICGenJnlLine."Posting Date" := SourceGenJnLine."Posting Date";
        ICGenJnlLine."Document No." := SourceGenJnLine."Document No.";
        ICGenJnlLine."External Document No." := SourceGenJnLine."External Document No.";
        ICGenJnlLine.Insert();
        ICGenJnlLine."Account Type" := AccType;
        ICGenJnlLine."Account No." := AccNo;
        ICGenJnlLine."Currency Code" := SourceGenJnLine."Currency Code";
        ICGenJnlLine."Currency Factor" := SourceGenJnLine."Currency Factor";
        ICGenJnlLine.Description := SourceGenJnLine.Description;
        ICGenJnlLine.Validate(Amount, LineAmount);

        //Line Dimension
        DefaultDim.Reset();
        case AccType of
            AccType::"G/L Account":
                DefaultDim.SetRange("Table ID", 15);
            AccType::Customer:
                DefaultDim.SetRange("Table ID", 18);
            AccType::Vendor:
                DefaultDim.SetRange("Table ID", 23);
        end;
        DefaultDim.SetRange("No.", AccNo);
        if DefaultDim.FindSet() then
            repeat
                TempDimSetEntry2.Init();
                TempDimSetEntry2."Dimension Code" := DefaultDim."Dimension Code";
                TempDimSetEntry2."Dimension Value Code" := DefaultDim."Dimension Value Code";
                DimVal.Get(DefaultDim."Dimension Code", DefaultDim."Dimension Value Code");
                TempDimSetEntry2."Dimension Value ID" := DimVal."Dimension Value ID";
                TempDimSetEntry2.Insert();
            until DefaultDim.Next() = 0;

        if DimSetID <> 0 then begin
            DimMgt.GetDimensionSet(tempDimSetEntry1, DimSetID);
            if tempDimSetEntry1.FindSet() then
                repeat
                    TempDimSetEntry2.SetRange("Dimension Code");
                    if TempDimSetEntry2.FindSet() then begin
                        TempDimSetEntry2."Dimension Value Code" := tempDimSetEntry1."Dimension Value Code";
                        DimVal.Get(tempDimSetEntry1."Dimension Code", tempDimSetEntry1."Dimension Value Code");
                        TempDimSetEntry2."Dimension Value ID" := DimVal."Dimension Value ID";
                        TempDimSetEntry2.Modify();
                    end else begin
                        TempDimSetEntry2.Init();
                        TempDimSetEntry2."Dimension Code" := tempDimSetEntry1."Dimension Code";
                        TempDimSetEntry2."Dimension Value Code" := tempDimSetEntry1."Dimension Value Code";
                        DimVal.Get(tempDimSetEntry1."Dimension Code", tempDimSetEntry1."Dimension Value Code");
                        TempDimSetEntry2."Dimension Value ID" := DimVal."Dimension Value ID";
                        TempDimSetEntry2.Insert();
                    end;
                until TempDimSetEntry1.Next() = 0;
        end;

        if ELIMINATION then begin
            TempDimSetEntry2.Init();
            TempDimSetEntry2."Dimension Code" := 'ELIMINATION';
            TempDimSetEntry2."Dimension Value Code" := 'ELIMINATION';
            DimVal.Get('ELIMINATION', 'ELIMINATION');
            TempDimSetEntry2."Dimension Value ID" := DimVal."Dimension Value ID";
            TempDimSetEntry2.Insert();
        end;

        ICGenJnlLine."Dimension Set ID" := GetDimensionSetID_Company(TempDimSetEntry2, AtCompany);
        ICGenJnlLine.Modify();
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

    //G014--
}