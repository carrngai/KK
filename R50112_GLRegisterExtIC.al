report 50112 "G/L Register Ext IC"
{
    DefaultLayout = RDLC;
    RDLCLayout = './R50112_GLRegisterExtIC.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'G/L Register Ext IC';
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
                    column(COMPANYNAME; Company."Display Name")
                    {
                    }
                    column(LCYCode; GLSetup."LCY Code")
                    {
                    }
                    column(ShowLines; ShowDetails)
                    {
                    }
                    column(G_L_Register__TABLECAPTION__________GLRegFilter; TableCaption + ': ' + GLRegFilter)
                    {
                    }
                    column(GLRegFilter; GLRegFilter)
                    {
                    }
                    column(G_L_Register__No__; "No.")
                    {
                    }
                    column(G_L_RegisterCaption; G_L_RegisterCaptionLbl)
                    {
                    }
                    column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
                    {
                    }
                    column(G_L_Entry__Posting_Date_Caption; G_L_Entry__Posting_Date_CaptionLbl)
                    {
                    }
                    column(G_L_Entry__Document_Type_Caption; G_L_Entry__Document_Type_CaptionLbl)
                    {
                    }
                    column(G_L_Entry__Document_No__Caption; "G/L Entry".FieldCaption("Document No."))
                    {
                    }
                    column(G_L_Entry__G_L_Account_No__Caption; "G/L Entry".FieldCaption("G/L Account No."))
                    {
                    }
                    column(GLAcc_NameCaption; GLAcc_NameCaptionLbl)
                    {
                    }
                    column(G_L_Entry_DescriptionCaption; "G/L Entry".FieldCaption(Description))
                    {
                    }
                    column(G_L_Entry__VAT_Amount_Caption; "G/L Entry".FieldCaption("VAT Amount"))
                    {
                    }
                    column(G_L_Entry__Gen__Posting_Type_Caption; G_L_Entry__Gen__Posting_Type_CaptionLbl)
                    {
                    }
                    column(G_L_Entry__Gen__Bus__Posting_Group_Caption; G_L_Entry__Gen__Bus__Posting_Group_CaptionLbl)
                    {
                    }
                    column(G_L_Entry__Gen__Prod__Posting_Group_Caption; G_L_Entry__Gen__Prod__Posting_Group_CaptionLbl)
                    {
                    }
                    column(G_L_Entry_AmountCaption; "G/L Entry".FieldCaption(Amount))
                    {
                    }
                    column(G_L_Entry__Entry_No__Caption; "G/L Entry".FieldCaption("Entry No."))
                    {
                    }
                    column(G_L_Register__No__Caption; G_L_Register__No__CaptionLbl)
                    {
                    }
                    column(TotalCaption; TotalCaptionLbl)
                    {
                    }
                    column(ShowPostingGroup; ShowPostingGroup)//G003
                    {
                    }
                    dataitem("G/L Entry"; "G/L Entry")
                    {
                        DataItemTableView = SORTING("Entry No.");
                        column(G_L_Entry__Posting_Date_; Format("Posting Date", 0, '<Day,2><Month text,3><Year4>'))
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
                        column(G_L_Entry__Gen__Posting_Type_; "Gen. Posting Type")
                        {
                        }
                        // column(G_L_Entry__Gen__Bus__Posting_Group_; "Gen. Bus. Posting Group")
                        column(G_L_Entry__Gen__Bus__Posting_Group_; "VAT Bus. Posting Group") //G003
                        {
                        }
                        // column(G_L_Entry__Gen__Prod__Posting_Group_; "Gen. Prod. Posting Group")
                        column(G_L_Entry__Gen__Prod__Posting_Group_; "VAT Prod. Posting Group") //G003
                        {
                        }
                        column(G_L_Entry_Amount; Amount)
                        {
                        }
                        column(DrAmt; DrAmt) //G003
                        {
                        }
                        column(CrAmt; CrAmt) //G003
                        {
                        }
                        column(TransNo; "G/L Entry"."Transaction No.") //G003
                        {
                        }
                        column(ShowApplied; ShowApplied) //G003
                        {

                        }
                        column(FCYCode; FCYCode) //G003
                        {
                        }
                        column(ExchRate; ExchRate) //G003
                        {
                        }
                        column(G_L_Entry__Entry_No__; "Entry No.")
                        {
                        }
                        column(G_L_Entry_Amount_Control41; Amount)
                        {
                        }
                        column(G_L_Entry_Amount_Control41Caption; G_L_Entry_Amount_Control41CaptionLbl)
                        {
                        }
                        column(ICPathCode_GLEntry; "IC Path Code")
                        {
                        }

                        dataitem("Purch. Inv. Line"; "Purch. Inv. Line")
                        {
                            DataItemLink = "Document No." = FIELD("Document No."), "No." = FIELD("G/L Account No.");
                            DataItemTableView = sorting("Document No.", "Line No.");
                            UseTemporary = true;
                            column(Purch__Inv__Line_Description; Description)
                            {
                            }
                            column(Purch__Inv__Line_Amount; Amount)
                            {
                            }
                            column(Purch__Inv__Line_Document_No_; "Document No.")
                            {
                            }
                            column(Purch__Inv__Line_Line_No_; "Line No.")
                            {
                            }
                            column(Purch__Inv__Line_No_; "No.")
                            {
                            }
                            trigger OnAfterGetRecord()
                            begin
                                DetailedVATAmount := "Amount Including VAT" - "VAT Base Amount";
                            end;
                        }
                        dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry") //G003
                        {
                            DataItemLink = "Entry No." = FIELD("Entry No.");
                            DataItemTableView = sorting("Entry No.");

                            dataitem("Detailed Cust. Ledg. Entry"; "Detailed Cust. Ledg. Entry")
                            {
                                DataItemTableView = WHERE("Unapplied" = CONST(false));
                                DataItemLink = "Applied Cust. Ledger Entry No." = FIELD("Entry No.");
                                dataitem(AppliedCLE; "Cust. Ledger Entry")
                                {
                                    DataItemTableView = WHERE("Document Type" = FILTER(<> Payment));
                                    DataItemLink = "Entry No." = FIELD("Cust. Ledger Entry No.");
                                    column(DocumentNo_AppliedCLE; "Document No.")
                                    {
                                    }
                                    column(ExternalDocumentNo_AppliedCLE; "External Document No.")
                                    {
                                    }
                                    column(Description_AppliedCLE; Description)
                                    {
                                    }
                                    column(CurrencyCode_AppliedCLE; "Currency Code")
                                    {
                                    }
                                    column(Amount_AppliedCLE; -1 * "Detailed Cust. Ledg. Entry".Amount)
                                    {
                                    }
                                    column(AmountLCY_AppliedCLE; -1 * "Detailed Cust. Ledg. Entry"."Amount (LCY)")
                                    {
                                    }
                                    trigger OnPreDataItem()
                                    begin
                                        if "G/L Entry"."Source Type" <> "G/L Entry"."Source Type"::Customer then
                                            CurrReport.Break();
                                    end;
                                }

                                trigger OnPreDataItem()
                                begin
                                    "Detailed Cust. Ledg. Entry".SetFilter("Cust. Ledger Entry No.", '<>%1', "Cust. Ledger Entry"."Entry No.");
                                end;
                            }

                            // trigger OnAfterGetRecord()
                            // begin
                            //     if ("Cust. Ledger Entry"."Document Type" = "Cust. Ledger Entry"."Document Type"::Invoice) OR ("Cust. Ledger Entry"."Document Type" = "Cust. Ledger Entry"."Document Type"::"Credit Memo") then
                            //         PrintSalesDoc := true;
                            // end;
                        }
                        dataitem("Vendor Ledger Entry"; "Vendor Ledger Entry") //G003
                        {
                            DataItemLink = "Entry No." = FIELD("Entry No.");
                            DataItemTableView = sorting("Entry No.");

                            dataitem("Detailed Vendor Ledg. Entry"; "Detailed Vendor Ledg. Entry")
                            {
                                DataItemTableView = WHERE("Unapplied" = CONST(false));
                                DataItemLink = "Applied Vend. Ledger Entry No." = FIELD("Entry No.");
                                dataitem(AppliedVLE; "Vendor Ledger Entry")
                                {
                                    DataItemTableView = WHERE("Document Type" = FILTER(<> Payment));
                                    DataItemLink = "Entry No." = FIELD("Vendor Ledger Entry No.");
                                    column(DocumentNo_AppliedVLE; "Document No.")
                                    {
                                    }
                                    column(ExternalDocumentNo_AppliedVLE; "External Document No.")
                                    {
                                    }
                                    column(Description_AppliedVLE; Description)
                                    {
                                    }
                                    column(CurrencyCode_AppliedVLE; "Currency Code")
                                    {
                                    }
                                    column(Amount_AppliedVLE; -1 * "Detailed Vendor Ledg. Entry".Amount)
                                    {
                                    }
                                    column(AmountLCY_AppliedVLE; -1 * "Detailed Vendor Ledg. Entry"."Amount (LCY)")
                                    {
                                    }
                                    trigger OnPreDataItem()
                                    begin
                                        if "G/L Entry"."Source Type" <> "G/L Entry"."Source Type"::Vendor then
                                            CurrReport.Break();
                                    end;
                                }
                                trigger OnPreDataItem()
                                begin
                                    "Detailed Vendor Ledg. Entry".SetFilter("Vendor Ledger Entry No.", '<>%1', "Vendor Ledger Entry"."Entry No.");
                                end;
                            }

                        }

                        dataitem(DimensionLoop; "Integer") //G003
                        {
                            DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                            column(DimText; DimText)
                            {
                            }
                            column(Number_DimensionLoop; Number)
                            {
                            }
                            column(DimensionsCaption; DimensionsCap)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if Number = 1 then begin
                                    if not DimSetEntry.FindSet then
                                        CurrReport.Break();
                                end else
                                    if not Continue then
                                        CurrReport.Break();

                                DimText := GetDimensionText(DimSetEntry);
                            end;

                            trigger OnPreDataItem()
                            begin
                                if not ShowDim then
                                    CurrReport.Break();
                                DimSetEntry.Reset();
                                DimSetEntry.SetRange("Dimension Set ID", "G/L Entry"."Dimension Set ID")
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
                            l_CLE: Record "Cust. Ledger Entry";         //G003
                            l_VLE: Record "Vendor Ledger Entry";        //G003
                            l_BLE: Record "Bank Account Ledger Entry";  //G003

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
                            l_VLE.ChangeCompany(Company.Name);
                            l_BLE.ChangeCompany(Company.Name);
                            GLAcc.ChangeCompany(Company.Name);
                            GLSetup.ChangeCompany(Company.Name);

                            if not GLAcc.Get("G/L Account No.") then
                                GLAcc.Init();

                            DetailedVATAmount := "VAT Amount";

                            //G003++
                            Clear(FCYCode);
                            Clear(DrAmt);
                            Clear(CrAmt);
                            Clear(ExchRate);

                            if LastTransNo <> "G/L Entry"."Transaction No." then
                                Clear(ShowApplied);

                            LastTransNo := "G/L Entry"."Transaction No.";

                            FCYCode := GLSetup."LCY Code";
                            ExchRate := 1;
                            DrAmt := "G/L Entry"."Debit Amount";
                            CrAmt := "G/L Entry"."Credit Amount";

                            if "Source Type" = "Source Type"::"Bank Account" then begin
                                if l_BLE.Get("Entry No.") then begin
                                    if l_BLE."Currency Code" <> '' then
                                        FCYCode := l_BLE."Currency Code";
                                    if l_BLE.Amount > 0 then
                                        DrAmt := l_BLE.Amount
                                    else
                                        CrAmt := -l_BLE.Amount;
                                    if (l_BLE.Amount <> 0) and (l_BLE."Amount (LCY)" <> 0) then
                                        ExchRate := l_BLE."Amount (LCY)" / l_BLE.Amount;
                                end;
                            end;

                            if "Source Type" = "Source Type"::Customer then begin
                                if l_CLE.Get("Entry No.") then begin

                                    l_CLE.CalcFields("Original Amount", "Original Amt. (LCY)", "Remaining Amount", Amount);

                                    if l_CLE."Currency Code" <> '' then
                                        FCYCode := l_CLE."Currency Code";

                                    if l_CLE."Original Amount" > 0 then
                                        DrAmt := l_CLE."Original Amount"
                                    else
                                        CrAmt := -l_CLE."Original Amount";

                                    if (l_CLE."Original Amount" <> 0) and (l_CLE."Original Amt. (LCY)" <> 0) then
                                        ExchRate := l_CLE."Original Amt. (LCY)" / l_CLE."Original Amount";

                                    if (l_CLE."Original Amount" < 0) and (l_CLE."Remaining Amount" <> l_CLE.Amount) then
                                        ShowApplied := true;

                                    if (l_CLE."Document Type" = l_CLE."Document Type"::Invoice) or (l_CLE."Document Type" = l_CLE."Document Type"::"Credit Memo") then
                                        PrintSalesDoc := true;
                                end;
                            end;

                            if "Source Type" = "Source Type"::Vendor then begin
                                if l_VLE.Get("Entry No.") then begin
                                    l_VLE.CalcFields("Original Amount", "Original Amt. (LCY)", "Remaining Amount", Amount);

                                    if l_VLE."Currency Code" <> '' then
                                        FCYCode := l_VLE."Currency Code";

                                    if l_VLE."Original Amount" > 0 then
                                        DrAmt := l_VLE."Original Amount"
                                    else
                                        CrAmt := -l_VLE."Original Amount";
                                    if (l_VLE."Original Amount" <> 0) and (l_VLE."Original Amt. (LCY)" <> 0) then
                                        ExchRate := l_VLE."Original Amt. (LCY)" / l_VLE."Original Amount";

                                    if (l_VLE."Original Amount" > 0) and (l_VLE."Remaining Amount" <> l_VLE.Amount) then
                                        ShowApplied := true;
                                end;
                            end;

                            //G003--

                            if not ShowDetails then
                                exit;

                            "Purch. Inv. Line".DeleteAll();

                            PurchInvLine.SetRange("Document No.", "Document No.");
                            PurchInvLine.SetRange("No.", "G/L Account No.");
                            PurchInvLine.SetRange("VAT Prod. Posting Group", "VAT Prod. Posting Group");
                            if PurchInvLine.FindSet then begin
                                if not PurchInvHeader.Get("Document No.") then
                                    exit;
                                CurrancyFactor := SetCurrancyFactor(PurchInvHeader."Currency Factor");
                                Amount := 0;
                                repeat
                                    PopulateRecFromPurchInvLine(PurchInvLine, CurrancyFactor, PurchInvHeader."Prices Including VAT");
                                until PurchInvLine.Next() = 0;
                                exit;
                            end;

                            PurchCrMemoLine.SetRange("Document No.", "Document No.");
                            PurchCrMemoLine.SetRange("No.", "G/L Account No.");
                            PurchCrMemoLine.SetRange("VAT Prod. Posting Group", "VAT Prod. Posting Group");
                            if PurchCrMemoLine.FindSet then begin
                                if not PurchCrMemoHdr.Get("Document No.") then
                                    exit;
                                CurrancyFactor := SetCurrancyFactor(PurchCrMemoHdr."Currency Factor");
                                Amount := 0;
                                repeat
                                    PopulateRecFromPurchCrMemoLine(PurchCrMemoLine, CurrancyFactor, PurchCrMemoHdr."Prices Including VAT");
                                until PurchCrMemoLine.Next() = 0;
                                exit;
                            end;

                            SalesInvoiceLine.SetRange("Document No.", "Document No.");
                            SalesInvoiceLine.SetRange("No.", "G/L Account No.");
                            SalesInvoiceLine.SetRange("VAT Prod. Posting Group", "VAT Prod. Posting Group");
                            if SalesInvoiceLine.FindSet then begin
                                if not SalesInvoiceHeader.Get("Document No.") then
                                    exit;
                                CurrancyFactor := SetCurrancyFactor(SalesInvoiceHeader."Currency Factor");
                                Amount := 0;
                                repeat
                                    PopulateRecFromSalesInvoiceLine(SalesInvoiceLine, CurrancyFactor, SalesInvoiceHeader."Prices Including VAT");
                                until SalesInvoiceLine.Next() = 0;
                                exit;
                            end;

                            SalesCrMemoLine.SetRange("Document No.", "Document No.");
                            SalesCrMemoLine.SetRange("No.", "G/L Account No.");
                            SalesCrMemoLine.SetRange("VAT Prod. Posting Group", "VAT Prod. Posting Group");
                            if SalesCrMemoLine.FindSet then begin
                                if not SalesCrMemoHeader.Get("Document No.") then
                                    exit;
                                CurrancyFactor := SetCurrancyFactor(SalesCrMemoHeader."Currency Factor");
                                Amount := 0;
                                repeat
                                    PopulateRecFromSalesCrMemoLine(SalesCrMemoLine, CurrancyFactor, SalesCrMemoHeader."Prices Including VAT");
                                until SalesCrMemoLine.Next() = 0;
                            end;
                        end;

                        trigger OnPreDataItem()
                        begin
                            SetRange("Entry No.", "G/L Register"."From Entry No.", "G/L Register"."To Entry No.");
                        end;

                        trigger OnPostDataItem()
                        var
                            l_GLRegister: Record "G/L Register";
                            GLSalesDocReport: Report "G/L Sales Document";
                            RecRef: RecordRef;
                        begin
                            // if AutoPrintSalesDoc AND PrintSalesDoc then begin
                            //     Commit();
                            //     l_GLRegister.CopyFilters("G/L Register");
                            //     //l_GLRegister.FindFirst();
                            //     GLSalesDocReport.SetTableView(l_GLRegister);
                            //     //RecRef.GetTable(l_GLRegister);
                            //     //GLSalesDocReport.Execute('', RecRef);
                            //     GLSalesDocReport.UseRequestPage(true);
                            //     GLSalesDocReport.Run();
                            //     //Report.Run(50106, false, false, l_GLRegister);
                            // end;
                        end;
                    }

                    trigger OnPreDataItem()
                    var
                        l_GLEntry: Record "G/L Entry";
                    begin
                        Clear(ShowApplied);
                        Clear(LastTransNo);

                        "G/L Register".ChangeCompany(Company.Name);
                        "G/L Entry".ChangeCompany(Company.Name);
                        "Purch. Inv. Line".ChangeCompany(Company.Name);
                        "Cust. Ledger Entry".ChangeCompany(Company.Name);
                        "Detailed Cust. Ledg. Entry".ChangeCompany(Company.Name);
                        AppliedCLE.ChangeCompany(Company.Name);
                        "Vendor Ledger Entry".ChangeCompany(Company.Name);
                        "Detailed Vendor Ledg. Entry".ChangeCompany(Company.Name);
                        DimSetEntry.ChangeCompany(Company.Name);
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
                                    Sleep(1000);
                                end;
                            until l_Company.Next() = 0;
                    until B_FinishedPosting or (Cnt >= 10);
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
                    end;
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
                        Visible = false; //G003
                    }
                    field(ShowDim; ShowDim) //G003
                    {
                        ApplicationArea = Dimensions;
                        Caption = 'Show Dimensions';
                        ToolTip = 'Specifies if you want dimensions information for the journal lines to be included in the report.';
                    }
                    field(ShowPostingGroup; ShowPostingGroup) //G003
                    {
                        ApplicationArea = All;
                        Caption = 'Show Posting Group';
                        ToolTip = 'Specifies if the report displays posting group in detail.';
                    }
                    // field(AutoPrintSalesDoc; AutoPrintSalesDoc) //G005
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Auto Print Sales Document if any Register includes Customer Invoice / Credit Memo';
                    // }
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
        GLRegFilter: Text;
        G_L_RegisterCaptionLbl: Label 'G/L Register';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        G_L_Entry__Posting_Date_CaptionLbl: Label 'Posting Date';
        G_L_Entry__Document_Type_CaptionLbl: Label 'Document Type';
        GLAcc_NameCaptionLbl: Label 'Name';
        G_L_Entry__Gen__Posting_Type_CaptionLbl: Label 'Gen. Posting Type';
        G_L_Entry__Gen__Bus__Posting_Group_CaptionLbl: Label 'Gen. Bus. Posting Group';
        G_L_Entry__Gen__Prod__Posting_Group_CaptionLbl: Label 'Gen. Prod. Posting Group';
        G_L_Register__No__CaptionLbl: Label 'Register No.';
        TotalCaptionLbl: Label 'Total';
        G_L_Entry_Amount_Control41CaptionLbl: Label 'Total';
        ShowDetails: Boolean;
        DetailedVATAmount: Decimal;
        ShowPostingGroup: Boolean; //G003
        LastTransNo: Integer; //G003
        ShowApplied: Boolean; //G003
        FCYCode: Code[10]; //G003
        DrAmt: Decimal; //G003
        CrAmt: Decimal; //G003
        ExchRate: Decimal; //G003
        // AutoPrintSalesDoc: Boolean; //G005
        PrintSalesDoc: Boolean; //G005
        ShowDim: Boolean;//G005
        DimText: Text[75];//G003
        AllocationDimText: Text[75];//G003   
        DimensionsCap: Label 'Dimensions';//G003  
        DimSetEntry: Record "Dimension Set Entry";//G003  
        Continue: Boolean;//G003

    trigger OnInitReport()
    begin
        // AutoPrintSalesDoc := true;
        ShowDim := true;
    end;

    trigger OnPreReport()
    begin
        GLRegFilter := "G/L Register".GetFilters();
        TempPurchInvLinePrinted.DeleteAll();
        GLSetup.Get;
        PrintSalesDoc := false;
    end;

    local procedure DetailsPrinted(PurchInvLine: Record "Purch. Inv. Line"): Boolean
    begin
        if TempPurchInvLinePrinted.get(PurchInvLine."Document No.", PurchInvLine."Line No.") then
            exit(true);
        TempPurchInvLinePrinted."Document No." := PurchInvLine."Document No.";
        TempPurchInvLinePrinted."Line No." := PurchInvLine."Line No.";
        TempPurchInvLinePrinted.Insert();
    end;

    local procedure PopulateRecFromPurchInvLine(PurchInvLine: Record "Purch. Inv. Line"; CurrancyFactor: Decimal; PricesInclVAT: Boolean)
    begin
        if PricesInclVAT then
            PurchInvLine.Amount := Round(PurchInvLine."VAT Base Amount" / CurrancyFactor)
        else
            PurchInvLine.Amount := Round(PurchInvLine."Line Amount" / CurrancyFactor);
        "Purch. Inv. Line".Init();
        "Purch. Inv. Line".TransferFields(PurchInvLine);
        if not DetailsPrinted("Purch. Inv. Line") then
            "Purch. Inv. Line".Insert();
    end;

    local procedure PopulateRecFromPurchCrMemoLine(PurchCrMemoLine: Record "Purch. Cr. Memo Line"; CurrancyFactor: Decimal; PricesInclVAT: Boolean)
    begin
        "Purch. Inv. Line".Init();
        if PricesInclVAT then
            PurchCrMemoLine.Amount := Round(PurchCrMemoLine."VAT Base Amount" / CurrancyFactor)
        else
            PurchCrMemoLine.Amount := Round(PurchCrMemoLine."Line Amount" / CurrancyFactor);
        "Purch. Inv. Line".Description := PurchCrMemoLine.Description;
        "Purch. Inv. Line".Amount := -PurchCrMemoLine.Amount;
        "Purch. Inv. Line"."Document No." := PurchCrMemoLine."Document No.";
        "Purch. Inv. Line"."Line No." := PurchCrMemoLine."Line No.";
        "Purch. Inv. Line"."No." := PurchCrMemoLine."No.";
        "Purch. Inv. Line"."Amount Including VAT" := -PurchCrMemoLine."Amount Including VAT";
        "Purch. Inv. Line"."VAT Base Amount" := -PurchCrMemoLine."VAT Base Amount";
        if not DetailsPrinted("Purch. Inv. Line") then
            "Purch. Inv. Line".Insert();
    end;

    local procedure PopulateRecFromSalesInvoiceLine(SalesInvoiceLine: Record "Sales Invoice Line"; CurrancyFactor: Decimal; PricesInclVAT: Boolean)
    begin
        "Purch. Inv. Line".Init();
        if PricesInclVAT then
            SalesInvoiceLine.Amount := Round(SalesInvoiceLine."VAT Base Amount" / CurrancyFactor)
        else
            SalesInvoiceLine.Amount := Round(SalesInvoiceLine."Line Amount" / CurrancyFactor);
        "Purch. Inv. Line".Description := SalesInvoiceLine.Description;
        "Purch. Inv. Line".Amount := -SalesInvoiceLine.Amount;
        "Purch. Inv. Line"."Document No." := SalesInvoiceLine."Document No.";
        "Purch. Inv. Line"."Line No." := SalesInvoiceLine."Line No.";
        "Purch. Inv. Line"."No." := SalesInvoiceLine."No.";
        "Purch. Inv. Line"."Amount Including VAT" := -SalesInvoiceLine."Amount Including VAT";
        "Purch. Inv. Line"."VAT Base Amount" := -SalesInvoiceLine."VAT Base Amount";
        if not DetailsPrinted("Purch. Inv. Line") then
            "Purch. Inv. Line".Insert();
    end;

    local procedure PopulateRecFromSalesCrMemoLine(SalesCrMemoLine: Record "Sales Cr.Memo Line"; CurrancyFactor: Decimal; PricesInclVAT: Boolean)
    begin
        "Purch. Inv. Line".Init();
        if PricesInclVAT then
            SalesCrMemoLine.Amount := Round(SalesCrMemoLine."VAT Base Amount" / CurrancyFactor)
        else
            SalesCrMemoLine.Amount := Round(SalesCrMemoLine."Line Amount" / CurrancyFactor);
        "Purch. Inv. Line".Description := SalesCrMemoLine.Description;
        "Purch. Inv. Line".Amount := SalesCrMemoLine.Amount;
        "Purch. Inv. Line"."Document No." := SalesCrMemoLine."Document No.";
        "Purch. Inv. Line"."Line No." := SalesCrMemoLine."Line No.";
        "Purch. Inv. Line"."No." := SalesCrMemoLine."No.";
        "Purch. Inv. Line"."Amount Including VAT" := SalesCrMemoLine."Amount Including VAT";
        "Purch. Inv. Line"."VAT Base Amount" := SalesCrMemoLine."VAT Base Amount";
        if not DetailsPrinted("Purch. Inv. Line") then
            "Purch. Inv. Line".Insert();
    end;

    local procedure SetCurrancyFactor(HeaderCurrancyFactor: Decimal): Decimal
    begin
        if HeaderCurrancyFactor = 0 then
            exit(1);
        exit(HeaderCurrancyFactor);
    end;

    local procedure GetDimensionText(var DimensionSetEntry: Record "Dimension Set Entry"): Text[75] //G003
    var
        DimensionText: Text[75];
        Separator: Code[10];
        DimValue: Text[45];
    begin
        Separator := '';
        DimValue := '';
        Continue := false;

        repeat
            DimValue := StrSubstNo('%1 - %2', DimensionSetEntry."Dimension Code", DimensionSetEntry."Dimension Value Code");
            if MaxStrLen(DimensionText) < StrLen(DimensionText + Separator + DimValue) then begin
                Continue := true;
                exit(DimensionText);
            end;
            DimensionText := DimensionText + Separator + DimValue;
            Separator := '; ';
        until DimSetEntry.Next() = 0;
        exit(DimensionText);
    end;
}

