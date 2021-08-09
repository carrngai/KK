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
                GenJnlLine: Record "Gen. Journal Line";

            begin

                GenJnlLine.Reset();
                GenJnlLine.SetRange("Journal Template Name", JnlTemplate.Name);
                GenJnlLine.SetRange("Journal Batch Name", JnlBatch.Name);
                if GenJnlLine.FindLast() then
                    NextLineNo := GenJnlLine."Line No." + 10000
                else
                    NextLineNo := 10000;

                l_CLE.Reset();
                l_CLE.SetRange("Customer No.", Customer."No.");
                l_CLE.SetFilter("Posting Date", '..%1', AsofDate);
                if l_CLE.FindSet() then begin
                    DocNo := NoSeriesMgt.TryGetNextNo(JnlBatch."No. Series", WorkDate());
                    repeat
                        GenJnlLine.Init();
                        GenJnlLine."Journal Template Name" := JnlTemplate.Name;
                        GenJnlLine."Journal Batch Name" := JnlBatch.Name;
                        GenJnlLine."Line No." := NextLineNo;
                        GenJnlLine."Posting Date" := WorkDate();
                        GenJnlLine."Document No." := DocNo;
                        GenJnlLine.Insert();
                        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
                        GenJnlLine.validate("Account No.", l_CLE."Customer No.");
                        GenJnlLine.Description := 'ARAP Netting';
                        GenJnlLine."Currency Code" := l_CLE."Currency Code";
                        GenJnlLine.Validate(Amount, -l_CLE."Remaining Amount");
                        GenJnlLine.Validate("Amount (LCY)", -l_CLE."Remaining Amt. (LCY)");
                        GenJnlLine."Applies-to Doc. Type" := l_CLE."Document Type";
                        GenJnlLine."Applies-to Doc. No." := l_CLE."Document No.";
                        NextLineNo := NextLineNo + 10000;
                    until l_CLE.Next() = 0;
                end;

                l_VLE.Reset();
                l_VLE.SetRange("Vendor No.", Customer."Netting Vendor No.");
                l_VLE.SetFilter("Posting Date", '..%1', AsofDate);
                if l_VLE.FindSet() then begin
                    repeat
                        GenJnlLine.Init();
                        GenJnlLine."Journal Template Name" := JnlTemplate.Name;
                        GenJnlLine."Journal Batch Name" := JnlBatch.Name;
                        GenJnlLine."Line No." := NextLineNo;
                        GenJnlLine."Posting Date" := WorkDate();
                        GenJnlLine."Document No." := DocNo;
                        GenJnlLine.Insert();
                        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
                        GenJnlLine.validate("Account No.", l_VLE."Vendor No.");
                        GenJnlLine.Description := 'ARAP Netting';
                        GenJnlLine."Currency Code" := l_VLE."Currency Code";
                        GenJnlLine.Validate(Amount, -l_VLE."Remaining Amount");
                        GenJnlLine.Validate("Amount (LCY)", -l_VLE."Remaining Amt. (LCY)");
                        GenJnlLine."Applies-to Doc. Type" := l_VLE."Document Type";
                        GenJnlLine."Applies-to Doc. No." := l_VLE."Document No.";
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
                    field("Journal Template Name"; JnlTemplate.Name)
                    {
                        ApplicationArea = All;
                    }
                    field("Journal Template Batch"; JnlBatch.Name)
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
        myInt: Integer;
        JnlTemplate: Record "Gen. Journal Template";
        JnlBatch: Record "Gen. Journal Batch";
        AsofDate: Date;
        NextLineNo: Integer;
        DocNo: Code[20];
        NoSeriesMgt: Codeunit NoSeriesManagement;
}