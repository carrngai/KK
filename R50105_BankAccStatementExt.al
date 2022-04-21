report 50105 "Bank Account Statement Ext"
{
    DefaultLayout = RDLC;
    RDLCLayout = './R50105_BankAccStatementExt.rdl';
    Caption = 'Bank Account Statement';

    dataset
    {
        dataitem("Bank Account Statement"; "Bank Account Statement")
        {
            DataItemTableView = SORTING("Bank Account No.", "Statement No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "Bank Account No.", "Statement No.";
            column(ComanyName; COMPANYPROPERTY.DisplayName)
            {
            }
            column(BankAccStmtTableCaptFltr; TableCaption + ': ' + BankAccStmtFilter)
            {
            }
            column(BankAccStmtFilter; BankAccStmtFilter)
            {
            }
            column(StmtNo_BankAccStmt; "Statement No.")
            {
                IncludeCaption = true;
            }
            column(Amt_BankAccStmtLineStmt; "Bank Account Statement Line"."Statement Amount")
            {
            }
            column(AppliedAmt_BankAccStmtLine; "Bank Account Statement Line"."Applied Amount")
            {
            }
            column(BankAccNo_BankAccStmt; "Bank Account No.")
            {
            }
            column(BankAccStmtCapt; BankAccStmtCaptLbl)
            {
            }
            column(CurrReportPAGENOCapt; CurrReportPAGENOCaptLbl)
            {
            }
            column(BnkAccStmtLinTrstnDteCapt; BnkAccStmtLinTrstnDteCaptLbl)
            {
            }
            column(BnkAcStmtLinValDteCapt; BnkAcStmtLinValDteCaptLbl)
            {
            }
            column(Statement_Date; FORMAT("Statement Date", 0, '<Day,2> <Month text,3> <Year4>')) //G004
            {
            }
            column(LastStatement_Date; FORMAT(LastStatementDate, 0, '<Day,2> <Month text,3> <Year4>')) //G004
            {
            }

            column(StatementEndingBalance; "Statement Ending Balance") //G004
            {
            }
            column(LedgerBalance; BankAcc."Balance at Date") //G004
            {

            }
            column(CurrecnyCode; BankAcc."Currency Code") //G004
            {

            }
            dataitem("Bank Account Statement Line"; "Bank Account Statement Line")
            {
                DataItemLink = "Bank Account No." = FIELD("Bank Account No."), "Statement No." = FIELD("Statement No.");
                DataItemTableView = SORTING("Bank Account No.", "Statement No.", "Statement Line No.");
                column(TrnsctnDte_BnkAcStmtLin; Format("Transaction Date", 0, '<Day,2><Month text,3><Year4>'))
                {
                }
                column(Type_BankAccStmtLine; Type)
                {
                    IncludeCaption = true;
                }
                column(LineDocNo_BankAccStmt; "Document No.")
                {
                    IncludeCaption = true;
                }
                column(AppliedEntr_BankAccStmtLine; "Applied Entries")
                {
                    IncludeCaption = true;
                }
                column(Amt1_BankAccStmtLineStmt; "Statement Amount")
                {
                    IncludeCaption = true;
                }
                column(AppliedAmt1_BankAccStmtLine; "Applied Amount")
                {
                    IncludeCaption = true;
                }
                column(Desc_BankAccStmtLine; Description)
                {
                    IncludeCaption = true;
                }
                column(ValueDate_BankAccStmtLine; Format("Value Date"))
                {
                }

            }

            dataitem(BLE; "Bank Account Ledger Entry")
            {
                DataItemLink = "Bank Account No." = field("Bank Account no.");
                column(PostingDate_BLE; format("Posting Date", 0, '<Day,2><Month text,3><Year4>'))
                {
                }
                column(DocumentNo_BLE; "Document No.")
                {
                }
                column(ExternalDocumentNo_BLE; "External Document No.")
                {
                }
                column(Description_BLE; Description)
                {
                }
                column(Amount_BLE; Amount)
                {
                }
                column(StatementNo_BLE; "Statement No.")
                {
                }
                column(AddAmt; AddAmt)
                { }
                column(LessAmt; LessAmt)
                { }
                column(IsAdd; IsAdd)
                { }
                column(IsLess; IsLess)
                { }
                trigger OnPreDataItem()
                begin
                    BLE.SetFilter("Posting Date", '%1..%2', LastStatementDate + 1, "Bank Account Statement"."Statement Date");
                    BLE.SetFilter("Statement No.", '<>%1', "Bank Account Statement"."Statement No.");
                end;

                trigger OnAfterGetRecord()
                begin
                    Clear(AddAmt);
                    Clear(LessAmt);
                    Clear(IsAdd);
                    Clear(IsLess);

                    if BLE.Amount > 0 then begin
                        ;
                        LessAmt := BLE.Amount;
                        IsLess := true;
                    end else begin
                        AddAmt := -BLE.Amount;
                        IsAdd := true;
                    end;

                end;
            }

            trigger OnAfterGetRecord()
            begin

                LastBankStatement.Reset();
                LastBankStatement.SetRange("Bank Account No.", "Bank Account No.");
                LastBankStatement.SetFilter("Statement Date", '..%1', "Statement Date" - 1);
                LastBankStatement.SetAscending("Statement No.", false);
                if LastBankStatement.FindFirst() then
                    LastStatementDate := LastBankStatement."Statement Date"
                else
                    LastStatementDate := 20000101D;

                if BankAcc.Get("Bank Account No.") then begin
                    BankAcc.SetFilter("Date Filter", '..%1', "Statement Date");
                    BankAcc.CalcFields("Balance at Date");
                    if BankAcc."Currency Code" <> '' then
                        CurrCode := BankAcc."Currency Code"
                    else
                        CurrCode := GLSetup."LCY Code";
                end;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
        TotalCaption = 'Total';
    }

    trigger OnPreReport()
    begin
        BankAccStmtFilter := "Bank Account Statement".GetFilters;
        GLSetup.Get();
    end;

    var
        BankAccStmtFilter: Text;
        BankAccStmtCaptLbl: Label 'Bank Account Statement';
        CurrReportPAGENOCaptLbl: Label 'Page';
        BnkAccStmtLinTrstnDteCaptLbl: Label 'Transaction Date';
        BnkAcStmtLinValDteCaptLbl: Label 'Value Date';
        //G004++
        BankAcc: Record "Bank Account";
        LastBankStatement: Record "Bank Account Statement";
        LastStatementDate: Date;
        CurrCode: Code[10];
        GLSetup: Record "General Ledger Setup";
        LessAmt: Decimal;
        AddAmt: Decimal;

        IsAdd: Boolean;
        IsLess: Boolean;

    //G004--
}

