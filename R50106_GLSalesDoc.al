report 50106 "G/L Invoice"
{
    DefaultLayout = RDLC;
    RDLCLayout = './R50106_GLSalesDoc.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'G/L Sales Document';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("G/L Register"; "G/L Register")
        {
            DataItemTableView = SORTING("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";
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
                RequestFilterFields = "Document No.";

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
                column(G_L_Entry__Document_No__; "Document No.")
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
                    CurrancyFactor: Decimal;
                    l_CLE: Record "Cust. Ledger Entry"; //G006
                    l_GLE: Record "G/L Entry"; //G006

                begin
                    if not GLAcc.Get("G/L Account No.") then
                        GLAcc.Init();

                    DetailedVATAmount := "VAT Amount";

                    //G006++
                    Clear(CustAddr[1]);
                    Clear(FCYCode);
                    Clear(ARAmt);
                    Clear(CurrancyFactor);

                    TempDocLine.DeleteAll();

                    if l_CLE.Get("Entry No.") then begin

                        if g_Cust.Get("Source No.") then begin
                            FormatAddr.Customer(CustAddr[1], g_Cust);
                        end;

                        IF l_CLE."Currency Code" <> '' then
                            FCYCode := l_CLE."Currency Code"
                        Else
                            FCYCode := GLSetup."LCY Code";

                        l_CLE.CalcFields("Original Amount", "Original Amt. (LCY)");
                        CurrancyFactor := l_CLE."Original Currency Factor";

                        if l_CLE."Document Type" = l_CLE."Document Type"::Invoice then begin
                            ARAmt := l_CLE."Original Amount";

                            SalesInvoiceLine.Reset();
                            SalesInvoiceLine.SetRange("Document No.", "Document No.");
                            if SalesInvoiceLine.FindSet then begin
                                if not SalesInvoiceHeader.Get("Document No.") then
                                    exit;
                                CurrancyFactor := SetCurrancyFactor(SalesInvoiceHeader."Currency Factor");
                                repeat
                                    PopulateRecFromSalesInvoiceLine(SalesInvoiceLine, CurrancyFactor, SalesInvoiceHeader."Prices Including VAT");
                                until SalesInvoiceLine.Next() = 0;
                                exit;
                            end else begin
                                l_GLE.SetRange("Document No.", "Document No.");
                                l_GLE.SetRange("Document Type", "Document Type");
                                l_GLE.SetRange("Transaction No.", "Transaction No.");
                                l_GLE.SetFilter("Entry No.", '<>%1', "Entry No.");
                                if l_GLE.FindSet then begin
                                    repeat
                                        PopulateRecFromGLLine(l_GLE, CurrancyFactor, false);
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
                                CurrancyFactor := SetCurrancyFactor(SalesCrMemoHeader."Currency Factor");
                                repeat
                                    PopulateRecFromSalesCrMemoLine(SalesCrMemoLine, CurrancyFactor, SalesCrMemoHeader."Prices Including VAT");
                                until SalesCrMemoLine.Next() = 0;
                            end else begin
                                l_GLE.SetRange("Document No.", "Document No.");
                                l_GLE.SetRange("Document Type", "Document Type");
                                l_GLE.SetRange("Transaction No.", "Transaction No.");
                                l_GLE.SetFilter("Entry No.", '<>%1', "Entry No.");
                                if l_GLE.FindSet then begin
                                    repeat
                                        PopulateRecFromGLLine(l_GLE, CurrancyFactor, false);
                                    until l_GLE.Next() = 0;
                                end;
                            end;
                        end;
                    end else
                        CurrReport.Skip();

                    //G006--



                end;

                trigger OnPreDataItem()
                begin
                    "G/L Entry".SetRange("Entry No.", "G/L Register"."From Entry No.", "G/L Register"."To Entry No.");
                    "G/L Entry".SetFilter("Document Type", '%1|%2', "Document Type"::Invoice, "Document Type"::"Credit Memo");
                end;

            }
            trigger OnPreDataItem()
            begin
                "G/L Register".SetFilter("Source Code", '%1|%2', 'SALES', 'SALESJNL');
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
    //G006--

    trigger OnPreReport()
    begin
        GLFilter := "G/L Entry".GetFilters();
        TempPurchInvLinePrinted.DeleteAll();
        GLSetup.Get;
        CompanyInfo.Get;

        FormatAddr.Company(CompanyAddr[1], CompanyInfo);
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
    local procedure PopulateRecFromGLLine(GLLine: Record "G/L Entry"; CurrancyFactor: Decimal; PricesInclVAT: Boolean)
    begin
        TempDocLine.Init();
        TempDocLine.Description := GLLine.Description;
        TempDocLine.Amount := -GLLine.Amount;
        TempDocLine."Document No." := GLLine."Document No.";
        TempDocLine."Line No." := GLLine."Entry No.";
        TempDocLine."No." := GLLine."G/L Account No.";
        TempDocLine."Amount Including VAT" := -GLLine.Amount;
        TempDocLine."VAT Base Amount" := -GLLine.Amount;
        if not DetailsPrinted(TempDocLine) then
            TempDocLine.Insert();
    end;
    //G006--
    local procedure PopulateRecFromSalesInvoiceLine(SalesInvoiceLine: Record "Sales Invoice Line"; CurrancyFactor: Decimal; PricesInclVAT: Boolean)
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

    local procedure PopulateRecFromSalesCrMemoLine(SalesCrMemoLine: Record "Sales Cr.Memo Line"; CurrancyFactor: Decimal; PricesInclVAT: Boolean)
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

    local procedure SetCurrancyFactor(HeaderCurrancyFactor: Decimal): Decimal
    begin
        if HeaderCurrancyFactor = 0 then
            exit(1);
        exit(HeaderCurrancyFactor);
    end;
}

