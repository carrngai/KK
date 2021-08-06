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
            begin

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
}