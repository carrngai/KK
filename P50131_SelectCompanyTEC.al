page 50131 SelectCompanyTEC
{

    Caption = 'SelectCompanyTEC';
    PageType = List;
    SourceTable = "Company TEC";
    //SourceTableTemporary = true;


    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Company Name"; Rec."Company Name")
                {
                    Caption = 'Company';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Select"; Rec.Select)
                {
                    ApplicationArea = All;
                    Caption = 'Select';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        Company: Record Company;
        CompanyTEC: Record "Company TEC";

    begin

        Company.Reset();
        if Company.FindFirst() then begin
            repeat

                Rec.Init();
                Rec."Company Name" := Company.Name;
                IF NOT CompanyTEC.Get(Company.Name) then begin
                    Rec.Insert()
                    //else begin
                    //  CompanyTEC.Select := false;
                    //CompanyTEC.Modify();
                end;
            until Company.Next() = 0;
        end;
        Rec.Reset();
        If Rec.FindFirst() then begin
            repeat
                If Not Company.Get(rec."Company Name") then
                    Rec.Delete()
            until rec.Next() = 0;
        end;
    end;

}
