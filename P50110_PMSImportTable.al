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
                field("Transaction Date"; "Transaction Date")
                {
                    ApplicationArea = All;

                }
                field("Account Number"; "Account Number")
                {
                    ApplicationArea = All;

                }
            }
        }
    }
}