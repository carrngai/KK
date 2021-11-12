page 50110 "PMSImportTable"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "PMSImportTable";
    Caption = 'PMS Import Table';

    layout
    {
        area(Content)
        {
            repeater(PMSImportTableList)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;

                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Transaction Date"; Rec."Transaction Date")
                {
                    ApplicationArea = All;

                }
                field("Account Number"; Rec."Account Number")
                {
                    ApplicationArea = All;
                }
                field("Account Description"; Rec."Account Description")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Base Amount"; Rec."Base Amount")
                {
                    ApplicationArea = All;
                }
                field("Native Amount"; Rec."Native Amount")
                {
                    ApplicationArea = All;
                }
                field(Currency; Rec.Currency)
                {
                    ApplicationArea = All;
                }
                field("Entry Memo"; Rec."Entry Memo")
                {
                    ApplicationArea = All;
                }
                field("GL Name"; Rec."GL Name")
                {
                    ApplicationArea = All;
                }
                field("Entry Source"; Rec."Entry Source")
                {
                    ApplicationArea = All;
                }
                field("GL Entry Id"; Rec."GL Entry Id")
                {
                    ApplicationArea = All;
                }
                field("GL Distribution Line"; Rec."GL Distribution Line")
                {
                    ApplicationArea = All;
                }
                field(ISIN; Rec.ISIN)
                {
                    ApplicationArea = All;
                }
                field("BB Yellow Key"; Rec."BB Yellow Key")
                {
                    ApplicationArea = All;
                }
                field("Custodian Account Display Name"; Rec."Custodian Account Display Name")
                {
                    ApplicationArea = All;
                }
                field(Custodian; Rec.Custodian)
                {
                    ApplicationArea = All;
                }
                field("Row No."; Rec."Row No.")
                {
                    ApplicationArea = all;
                }
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = all;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Convert to General Journal")
            {
                ApplicationArea = All;
                Image = Line;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    PMSImport: Codeunit PMSImport;
                begin
                    PMSImport.ConvertPMS(Rec."File Name");
                end;

            }
        }
    }
}