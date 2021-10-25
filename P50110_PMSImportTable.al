page 50110 "PMSImportTable"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "PMSImportTable";

    layout
    {
        area(Content)
        {
            repeater(PMSImportTableList)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;

                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Transaction Date"; "Transaction Date")
                {
                    ApplicationArea = All;

                }
                field("Account Number"; "Account Number")
                {
                    ApplicationArea = All;
                }
                field("Account Description"; "Account Description")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Base Amount"; "Base Amount")
                {
                    ApplicationArea = All;
                }
                field("Native Amount"; "Native Amount")
                {
                    ApplicationArea = All;
                }
                field(Currency; Currency)
                {
                    ApplicationArea = All;
                }
                field("Entry Memo"; "Entry Memo")
                {
                    ApplicationArea = All;
                }
                field("GL Name"; "GL Name")
                {
                    ApplicationArea = All;
                }
                field("Entry Source"; "Entry Source")
                {
                    ApplicationArea = All;
                }
                field("GL Entry Id"; "GL Entry Id")
                {
                    ApplicationArea = All;
                }
                field("GL Distribution Line"; "GL Distribution Line")
                {
                    ApplicationArea = All;
                }
                field(ISIN; ISIN)
                {
                    ApplicationArea = All;
                }
                field("BB Yellow Key"; "BB Yellow Key")
                {
                    ApplicationArea = All;
                }
                field("Custodian Account Display Name"; "Custodian Account Display Name")
                {
                    ApplicationArea = All;
                }
                field(Custodian; Custodian)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}