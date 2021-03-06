report 50110 "Exch. Rate Gain/Loss Netting"
{
    //G025
    UsageCategory = Tasks;
    ApplicationArea = All;
    ProcessingOnly = true;
    Permissions = tabledata "Dimension Set Tree Node" = RIMD,
                    tabledata "Dimension Set Entry" = RIMD;

    dataset
    {
        dataitem(Company; Company)
        {
            RequestFilterFields = Name;

            trigger OnAfterGetRecord()
            var
                BU: Record "Business Unit";
                l_COA1: Record "G/L Account";
                l_COA2: Record "G/L Account";
                l_COA3: Record "G/L Account";
                l_COA4: Record "G/L Account";
                l_GL: Record "G/L Entry";
                l_SumGain: Decimal;
                l_SumLoss: Decimal;
                l_SumUnGain: Decimal;
                l_SumUnLoss: Decimal;
                GenJnlLine: Record "Gen. Journal Line";
                GenJnlBatch: Record "Gen. Journal Batch";
                NextLineNo: Integer;
                l_AccPeriod: Record "Accounting Period";
                l_YearEnd: Boolean;
                TempDimSetEntry: Record "Dimension Set Entry" temporary;
                DimVal: Record "Dimension Value";
            begin

                // BU.ChangeCompany(Company.Name);
                // if BU.FindSet() then
                //     CurrReport.Skip();

                //Not Reverse for year end posting
                l_AccPeriod.ChangeCompany(Company.Name);
                l_AccPeriod.SetRange("Starting Date", AsofDate + 1);
                if l_AccPeriod.FindSet() then
                    if l_AccPeriod."New Fiscal Year" then
                        l_YearEnd := true
                    else
                        l_YearEnd := false;

                l_COA1.ChangeCompany(Company.Name);
                l_COA2.ChangeCompany(Company.Name);
                l_COA3.ChangeCompany(Company.Name);
                l_COA4.ChangeCompany(Company.Name);
                l_GL.ChangeCompany(Company.Name);
                // EntryNoAmountBuf.ChangeCompany(Company.Name); //Confirmed by K&K on 8 Sept IC CRP, Exch Rate Netting by Account Only, not by Dimension. 


                l_SumGain := 0;
                l_COA1.Reset();
                l_COA1.SetRange("Income/Balance", l_COA1."Income/Balance"::"Income Statement");
                l_COA1.SetRange("Account Type", l_COA1."Account Type"::Posting);
                l_COA1.SetRange("Netting Type", l_COA1."Netting Type"::"Exch. Rate Gain");
                if l_COA1.FindFirst() then begin
                    l_GL.Reset();
                    l_GL.SetFilter("G/L Account No.", l_COA1."No.");
                    l_GL.SetFilter("Posting Date", '..%1', AsofDate);
                    if l_GL.FindSet() then
                        repeat
                            l_SumGain += l_GL.Amount;
                        until l_GL.Next() = 0;
                end;

                l_SumLoss := 0;
                l_COA2.Reset();
                l_COA2.SetRange("Income/Balance", l_COA2."Income/Balance"::"Income Statement");
                l_COA2.SetRange("Account Type", l_COA2."Account Type"::Posting);
                l_COA2.SetRange("Netting Type", l_COA2."Netting Type"::"Exch. Rate Loss");
                if l_COA2.FindFirst() then begin
                    l_GL.Reset();
                    l_GL.SetFilter("G/L Account No.", l_COA2."No.");
                    l_GL.SetFilter("Posting Date", '..%1', AsofDate);
                    if l_GL.FindSet() then
                        repeat
                            l_SumLoss += l_GL.Amount;
                        until l_GL.Next() = 0;
                end;

                l_SumUnGain := 0;
                l_COA3.Reset();
                l_COA3.SetRange("Income/Balance", l_COA3."Income/Balance"::"Income Statement");
                l_COA3.SetRange("Account Type", l_COA3."Account Type"::Posting);
                l_COA3.SetRange("Netting Type", l_COA3."Netting Type"::"Unrealized Exch. Rate Gain");
                if l_COA3.FindFirst() then begin
                    l_GL.Reset();
                    l_GL.SetFilter("G/L Account No.", l_COA3."No.");
                    l_GL.SetFilter("Posting Date", '..%1', AsofDate);
                    if l_GL.FindSet() then
                        repeat
                            l_SumUnGain += l_GL.Amount;
                        until l_GL.Next() = 0;
                end;

                l_SumUnLoss := 0;
                l_COA4.Reset();
                l_COA4.SetRange("Income/Balance", l_COA4."Income/Balance"::"Income Statement");
                l_COA4.SetRange("Account Type", l_COA4."Account Type"::Posting);
                l_COA4.SetRange("Netting Type", l_COA4."Netting Type"::"Unrealized Exch. Rate Loss");
                if l_COA4.FindFirst() then begin
                    l_GL.Reset();
                    l_GL.SetFilter("G/L Account No.", l_COA4."No.");
                    l_GL.SetFilter("Posting Date", '..%1', AsofDate);
                    if l_GL.FindSet() then
                        repeat
                            l_SumUnLoss += l_GL.Amount;
                        until l_GL.Next() = 0;
                end;

                if (Abs(l_SumGain) + Abs(l_SumLoss) + Abs(l_SumUnGain) + Abs(l_SumUnLoss)) > 0 then begin

                    GenJnlBatch.ChangeCompany(Company.Name);
                    GenJnlLine.ChangeCompany(Company.Name);

                    GenJnlBatch.Reset();
                    GenJnlBatch.SetRange("Journal Template Name", 'GENERAL');
                    GenJnlBatch.SetRange(Name, 'NET-EXCH');
                    if not GenJnlBatch.FindSet() then begin
                        GenJnlBatch.Init();
                        GenJnlBatch."Journal Template Name" := 'GENERAL';
                        GenJnlBatch.Name := 'NET-EXCH';
                        GenJnlBatch."Posting No. Series" := 'GJNL-GEN';
                        GenJnlBatch.Insert();
                    end;

                    GenJnlLine.Reset();
                    GenJnlLine.SetRange("Journal Template Name", 'GENERAL');
                    GenJnlLine.SetRange("Journal Batch Name", 'NET-EXCH');
                    if GenJnlLine.FindLast() then
                        NextLineNo := GenJnlLine."Line No." + 10000
                    else
                        NextLineNo := 10000;

                end else
                    CurrReport.Skip();


                //Default Dimension MULTI-PURPOSE = N/A - 18Nov2021
                TempDimSetEntry.Init();
                TempDimSetEntry."Dimension Code" := 'MULTI-PURPOSE';
                TempDimSetEntry."Dimension Value Code" := 'N/A';
                DimVal.Get('MULTI-PURPOSE', 'N/A');
                TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
                TempDimSetEntry.Insert();

                // For Realized Exch. Rate Gain/Loss
                if (Abs(l_SumGain) + Abs(l_SumLoss) > 0) AND ((Abs(l_SumLoss) > Abs(l_SumLoss + l_SumGain)) or (Abs(l_SumGain) > Abs(l_SumLoss + l_SumGain))) then begin

                    GenJnlLine.Init();
                    GenJnlLine."Journal Template Name" := 'GENERAL';
                    GenJnlLine."Journal Batch Name" := 'NET-EXCH';
                    GenJnlLine."Line No." := NextLineNo;
                    GenJnlLine."Posting Date" := AsofDate;
                    GenJnlLine."Document No." := format(NextLineNo);
                    GenJnlLine."Posting No. Series" := GenJnlBatch."Posting No. Series";
                    GenJnlLine."System-Created Entry" := true;
                    GenJnlLine.Insert();
                    If Abs(l_SumLoss) >= Abs(l_SumGain) then begin
                        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                        GenJnlLine."Account No." := l_COA1."No."; //Net Gain by Loss Amount
                        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
                        GenJnlLine."Bal. Account No." := l_COA2."No.";
                        GenJnlLine.Validate(Amount, -l_SumGain);
                    end else begin
                        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                        GenJnlLine."Account No." := l_COA2."No."; //Net Loss by Gain Amount
                        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
                        GenJnlLine."Bal. Account No." := l_COA1."No.";
                        GenJnlLine.Validate(Amount, -l_SumLoss);
                    end;
                    GenJnlLine.Description := StrSubstNo('EX Netting %1/%2 on %3', l_SumGain, l_SumLoss, AsofDate);
                    GenJnlLine."Dimension Set ID" := GetDimensionSetID_Company(TempDimSetEntry, Company.Name);
                    GenJnlLine.Modify();
                    NextLineNo := NextLineNo + 10000;

                    if not l_YearEnd then begin
                        //Line 2 - Reverse
                        GenJnlLine.Init();
                        GenJnlLine."Journal Template Name" := 'GENERAL';
                        GenJnlLine."Journal Batch Name" := 'NET-EXCH';
                        GenJnlLine."Line No." := NextLineNo;
                        GenJnlLine."Posting Date" := AsofDate + 1;
                        GenJnlLine."Document No." := format(NextLineNo);
                        GenJnlLine."Posting No. Series" := GenJnlBatch."Posting No. Series";
                        GenJnlLine."System-Created Entry" := true;
                        GenJnlLine.Insert();
                        If Abs(l_SumLoss) >= Abs(l_SumGain) then begin
                            GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                            GenJnlLine."Account No." := l_COA1."No."; //Gain
                            GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
                            GenJnlLine."Bal. Account No." := l_COA2."No.";
                            GenJnlLine.Validate(Amount, l_SumGain);
                        end else begin
                            GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                            GenJnlLine."Account No." := l_COA2."No."; //Loss
                            GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
                            GenJnlLine."Bal. Account No." := l_COA1."No.";
                            GenJnlLine.Validate(Amount, l_SumLoss);
                        end;
                        GenJnlLine.Description := StrSubstNo('EX Netting %1/%2 on %3-Reverse', l_SumGain, l_SumLoss, AsofDate);
                        GenJnlLine."Dimension Set ID" := GetDimensionSetID_Company(TempDimSetEntry, Company.Name);
                        GenJnlLine.Modify();
                        NextLineNo := NextLineNo + 10000;
                    end;
                end;

                // For Unrealized Exch. Rate Gain/Loss
                if (Abs(l_SumUnGain) + Abs(l_SumUnLoss) > 0) AND ((Abs(l_SumUnLoss) > Abs(l_SumUnLoss + l_SumUnGain)) or (Abs(l_SumUnGain) > Abs(l_SumUnLoss + l_SumUnGain))) then begin

                    GenJnlLine.Init();
                    GenJnlLine."Journal Template Name" := 'GENERAL';
                    GenJnlLine."Journal Batch Name" := 'NET-EXCH';
                    GenJnlLine."Line No." := NextLineNo;
                    GenJnlLine."Posting Date" := AsofDate;
                    GenJnlLine."Document No." := format(NextLineNo);
                    GenJnlLine."Posting No. Series" := GenJnlBatch."Posting No. Series";
                    GenJnlLine."System-Created Entry" := true;
                    GenJnlLine.Insert();
                    If Abs(l_SumUnLoss) >= Abs(l_SumUnGain) then begin
                        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                        GenJnlLine."Account No." := l_COA3."No."; //Net Gain by Loss Amount
                        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
                        GenJnlLine."Bal. Account No." := l_COA4."No.";
                        GenJnlLine.Validate(Amount, -l_SumUnGain);
                    end else begin
                        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                        GenJnlLine."Account No." := l_COA4."No."; //Net Loss by Gain Amount
                        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
                        GenJnlLine."Bal. Account No." := l_COA3."No.";
                        GenJnlLine.Validate(Amount, -l_SumUnLoss);
                    end;
                    GenJnlLine.Description := StrSubstNo('EX Netting %1/%2 on %3', l_SumUnGain, l_SumUnLoss, AsofDate);
                    GenJnlLine."Dimension Set ID" := GetDimensionSetID_Company(TempDimSetEntry, Company.Name);
                    GenJnlLine.Modify();
                    NextLineNo := NextLineNo + 10000;

                    if not l_YearEnd then begin
                        //Line 2 - Reverse
                        GenJnlLine.Init();
                        GenJnlLine."Journal Template Name" := 'GENERAL';
                        GenJnlLine."Journal Batch Name" := 'NET-EXCH';
                        GenJnlLine."Line No." := NextLineNo;
                        GenJnlLine."Posting Date" := AsofDate + 1;
                        GenJnlLine."Document No." := format(NextLineNo);
                        GenJnlLine."Posting No. Series" := GenJnlBatch."Posting No. Series";
                        GenJnlLine."System-Created Entry" := true;
                        GenJnlLine.Insert();
                        If Abs(l_SumUnLoss) >= Abs(l_SumUnGain) then begin
                            GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                            GenJnlLine."Account No." := l_COA3."No."; //Gain
                            GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
                            GenJnlLine."Bal. Account No." := l_COA4."No.";
                            GenJnlLine.Validate(Amount, l_SumUnGain);
                        end else begin
                            GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                            GenJnlLine."Account No." := l_COA4."No."; //Loss
                            GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
                            GenJnlLine."Bal. Account No." := l_COA3."No.";
                            GenJnlLine.Validate(Amount, l_SumUnLoss);
                        end;
                        GenJnlLine.Description := StrSubstNo('EX Netting %1/%2 on %3-Reverse', l_SumUnGain, l_SumUnLoss, AsofDate);
                        GenJnlLine."Dimension Set ID" := GetDimensionSetID_Company(TempDimSetEntry, Company.Name);
                        GenJnlLine.Modify();
                        NextLineNo := NextLineNo + 10000;
                    end;
                end;

            end;

        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field("As of Date"; AsofDate)
                    {
                        ApplicationArea = All;
                        trigger OnValidate()
                        begin
                            if AsofDate <> CalcDate('<CM>', AsofDate) then
                                Error('As of Date must be done at month end');
                        end;
                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    var
        AsofDate: Date;
    // EntryNoAmountBuf: Record "Entry No. Amount Buffer" temporary;

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

}