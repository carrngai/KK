report 50109 ARAPNetting
{
    //G025
    UsageCategory = Tasks;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Company; Company)
        {
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

                        if (l_SumAR = 0) OR (l_SumAP = 0) then
                            CurrReport.Skip();

                        GenJnlBatch.ChangeCompany(Company.Name);
                        GenJnlLine.ChangeCompany(Company.Name);

                        if (l_SumAR) <> (l_SumAP) then begin

                            l_CustPostGrp.Get(Customer."Customer Posting Group");
                            l_Vend.Get(Customer."Netting Vendor No.");
                            l_VendPostGrp.Get(l_Vend."Vendor Posting Group");

                            GenJnlBatch.Reset();
                            GenJnlBatch.SetRange("Journal Template Name", 'GENERAL');
                            GenJnlBatch.SetRange(Name, 'ARAPNET');
                            if not GenJnlBatch.FindSet() then begin
                                GenJnlBatch.Init();
                                GenJnlBatch."Journal Template Name" := 'GENERAL';
                                GenJnlBatch.Name := 'ARAPNET';
                                GenJnlBatch."Posting No. Series" := 'GJNL-GEN';
                                GenJnlBatch.Insert();
                            end;

                            GenJnlLine.Reset();
                            GenJnlLine.SetRange("Journal Template Name", 'GENERAL');
                            GenJnlLine.SetRange("Journal Batch Name", 'ARAPNET');
                            if GenJnlLine.FindLast() then
                                NextLineNo := GenJnlLine."Line No." + 10000
                            else
                                NextLineNo := 10000;

                            //Line 1
                            GenJnlLine.Init();
                            GenJnlLine."Journal Template Name" := 'GENERAL';
                            GenJnlLine."Journal Batch Name" := 'ARAPNET';
                            GenJnlLine."Line No." := NextLineNo;
                            GenJnlLine."Posting Date" := AsofDate;
                            GenJnlLine."Document No." := format(NextLineNo);
                            GenJnlLine."System-Created Entry" := true;
                            GenJnlLine."Netting Source No." := Customer."No.";
                            GenJnlLine.Insert();
                            If l_SumAR > l_SumAP then begin
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
                            GenJnlLine.Modify();
                            NextLineNo := NextLineNo + 10000;

                            //Line 2 - Reverse
                            GenJnlLine.Init();
                            GenJnlLine."Journal Template Name" := 'GENERAL';
                            GenJnlLine."Journal Batch Name" := 'ARAPNET';
                            GenJnlLine."Line No." := NextLineNo;
                            GenJnlLine."Posting Date" := AsofDate + 1;
                            GenJnlLine."Document No." := format(NextLineNo);
                            GenJnlLine."System-Created Entry" := true;
                            GenJnlLine."Netting Source No." := Customer."No.";
                            GenJnlLine.Insert();

                            If l_SumAR > l_SumAP then begin
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

                            GenJnlLine.Description := StrSubstNo('Reverse ARAPNetting %1/%2 on %3', l_SumAR, l_SumAP, AsofDate);
                            GenJnlLine.Modify();
                            NextLineNo := NextLineNo + 10000;

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
}