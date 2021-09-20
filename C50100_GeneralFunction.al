codeunit 50100 "General Function"
{
    Permissions = TableData "Dimension Set Entry" = rim, //G014
                  TableData "Dimension Set Tree Node" = rim, //G014
                  tabledata "G/L Entry" = rim;

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
        GLEntry."IC Path Code" := GenJournalLine."IC Path Code"; //G014
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
        ICTransPath: Record "IC Transaction Path";
        l_GenJnlLine: Record "Gen. Journal Line";
    begin
        with GenJournalLine do begin
            SetCurrentKey("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");
            Find('-');
            repeat
                if (GenJournalLine."IC Path Code" <> '') then begin
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

                    //Check Bal. Account and IC Allocation Bal. Account same as setup
                    ICTransPath.Get(GenJournalLine."IC Path Code");
                    l_GenJnlLine.Reset();
                    l_GenJnlLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
                    l_GenJnlLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
                    l_GenJnlLine.SetRange("Document No.", GenJournalLine."Document No.");
                    l_GenJnlLine.SetRange("Account Type", ICTransPath."Account Type");
                    l_GenJnlLine.SetRange("Account No.", ICTransPath."Account No.");
                    if not l_GenJnlLine.FindSet() then
                        Error('Document No. %1: %2 %3 must be the balance account for IC Path %4', GenJournalLine."Document No.", ICTransPath."Account Type", ICTransPath."Account No.", GenJournalLine."IC Path Code");
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
                                    if TempGenJournalLine."Account Type" = TempGenJournalLine."Account Type"::Customer then
                                        InsertGenJnlLine_Company(TempGenJournalLine, TempGenJournalLine."Account Type"::Vendor, ICPartner."Vendor No.", -TempGenJournalLine.Amount, 0, false, AtCompany)
                                    else
                                        InsertGenJnlLine_Company(TempGenJournalLine, TempGenJournalLine."Account Type"::Customer, ICPartner."Customer No.", -TempGenJournalLine.Amount, 0, false, AtCompany);
                                //IC_Line2
                                ICPartner.SetRange("Inbox Details", NextCompany);
                                if ICPartner.FindFirst() then
                                    if TempGenJournalLine."Account Type" = TempGenJournalLine."Account Type"::Customer then
                                        InsertGenJnlLine_Company(TempGenJournalLine, TempGenJournalLine."Account Type"::Customer, ICPartner."Customer No.", TempGenJournalLine.Amount, 0, false, AtCompany)
                                    else
                                        InsertGenJnlLine_Company(TempGenJournalLine, TempGenJournalLine."Account Type"::Vendor, ICPartner."Vendor No.", TempGenJournalLine.Amount, 0, false, AtCompany);

                                //Set Schedule Post
                                EnqueueGenJrnlLine_Company(TempGenJournalLine, AtCompany);

                                FromCompany := AtCompany;
                            end else begin
                                //If there is NO NextCompenay >>Last Line
                                //Last IC Line
                                ICPartner.ChangeCompany(AtCompany);
                                ICPartner.SetRange("Inbox Details", FromCompany);
                                if ICPartner.FindFirst() then
                                    if TempGenJournalLine."Account Type" = TempGenJournalLine."Account Type"::Customer then
                                        InsertGenJnlLine_Company(TempGenJournalLine, TempGenJournalLine."Account Type"::Vendor, ICPartner."Vendor No.", -TempGenJournalLine.Amount, 0, false, AtCompany)
                                    else
                                        InsertGenJnlLine_Company(TempGenJournalLine, TempGenJournalLine."Account Type"::Customer, ICPartner."Customer No.", -TempGenJournalLine.Amount, 0, false, AtCompany);

                                //Allocation Line         
                                ICAllocation.Reset();
                                ICAllocation.SetRange("Journal Template Name", TempGenJournalLine."Journal Template Name");
                                ICAllocation.SetRange("Journal Batch Name", TempGenJournalLine."Journal Batch Name");
                                ICAllocation.SetRange("Journal Line No.", TempGenJournalLine."Line No.");
                                if ICAllocation.FindSet() then begin
                                    repeat
                                        InsertGenJnlLine_Company(TempGenJournalLine, ICAllocation."IC Bal. Account Type", ICAllocation."IC Bal. Account No.", ICAllocation.Amount, ICAllocation."Bal. Dimension Set ID", false, AtCompany);
                                    until ICAllocation.Next() = 0;
                                    ICAllocation.DeleteAll();
                                end;

                                //Set Schedule Post
                                EnqueueGenJrnlLine_Company(TempGenJournalLine, AtCompany);
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
        ICGenJnlLine."Posting No. Series" := ICGenBatch."Posting No. Series";
        // ICGenJnlLine."Print Posted Documents" := true;
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
        //1. From Default Dimension
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
        DefaultDim.SetFilter("Dimension Value Code", '<>%1', '');
        if DefaultDim.FindSet() then
            repeat
                TempDimSetEntry2.Init();
                TempDimSetEntry2."Dimension Code" := DefaultDim."Dimension Code";
                TempDimSetEntry2."Dimension Value Code" := DefaultDim."Dimension Value Code";
                DimVal.Get(DefaultDim."Dimension Code", DefaultDim."Dimension Value Code");
                TempDimSetEntry2."Dimension Value ID" := DimVal."Dimension Value ID";
                TempDimSetEntry2."Global Dimension No." := DimVal."Global Dimension No.";
                TempDimSetEntry2.Insert();
            until DefaultDim.Next() = 0;

        //2. From Journal Line Dimension
        if DimSetID <> 0 then begin
            DimMgt.GetDimensionSet(tempDimSetEntry1, DimSetID);
            if tempDimSetEntry1.FindSet() then
                repeat
                    TempDimSetEntry2.SetRange("Dimension Code", tempDimSetEntry1."Dimension Code");
                    if TempDimSetEntry2.FindSet() then begin
                        TempDimSetEntry2."Dimension Value Code" := tempDimSetEntry1."Dimension Value Code";
                        DimVal.Get(tempDimSetEntry1."Dimension Code", tempDimSetEntry1."Dimension Value Code");
                        TempDimSetEntry2."Dimension Value ID" := DimVal."Dimension Value ID";
                        TempDimSetEntry2."Global Dimension No." := DimVal."Global Dimension No.";
                        TempDimSetEntry2.Modify();
                    end else begin
                        TempDimSetEntry2.Init();
                        TempDimSetEntry2."Dimension Code" := tempDimSetEntry1."Dimension Code";
                        TempDimSetEntry2."Dimension Value Code" := tempDimSetEntry1."Dimension Value Code";
                        DimVal.Get(tempDimSetEntry1."Dimension Code", tempDimSetEntry1."Dimension Value Code");
                        TempDimSetEntry2."Dimension Value ID" := DimVal."Dimension Value ID";
                        TempDimSetEntry2."Global Dimension No." := DimVal."Global Dimension No.";
                        TempDimSetEntry2.Insert();
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

    procedure EnqueueGenJrnlLine_Company(var GenJrnlLine: Record "Gen. Journal Line"; AtCompany: Text[30])
    var
        // JobQueueID: Guid;
        l_GenJnlLine: Record "Gen. Journal Line";

        JobQueueEntry: Record "Job Queue Entry";
        GeneralLedgerSetup: Record "General Ledger Setup";
        PostAndPrintDescription: Label 'Post and print journal lines for journal template %1, journal batch %2, document no. %3.';

    begin
        l_GenJnlLine.ChangeCompany(AtCompany);

        l_GenJnlLine.Reset();
        l_GenJnlLine.SetRange("Journal Template Name", 'GENERAL');
        l_GenJnlLine.SetRange("Journal Batch Name", 'ICTRANS');
        l_GenJnlLine.SetRange("Document No.", GenJrnlLine."Document No.");
        if l_GenJnlLine.FindSet() then begin
            GeneralLedgerSetup.ChangeCompany(AtCompany);
            GeneralLedgerSetup.Get();

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
            JobQueueEntry."Earliest Start Date/Time" := CurrentDateTime + 1000;
            JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
            if IsNullGuid(JobQueueEntry.ID) then
                JobQueueEntry.Insert(true);

            l_GenJnlLine.ModifyAll("Job Queue Status", l_GenJnlLine."Job Queue Status"::"Scheduled for Posting");
            l_GenJnlLine.ModifyAll("Job Queue Entry ID", JobQueueEntry.ID);

            JobQueueEntry.SetStatus(JobQueueEntry.Status::Ready);

        end;
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
        FAPostingGr.TestField("Accum. Depr. Acc. on Disposal Dim.");
        TempDimSetEntry.reset;
        TempDimSetEntry.SetRange("Dimension Code", 'FIXED ASSET MOVEMENT');
        if TempDimSetEntry.findfirst() then begin
            TempDimSetEntry.Validate("Dimension Value Code", FAPostingGr."Accum. Depr. Acc. on Disposal Dim.");
            TempDimSetEntry.Modify();
        end
        else begin
            TempDimSetEntry.Init();
            TempDimSetEntry."Dimension Code" := 'FIXED ASSET MOVEMENT';
            TempDimSetEntry."Dimension Value Code" := FAPostingGr."Accum. Depr. Acc. on Disposal Dim.";
            DimVal.Get(TempDimSetEntry."Dimension Code", FAPostingGr."Accum. Depr. Acc. on Disposal Dim.");
            TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
            TempDimSetEntry."Global Dimension No." := DimVal."Global Dimension No.";
            TempDimSetEntry.Insert();
        end;

        DimensionSetID := GetDimensionSetID_Company(TempDimSetEntry, CompanyName);
        if DimensionSetID <> GenJournalLine."Dimension Set ID" then begin
            GLEntry."Dimension Set ID" := DimensionSetID;
            //GLEntry.Modify();
        end;
    end;
}