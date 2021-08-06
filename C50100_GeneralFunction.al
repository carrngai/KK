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
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        TempDimSetEntry2: Record "Dimension Set Entry" temporary;
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
                            //Last Step
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

                                    //First Line - Dimension
                                    TempDimSetEntry2.ChangeCompany(ICTransPathD."To Company");
                                    DimVal.ChangeCompany(ICTransPathD."To Company");
                                    DimMgt.GetDimensionSet(tempDimSetEntry, TempGenJournalLine."Dimension Set ID");
                                    if tempDimSetEntry.FindSet() then
                                        repeat
                                            TempDimSetEntry2.Init();
                                            TempDimSetEntry2."Dimension Code" := tempDimSetEntry."Dimension Code";
                                            TempDimSetEntry2."Dimension Value Code" := tempDimSetEntry."Dimension Value Code";
                                            DimVal.Get(tempDimSetEntry."Dimension Code", tempDimSetEntry."Dimension Value Code");
                                            TempDimSetEntry2."Dimension Value ID" := DimVal."Dimension Value ID";
                                            TempDimSetEntry2.Insert();
                                        until tempDimSetEntry.Next() = 0;
                                    TempDimSetEntry2.Init();
                                    TempDimSetEntry2."Dimension Code" := 'ELIMINATION';
                                    TempDimSetEntry2."Dimension Value Code" := 'ELIMINATION';
                                    DimVal.Get('ELIMINATION', 'ELIMINATION');
                                    TempDimSetEntry2."Dimension Value ID" := DimVal."Dimension Value ID";
                                    TempDimSetEntry2.Insert();
                                    ICGenJnlLine."Dimension Set ID" := GetDimensionSetIDFromCompany(TempDimSetEntry2, ICTransPathD."To Company");
                                    ICGenJnlLine.Modify();
                                    TempDimSetEntry2.DeleteAll();

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
                                            //Allocation Line - Dimension
                                            DimMgt.GetDimensionSet(tempDimSetEntry, ICAllocation."Bal. Dimension Set ID");
                                            if tempDimSetEntry.FindSet() then
                                                repeat
                                                    TempDimSetEntry2.Init();
                                                    TempDimSetEntry2."Dimension Code" := tempDimSetEntry."Dimension Code";
                                                    TempDimSetEntry2."Dimension Value Code" := tempDimSetEntry."Dimension Value Code";
                                                    DimVal.Get(tempDimSetEntry."Dimension Code", tempDimSetEntry."Dimension Value Code");
                                                    TempDimSetEntry2."Dimension Value ID" := DimVal."Dimension Value ID";
                                                    TempDimSetEntry2.Insert();
                                                until tempDimSetEntry.Next() = 0;

                                            If ICTransMapping.Get(TempGenJournalLine."IC Path Code",
                                                                    TempGenJournalLine."Account Type",
                                                                    TempGenJournalLine."Account No.",
                                                                    TempGenJournalLine."Dimension Set ID",
                                                                    TempGenJournalLine."IC Bal. Account Type",
                                                                    TempGenJournalLine."IC Bal. Account No.",
                                                                    ICAllocation."Bal. Dimension Set ID") then begin
                                                if ICTransMapping.Elimination then begin
                                                    TempDimSetEntry2.Init();
                                                    TempDimSetEntry2."Dimension Code" := 'ELIMINATION';
                                                    TempDimSetEntry2."Dimension Value Code" := 'ELIMINATION';
                                                    DimVal.Get('ELIMINATION', 'ELIMINATION');
                                                    TempDimSetEntry2."Dimension Value ID" := DimVal."Dimension Value ID";
                                                    TempDimSetEntry2.Insert();
                                                end;
                                            end;

                                            ICGenJnlLine."Dimension Set ID" := GetDimensionSetIDFromCompany(TempDimSetEntry2, ICTransPathD."To Company");
                                            ICGenJnlLine.Modify();
                                            TempDimSetEntry2.DeleteAll();

                                        until ICAllocation.Next() = 0;
                                    end;
                                    //need to delete IC allocation
                                end;
                            end
                            else begin
                                //IC ARAP
                                //Get Line No.
                                ICGenJnlLine.ChangeCompany(ICTransPathD."To Company");
                                ICGenJnlLine.SetRange("Journal Template Name", 'GENERAL');
                                ICGenJnlLine.SetRange("Journal Batch Name", 'DEFAULT');
                                if ICGenJnlLine.FindLast() then
                                    NextLineNo := ICGenJnlLine."Line No." + 10000
                                else
                                    NextLineNo := 10000;

                                ICPartner.ChangeCompany(ICTransPathD."To Company");
                                ICPartner.SetRange("Inbox Details", FromCompany);
                                if ICPartner.FindFirst() then begin
                                    //Line1
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
                                    //ICGenJnlLine."Dimension Set ID" := ??
                                    ICGenJnlLine.Modify();
                                end;

                                // ICPartner.SetRange("Inbox Details", ); //ToCompany
                                // if ICPartner.FindFirst() then begin
                                //     //Line2
                                //     ICGenJnlLine.Init();
                                //     ICGenJnlLine."Journal Template Name" := 'GENERAL';
                                //     ICGenJnlLine."Journal Batch Name" := 'DEFAULT';
                                //     ICGenJnlLine."Line No." := NextLineNo;
                                //     ICGenJnlLine."Posting Date" := TempGenJournalLine."Posting Date";
                                //     ICGenJnlLine."External Document No." := TempGenJournalLine."Document No.";
                                //     ICGenJnlLine."Account Type" := TempGenJournalLine."Account Type"::Customer;
                                //     ICGenJnlLine."Account No." := ICPartner."Customer No.";
                                //     ICGenJnlLine."Currency Code" := TempGenJournalLine."Currency Code";
                                //     ICGenJnlLine."Currency Factor" := TempGenJournalLine."Currency Factor";
                                //     ICGenJnlLine.Insert();
                                //     ICGenJnlLine.Validate(Amount, TempGenJournalLine.Amount);    
                                //     //ICGenJnlLine."Dimension Set ID" := ??
                                //     ICGenJnlLine.Modify();                
                                // end;

                                FromCompany := ICTransPathD."To Company";
                            end;

                        until ICTransPathD.Next() = 0;

                    end;
                end;
            until Next() = 0;
        end;
    end;


    procedure GetDimensionSetIDFromCompany(var DimSetEntry: Record "Dimension Set Entry"; FromCompany: Text[30]): Integer
    var
        DimSetEntry2: Record "Dimension Set Entry";
        DimSetTreeNode: Record "Dimension Set Tree Node";
        Found: Boolean;
    begin
        DimSetEntry2.ChangeCompany(FromCompany);
        DimSetTreeNode.ChangeCompany(FromCompany);

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
            InsertDimSetEntriesFromCompany(DimSetEntry, DimSetTreeNode."Dimension Set ID", FromCompany);
        end;

        DimSetEntry.Copy(DimSetEntry2);

        exit(DimSetTreeNode."Dimension Set ID");
    end;

    local procedure InsertDimSetEntriesFromCompany(var DimSetEntry: Record "Dimension Set Entry"; NewID: Integer; FromCompany: Text[30])
    var
        DimSetEntry2: Record "Dimension Set Entry";
    begin
        DimSetEntry2.ChangeCompany(FromCompany);
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