report 50109 ARAPNetting
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
                Customer: Record Customer;
                l_COA: Record "G/L Account";
                l_GL: Record "G/L Entry";
                l_SumAR: Decimal;
                l_SumAP: Decimal;
                l_CustPostGrp: Record "Customer Posting Group";
                l_Vend: Record Vendor;
                l_VendPostGrp: Record "Vendor Posting Group";
                GenJnlLine: Record "Gen. Journal Line";
                GenJnlBatch: Record "Gen. Journal Batch";
                NextLineNo: Integer;
                TempDimSetEntry: Record "Dimension Set Entry" temporary;
                DimVal: Record "Dimension Value";
            begin

                BU.ChangeCompany(Company.Name);
                if BU.FindSet() then
                    CurrReport.Skip();

                Customer.ChangeCompany(Company.Name);
                Customer.Reset();
                Customer.SetFilter("Netting Vendor No.", '<>%1', '');
                if Customer.FindSet() then begin
                    repeat

                        l_SumAR := 0;

                        l_COA.ChangeCompany(Company.Name);
                        l_GL.ChangeCompany(Company.Name);
                        l_CustPostGrp.ChangeCompany(Company.Name);
                        l_VendPostGrp.ChangeCompany(Company.Name);
                        l_Vend.ChangeCompany(Company.Name);

                        l_COA.Reset();
                        l_COA.SetRange("Income/Balance", l_COA."Income/Balance"::"Balance Sheet");
                        l_COA.SetRange("Account Type", l_COA."Account Type"::Posting);
                        // l_COA.SetRange("Account Subcategory Descript.", 'Accounts Receivable');
                        l_COA.SetRange("Netting Type", l_COA."Netting Type"::AR);
                        if l_COA.FindSet() then
                            repeat
                                l_GL.Reset();
                                l_GL.SetFilter("G/L Account No.", l_COA."No.");
                                l_GL.SetFilter("Posting Date", '..%1', AsofDate);
                                l_GL.SetRange("Source Type", l_GL."Source Type"::Customer);
                                l_GL.SetRange("Source No.", Customer."No.");
                                if l_GL.FindSet() then
                                    repeat
                                        l_SumAR += l_GL.Amount;
                                    until l_GL.Next() = 0;
                                l_GL.Reset();
                                l_GL.SetFilter("G/L Account No.", l_COA."No.");
                                l_GL.SetFilter("Posting Date", '..%1', AsofDate);
                                l_GL.SetRange("Netting Source No.", Customer."No.");
                                if l_GL.FindSet() then
                                    repeat
                                        l_SumAR += l_GL.Amount;
                                    until l_GL.Next() = 0;
                            until l_COA.Next() = 0;

                        l_SumAP := 0;
                        l_COA.Reset();
                        l_COA.SetRange("Income/Balance", l_COA."Income/Balance"::"Balance Sheet");
                        l_COA.SetRange("Account Type", l_COA."Account Type"::Posting);
                        // l_COA.SetRange("Account Subcategory Descript.", 'Current Liabilities');
                        l_COA.SetRange("Netting Type", l_COA."Netting Type"::AP);
                        if l_COA.FindSet() then
                            repeat
                                l_GL.Reset();
                                l_GL.SetFilter("Posting Date", '..%1', AsofDate);
                                l_GL.SetFilter("G/L Account No.", l_COA."No.");
                                l_GL.SetRange("Source Type", l_GL."Source Type"::Vendor);
                                l_GL.SetRange("Source No.", Customer."Netting Vendor No.");
                                if l_GL.FindSet() then
                                    repeat
                                        l_SumAP += l_GL.Amount;
                                    until l_GL.Next() = 0;
                                l_GL.Reset();
                                l_GL.SetFilter("G/L Account No.", l_COA."No.");
                                l_GL.SetFilter("Posting Date", '..%1', AsofDate);
                                l_GL.SetRange("Netting Source No.", Customer."No.");
                                if l_GL.FindSet() then
                                    repeat
                                        l_SumAP += l_GL.Amount;
                                    until l_GL.Next() = 0;
                            until l_COA.Next() = 0;

                        if (l_SumAR <> 0) AND (l_SumAP <> 0) then begin
                            GenJnlBatch.ChangeCompany(Company.Name);
                            GenJnlLine.ChangeCompany(Company.Name);

                            if (Abs(l_SumAR) > Abs(l_SumAR + l_SumAP)) or (Abs(l_SumAP) > Abs(l_SumAR + l_SumAP)) then begin

                                l_CustPostGrp.Get(Customer."Customer Posting Group");
                                l_Vend.Get(Customer."Netting Vendor No.");
                                l_VendPostGrp.Get(l_Vend."Vendor Posting Group");

                                GenJnlBatch.Reset();
                                GenJnlBatch.SetRange("Journal Template Name", 'GENERAL');
                                GenJnlBatch.SetRange(Name, 'NET-ARAP');
                                if not GenJnlBatch.FindSet() then begin
                                    GenJnlBatch.Init();
                                    GenJnlBatch."Journal Template Name" := 'GENERAL';
                                    GenJnlBatch.Name := 'NET-ARAP';
                                    GenJnlBatch."Posting No. Series" := 'GJNL-GEN';
                                    GenJnlBatch.Insert();
                                end;

                                GenJnlLine.Reset();
                                GenJnlLine.SetRange("Journal Template Name", 'GENERAL');
                                GenJnlLine.SetRange("Journal Batch Name", 'NET-ARAP');
                                if GenJnlLine.FindLast() then
                                    NextLineNo := GenJnlLine."Line No." + 10000
                                else
                                    NextLineNo := 10000;

                                //Set Elimination Dimension
                                TempDimSetEntry.Init();
                                TempDimSetEntry."Dimension Code" := 'ELIMINATION';
                                TempDimSetEntry."Dimension Value Code" := 'ELIMINATION';
                                DimVal.Get('ELIMINATION', 'ELIMINATION');
                                TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
                                TempDimSetEntry.Insert();

                                //Line 1
                                GenJnlLine.Init();
                                GenJnlLine."Journal Template Name" := 'GENERAL';
                                GenJnlLine."Journal Batch Name" := 'NET-ARAP';
                                GenJnlLine."Line No." := NextLineNo;
                                GenJnlLine."Posting Date" := AsofDate;
                                GenJnlLine."Document No." := format(NextLineNo);
                                GenJnlLine."System-Created Entry" := true;
                                GenJnlLine."Netting Source No." := Customer."No.";
                                GenJnlLine.Insert();
                                If Abs(l_SumAR) >= Abs(l_SumAP) then begin
                                    GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                                    GenJnlLine."Account No." := l_VendPostGrp."Payables Account";
                                    GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
                                    GenJnlLine."Bal. Account No." := l_CustPostGrp."Receivables Account";
                                    GenJnlLine.Validate(Amount, -l_SumAP);
                                end
                                else begin
                                    GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                                    GenJnlLine."Account No." := l_CustPostGrp."Receivables Account";
                                    GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
                                    GenJnlLine."Bal. Account No." := l_VendPostGrp."Payables Account";
                                    GenJnlLine.Validate(Amount, -l_SumAR);
                                end;
                                GenJnlLine.Description := StrSubstNo('ARAP Netting %1/%2 on %3', l_SumAR, l_SumAP, AsofDate);
                                GenJnlLine."Dimension Set ID" := GetDimensionSetID_Company(TempDimSetEntry, Company.Name);
                                GenJnlLine.Modify();
                                NextLineNo := NextLineNo + 10000;

                                //Line 2 - Reverse
                                GenJnlLine.Init();
                                GenJnlLine."Journal Template Name" := 'GENERAL';
                                GenJnlLine."Journal Batch Name" := 'NET-ARAP';
                                GenJnlLine."Line No." := NextLineNo;
                                GenJnlLine."Posting Date" := AsofDate + 1;
                                GenJnlLine."Document No." := format(NextLineNo);
                                GenJnlLine."System-Created Entry" := true;
                                GenJnlLine."Netting Source No." := Customer."No.";
                                GenJnlLine.Insert();

                                If Abs(l_SumAR) >= Abs(l_SumAP) then begin
                                    GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                                    GenJnlLine.Validate("Account No.", l_VendPostGrp."Payables Account");
                                    GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
                                    GenJnlLine.Validate("Bal. Account No.", l_CustPostGrp."Receivables Account");
                                    GenJnlLine.Validate(Amount, l_SumAP);
                                end
                                else begin
                                    GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                                    GenJnlLine.Validate("Account No.", l_CustPostGrp."Receivables Account");
                                    GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
                                    GenJnlLine.Validate("Bal. Account No.", l_VendPostGrp."Payables Account");
                                    GenJnlLine.Validate(Amount, l_SumAR);
                                end;
                                GenJnlLine.Description := StrSubstNo('ARAP Netting %1/%2 on %3-Reverse', l_SumAR, l_SumAP, AsofDate);
                                GenJnlLine."Dimension Set ID" := GetDimensionSetID_Company(TempDimSetEntry, Company.Name);
                                GenJnlLine.Modify();
                                NextLineNo := NextLineNo + 10000;

                            end;
                        end;
                    until Customer.Next() = 0;
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