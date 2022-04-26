report 50120 DeleteCompany
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Company; Company)
        {
            RequestFilterFields = Name;
            trigger OnAfterGetRecord()
            begin
                Delete(true);
            end;
        }
    }

}