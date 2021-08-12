report 50109 ARAPNetting
{
    //G025
    UsageCategory = Tasks;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = SORTING("No.") WHERE("Netting Vendor No." = filter(<> ''));
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            var
                l_CLE: Record "Cust. Ledger Entry";
                l_VLE: Record "Vendor Ledger Entry";
                l_GenJnlBatch: Record "Gen. Journal Batch";
                GenJnlLine: Record "Gen. Journal Line";

            begin

                l_GenJnlBatch.Get('GENERAL', JnlBatchName);

                GenJnlLine.Reset();
                GenJnlLine.SetRange("Journal Template Name", 'GENERAL');
                GenJnlLine.SetRange("Journal Batch Name", JnlBatchName);
                if GenJnlLine.FindLast() then
                    NextLineNo := GenJnlLine."Line No." + 10000
                else
                    NextLineNo := 10000;

                l_CLE.Reset();
                l_CLE.CalcFields("Remaining Amount", "Remaining Amt. (LCY)");
                l_CLE.SetRange("Customer No.", Customer."No.");
                l_CLE.SetFilter("Posting Date", '..%1', AsofDate);
                l_CLE.SetFilter("Remaining Amount", '<>%1', 0);
                if l_CLE.FindSet() then begin
                    DocNo := NoSeriesMgt.TryGetNextNo(l_GenJnlBatch."No. Series", WorkDate());
                    repeat
                        GenJnlLine.Init();
                        GenJnlLine."Journal Template Name" := 'GENERAL';
                        GenJnlLine."Journal Batch Name" := JnlBatchName;
                        GenJnlLine."Line No." := NextLineNo;
                        GenJnlLine."Posting Date" := WorkDate();
                        GenJnlLine."Document No." := DocNo;
                        GenJnlLine.Insert();
                        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
                        GenJnlLine.validate("Account No.", l_CLE."Customer No.");
                        GenJnlLine.Description := 'ARAP Netting';
                        GenJnlLine.Validate("Currency Code", l_CLE."Currency Code");
                        GenJnlLine.Validate("Applies-to Doc. Type", l_CLE."Document Type");
                        GenJnlLine.Validate("Applies-to Doc. No.", l_CLE."Document No.");
                        GenJnlLine.Modify();
                        NextLineNo := NextLineNo + 10000;
                    until l_CLE.Next() = 0;
                end;

                l_VLE.Reset();
                l_VLE.CalcFields("Remaining Amount", "Remaining Amt. (LCY)");
                l_VLE.SetRange("Vendor No.", Customer."Netting Vendor No.");
                l_VLE.SetFilter("Posting Date", '..%1', AsofDate);
                l_VLE.SetFilter("Remaining Amount", '<>%1', 0);
                if l_VLE.FindSet() then begin
                    repeat
                        GenJnlLine.Init();
                        GenJnlLine."Journal Template Name" := 'GENERAL';
                        GenJnlLine."Journal Batch Name" := JnlBatchName;
                        GenJnlLine."Line No." := NextLineNo;
                        GenJnlLine."Posting Date" := WorkDate();
                        GenJnlLine."Document No." := DocNo;
                        GenJnlLine.Insert();
                        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Vendor;
                        GenJnlLine.validate("Account No.", l_VLE."Vendor No.");
                        GenJnlLine.Description := 'ARAP Netting';
                        GenJnlLine.Validate("Currency Code", l_VLE."Currency Code");
                        GenJnlLine.Validate("Applies-to Doc. Type", l_VLE."Document Type");
                        GenJnlLine.Validate("Applies-to Doc. No.", l_VLE."Document No.");
                        GenJnlLine.Modify();
                        NextLineNo := NextLineNo + 10000;
                    until l_VLE.Next() = 0;
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
                    field("Journal Template Batch"; JnlBatchName)
                    {
                        ApplicationArea = All;
                        TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = const('GENERAL'));
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
        myInt: Integer;
        JnlBatchName: Code[10];
        AsofDate: Date;
        NextLineNo: Integer;
        DocNo: Code[20];
        NoSeriesMgt: Codeunit NoSeriesManagement;
}