report 50113 "G/L Sales Document IC"
{
    DefaultLayout = RDLC;
    RDLCLayout = './R50113_GLSalesDocIC.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'G/L Sales Document IC';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(GLRegisterIC; "G/L Register")
        {
            DataItemTableView = SORTING("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";
            dataitem(Company; Company)
            {
                DataItemTableView = sorting(Name);
                dataitem("G/L Register"; "G/L Register")
                {
                    DataItemTableView = SORTING("No.");
                    PrintOnlyIfDetail = true;
                    column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
                    {
                    }
                    column(LCYCode; GLSetup."LCY Code")
                    {
                    }
                    column(ShowLines; ShowDetails)
                    {
                    }
                    column(No_GLRegister; "No.")
                    {
                    }
                    dataitem("G/L Entry"; "G/L Entry")
                    {
                        DataItemTableView = SORTING("Entry No.") where("Source Type" = const(Customer));
                        column(G_L_Entry__Posting_Date_; Format("Posting Date", 0, '<Day,2>-<Month text,3>-<Year4>'))
                        {
                        }
                        column(DocumentDate_GLEntry; Format("Document Date", 0, '<Day,2>-<Month text,3>-<Year4>'))
                        {
                        }
                        column(TransactionNo_GLEntry; "Transaction No.")
                        {
                        }
                        column(G_L_Entry__Document_Type_; "Document Type")
                        {
                        }
                        column(G_L_Entry__Document_No__; DocNo) //G006
                        {
                        }
                        column(G_L_Entry__G_L_Account_No__; "G/L Account No.")
                        {
                        }
                        column(GLAcc_Name; GLAcc.Name)
                        {
                        }
                        column(G_L_Entry_Description; Description)
                        {
                        }
                        column(G_L_Entry__VAT_Amount_; DetailedVATAmount)
                        {
                            AutoCalcField = true;
                        }
                        //G006++
                        column(Name_CompanyInfo; CompanyInfo.Name)
                        { }
                        column(Addr_CompanyInfo; CompanyAddr[1] [2])
                        { }
                        column(Addr2_CompanyInfo; CompanyAddr[1] [3])
                        { }
                        column(PhoneNo_CompanyInfo; CompanyInfo."Phone No.")
                        { }
                        column(FaxNo_CompanyInfo; CompanyInfo."Fax No.")
                        { }
                        column(ARAmt; ARAmt)
                        { }
                        column(FCYCode; FCYCode)
                        { }
                        column(G_L_Entry__Entry_No__; "Entry No.")
                        { }
                        column(CustAddr_1__1_; CustAddr[1] [1])
                        {
                        }
                        column(CustAddr_1__2_; CustAddr[1] [2])
                        {
                        }
                        column(CustAddr_1__3_; CustAddr[1] [3])
                        {
                        }
                        column(CustAddr_1__4_; CustAddr[1] [4])
                        {
                        }
                        column(CustAddr_1__5_; CustAddr[1] [5])
                        {
                        }
                        column(CustAddr_1__6_; CustAddr[1] [6])
                        {
                        }
                        //G006-- 
                        //TempPurchInvLinePrinted
                        dataitem(PrintDocLine; "Integer")
                        {
                            DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                            column(PrintDocLine_Description; TempDocLine.Description)
                            {
                            }
                            column(PrintDocLine_Amount; TempDocLine.Amount)
                            {
                            }
                            column(PrintDocLine_Document_No_; TempDocLine."Document No.")
                            {
                            }
                            column(PrintDocLine_Line_No_; TempDocLine."Line No.")
                            {
                            }
                            column(PrintDocLine_No_; TempDocLine."No.")
                            {
                            }
                            trigger OnAfterGetRecord()
                            begin
                                if Number = 1 then begin
                                    if not TempDocLine.FindSet(false, false) then
                                        CurrReport.Break();
                                end else
                                    if TempDocLine.Next() = 0 then
                                        CurrReport.Break();
                            end;
                        }

                        trigger OnPreDataItem()
                        begin
                            if Company.Name = CompanyName() then begin
                                "G/L Entry".SetRange("Entry No.", "G/L Register"."From Entry No.", "G/L Register"."To Entry No.");
                                "G/L Entry".SetFilter("Document Type", '%1|%2', "Document Type"::Invoice, "Document Type"::"Credit Memo");
                            end else begin
                                "G/L Entry".SetRange("Entry No.", "G/L Register"."From Entry No.", "G/L Register"."To Entry No.");
                                "G/L Entry".SetFilter("Document Type", '%1|%2', "Document Type"::Invoice, "Document Type"::"Credit Memo");
                                "G/L Entry".SetFilter("IC Source Document No.", ICSourceDocNo);
                            end;
                        end;

                        trigger OnAfterGetRecord()
                        var
                            PurchInvLine: Record "Purch. Inv. Line";
                            SalesInvoiceLine: Record "Sales Invoice Line";
                            PurchCrMemoLine: Record "Purch. Cr. Memo Line";
                            SalesCrMemoLine: Record "Sales Cr.Memo Line";
                            PurchInvHeader: Record "Purch. Inv. Header";
                            PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
                            SalesInvoiceHeader: Record "Sales Invoice Header";
                            SalesCrMemoHeader: Record "Sales Cr.Memo Header";
                            CurrencyFactor: Decimal;
                            l_CLE: Record "Cust. Ledger Entry"; //G006
                            l_GLE: Record "G/L Entry"; //G006

                        begin
                            PurchInvLine.ChangeCompany(Company.Name);
                            SalesInvoiceLine.ChangeCompany(Company.Name);
                            PurchCrMemoLine.ChangeCompany(Company.Name);
                            SalesCrMemoLine.ChangeCompany(Company.Name);
                            PurchInvHeader.ChangeCompany(Company.Name);
                            PurchCrMemoHdr.ChangeCompany(Company.Name);
                            SalesInvoiceHeader.ChangeCompany(Company.Name);
                            SalesCrMemoHeader.ChangeCompany(Company.Name);
                            l_CLE.ChangeCompany(Company.Name);
                            GLAcc.ChangeCompany(Company.Name);
                            GLSetup.ChangeCompany(Company.Name);
                            l_GLE.ChangeCompany(company.Name);

                            if not GLAcc.Get("G/L Account No.") then
                                GLAcc.Init();

                            DetailedVATAmount := "VAT Amount";

                            //G006++
                            Clear(CustAddr[1]);
                            Clear(FCYCode);
                            Clear(ARAmt);
                            Clear(CurrencyFactor);
                            DocNo := "G/L Entry"."Document No.";

                            TempDocLine.DeleteAll();

                            if l_CLE.Get("Entry No.") then begin

                                if l_CLE."Pre-Assigned No." <> '' then
                                    DocNo := l_CLE."Pre-Assigned No.";

                                if g_Cust.Get("Source No.") then begin
                                    FormatAddr.Customer(CustAddr[1], g_Cust);
                                end;

                                IF l_CLE."Currency Code" <> '' then
                                    FCYCode := l_CLE."Currency Code"
                                Else
                                    FCYCode := GLSetup."LCY Code";

                                l_CLE.CalcFields("Original Amount", "Original Amt. (LCY)");
                                CurrencyFactor := l_CLE."Original Currency Factor";

                                if l_CLE."Document Type" = l_CLE."Document Type"::Invoice then begin
                                    ARAmt := l_CLE."Original Amount";

                                    SalesInvoiceLine.Reset();
                                    SalesInvoiceLine.SetRange("Document No.", "Document No.");
                                    if SalesInvoiceLine.FindSet then begin
                                        if not SalesInvoiceHeader.Get("Document No.") then
                                            exit;
                                        CurrencyFactor := SetCurrencyFactor(SalesInvoiceHeader."Currency Factor");
                                        repeat
                                            PopulateRecFromSalesInvoiceLine(SalesInvoiceLine, CurrencyFactor, SalesInvoiceHeader."Prices Including VAT");
                                        until SalesInvoiceLine.Next() = 0;
                                        exit;
                                    end else begin
                                        l_GLE.SetRange("Document No.", "Document No.");
                                        l_GLE.SetRange("Document Type", "Document Type");
                                        l_GLE.SetRange("Transaction No.", "Transaction No.");
                                        l_GLE.SetFilter("Entry No.", '<>%1', "Entry No.");
                                        if l_GLE.FindSet then begin
                                            repeat
                                                PopulateRecFromGLLine(l_GLE, CurrencyFactor, false);
                                            until l_GLE.Next() = 0;
                                        end;
                                    end;
                                end;

                                if l_CLE."Document Type" = l_CLE."Document Type"::"Credit Memo" then begin
                                    ARAmt := -l_CLE."Original Amount";

                                    SalesCrMemoLine.Reset();
                                    SalesCrMemoLine.SetRange("Document No.", "Document No.");
                                    if SalesCrMemoLine.FindSet then begin
                                        if not SalesCrMemoHeader.Get("Document No.") then
                                            exit;
                                        CurrencyFactor := SetCurrencyFactor(SalesCrMemoHeader."Currency Factor");
                                        repeat
                                            PopulateRecFromSalesCrMemoLine(SalesCrMemoLine, CurrencyFactor, SalesCrMemoHeader."Prices Including VAT");
                                        until SalesCrMemoLine.Next() = 0;
                                    end else begin
                                        l_GLE.SetRange("Document No.", "Document No.");
                                        l_GLE.SetRange("Document Type", "Document Type");
                                        l_GLE.SetRange("Transaction No.", "Transaction No.");
                                        l_GLE.SetFilter("Entry No.", '<>%1', "Entry No.");
                                        if l_GLE.FindSet then begin
                                            repeat
                                                PopulateRecFromGLLine(l_GLE, CurrencyFactor, false);
                                            until l_GLE.Next() = 0;
                                        end;
                                    end;
                                end;
                            end else
                                CurrReport.Skip();

                            //G006--

                        end;

                    }

                    trigger OnPreDataItem()
                    var
                        l_GLEntry: Record "G/L Entry";
                    begin
                        "G/L Register".ChangeCompany(Company.Name);
                        "G/L Entry".ChangeCompany(Company.Name);
                        if Company.Name = CompanyName() then begin
                            "G/L Register".CopyFilters(GLRegisterIC);
                        end
                        else begin
                            l_GLEntry.ChangeCompany(Company.Name);
                            l_GLEntry.Reset();
                            l_GLEntry.SetRange("IC Source Document No.", ICSourceDocNo);
                            if l_GLEntry.FindFirst() then begin
                                "G/L Register".SetFilter("From Entry No.", '<=%1', l_GLEntry."Entry No.");
                                "G/L Register".SetFilter("To Entry No.", '>=%1', l_GLEntry."Entry No.");
                            end else begin
                                "G/L Register".SetFilter("From Entry No.", '<=%1', 0);
                                "G/L Register".SetFilter("To Entry No.", '>=%1', 0);
                            end;
                        end;
                        "G/L Register".SetFilter("Source Code", '%1|%2|%3', 'SALES', 'SALESJNL', 'GENJNL'); //IC entries post from General Journal
                    end;
                }

                trigger OnPreDataItem()
                var
                    l_GLEntry: Record "G/L Entry";
                    l_Company: Record "Company";
                    ICPath: Record "IC Transaction Path Details";
                    CompanyFilter: Text;
                    B_FinishedPosting: Boolean;
                    Cnt: Integer;
                begin
                    CompanyFilter := CompanyName();
                    l_GLEntry.Reset();
                    l_GLEntry.SetRange("Entry No.", GLRegisterIC."From Entry No.", GLRegisterIC."To Entry No.");
                    l_GLEntry.SetFilter("IC Path Code", '<>%1', '');
                    if l_GLEntry.FindFirst() then begin
                        ICSourceDocNo := l_GLEntry."Pre-Assigned No.";
                        ICPath.Reset();
                        ICPath.SetRange("Path Code", l_GLEntry."IC Path Code");
                        if ICPath.FindSet() then
                            repeat
                                CompanyFilter := CompanyFilter + '|' + ICPath."To Company";
                            until ICPath.next = 0;
                    end;
                    Company.SetFilter(Name, CompanyFilter);
                    Cnt := 0;

                    repeat
                        Cnt := Cnt + 1;
                        B_FinishedPosting := true;
                        l_Company.Reset();
                        l_Company.SetFilter(Name, Copystr(CompanyFilter, StrPOS(CompanyFilter, '|') + 1));
                        if l_Company.FindSet() then
                            repeat
                                l_GLEntry.ChangeCompany(l_Company.Name);
                                l_GLEntry.Reset();
                                l_GLEntry.SetRange("IC Source Document No.", ICSourceDocNo);
                                if not l_GLEntry.FindFirst() then begin
                                    B_FinishedPosting := false;
                                    Sleep(2000);
                                end;
                            until l_Company.Next() = 0;
                    until B_FinishedPosting or (Cnt >= 10);
                end;

                trigger OnAfterGetRecord()
                begin
                    CompanyInfo.ChangeCompany(Company.Name);
                    CompanyInfo.Get;
                    FormatAddr.Company(CompanyAddr[1], CompanyInfo);
                end;
            }

            trigger OnPreDataItem()
            var
                l_GLEntry: Record "G/L Entry";
            begin
                if FilterDocNo <> '' then begin
                    l_GLEntry.Reset();
                    l_GLEntry.SetRange("Document No.", FilterDocNo);
                    if l_GLEntry.FindFirst() then begin
                        GLRegisterIC.SetFilter("From Entry No.", '<=%1', l_GLEntry."Entry No.");
                        GLRegisterIC.SetFilter("To Entry No.", '>=%1', l_GLEntry."Entry No.");
                    end else
                        Error('No G/L entries found for %1. Adjust your filters and try again.', FilterDocNo);
                end;
            end;

        }

    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Control3)
                {
                    Caption = 'Options';
                    field("IC Document No."; FilterDocNo)
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field(ShowDetails; ShowDetails)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show details';
                        ToolTip = 'Specifies if the report displays all lines in detail.';
                        Visible = false; //G006
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        FilterDocNo: Code[20];
        ICSourceDocNo: Code[20];
        GLSetup: Record "General Ledger Setup";
        GLAcc: Record "G/L Account";
        TempPurchInvLinePrinted: Record "Purch. Inv. Line" temporary;
        GLFilter: Text;
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        ShowDetails: Boolean;
        DetailedVATAmount: Decimal;
        //G006++
        TempDocLine: Record "Purch. Inv. Line" temporary;
        FCYCode: Code[10];
        ARAmt: Decimal;
        g_Cust: Record Customer;
        FormatAddr: Codeunit "Format Address";
        CustAddr: array[1, 8] of Text[100];
        CompanyAddr: array[1, 8] of Text[100];
        CompanyInfo: Record "Company Information";
        DocNo: Code[20];
    //G006--

    trigger OnPreReport()
    begin
        GLFilter := "G/L Entry".GetFilters();
        TempPurchInvLinePrinted.DeleteAll();
        GLSetup.Get;
    end;

    local procedure DetailsPrinted(PurchInvLine: Record "Purch. Inv. Line"): Boolean
    begin
        if TempPurchInvLinePrinted.get(PurchInvLine."Document No.", PurchInvLine."Line No.") then
            exit(true);
        TempPurchInvLinePrinted."Document No." := PurchInvLine."Document No.";
        TempPurchInvLinePrinted."Line No." := PurchInvLine."Line No.";
        TempPurchInvLinePrinted."No." := PurchInvLine."No.";
        TempPurchInvLinePrinted.Description := PurchInvLine.Description;
        TempPurchInvLinePrinted.Amount := PurchInvLine.Amount;
        TempPurchInvLinePrinted.Insert();
    end;
    //G006++
    local procedure PopulateRecFromGLLine(GLLine: Record "G/L Entry"; CurrencyFactor: Decimal; PricesInclVAT: Boolean)
    begin
        TempDocLine.Init();
        TempDocLine.Description := GLLine.Description;
        TempDocLine."Document No." := GLLine."Document No.";
        TempDocLine."Line No." := GLLine."Entry No.";
        TempDocLine."No." := GLLine."G/L Account No.";
        if GLLine."Document Type" = GLLine."Document Type"::Invoice then begin
            TempDocLine.Amount := -GLLine.Amount * CurrencyFactor;
            TempDocLine."Amount Including VAT" := -GLLine.Amount * CurrencyFactor;
            TempDocLine."VAT Base Amount" := -GLLine.Amount * CurrencyFactor;
        end else
            if GLLine."Document Type" = GLLine."Document Type"::"Credit Memo" then begin
                TempDocLine.Amount := GLLine.Amount * CurrencyFactor;
                TempDocLine."Amount Including VAT" := GLLine.Amount * CurrencyFactor;
                TempDocLine."VAT Base Amount" := GLLine.Amount * CurrencyFactor;
            end;

        // if not DetailsPrinted(TempDocLine) then
        TempDocLine.Insert();
    end;
    //G006--
    local procedure PopulateRecFromSalesInvoiceLine(SalesInvoiceLine: Record "Sales Invoice Line"; CurrencyFactor: Decimal; PricesInclVAT: Boolean)
    begin
        TempDocLine.Init();
        TempDocLine.Description := SalesInvoiceLine.Description;
        TempDocLine.Amount := SalesInvoiceLine."Amount Including VAT";
        TempDocLine."Document No." := SalesInvoiceLine."Document No.";
        TempDocLine."Line No." := SalesInvoiceLine."Line No.";
        TempDocLine."No." := SalesInvoiceLine."No.";
        TempDocLine."VAT Base Amount" := -SalesInvoiceLine."VAT Base Amount";
        if not DetailsPrinted(TempDocLine) then
            TempDocLine.Insert();
    end;

    local procedure PopulateRecFromSalesCrMemoLine(SalesCrMemoLine: Record "Sales Cr.Memo Line"; CurrencyFactor: Decimal; PricesInclVAT: Boolean)
    begin
        TempDocLine.Init();
        TempDocLine.Description := SalesCrMemoLine.Description;
        TempDocLine.Amount := SalesCrMemoLine."Amount Including VAT";
        TempDocLine."Document No." := SalesCrMemoLine."Document No.";
        TempDocLine."Line No." := SalesCrMemoLine."Line No.";
        TempDocLine."No." := SalesCrMemoLine."No.";
        TempDocLine."VAT Base Amount" := SalesCrMemoLine."VAT Base Amount";
        if not DetailsPrinted(TempDocLine) then
            TempDocLine.Insert();
    end;

    local procedure SetCurrencyFactor(HeaderCurrencyFactor: Decimal): Decimal
    begin
        if HeaderCurrencyFactor = 0 then
            exit(1);
        exit(HeaderCurrencyFactor);
    end;
}

