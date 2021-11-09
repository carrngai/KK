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

    actions
    {

        area(Processing)
        {
            action("Set Select")
            {
                ApplicationArea = All;
                Image = Completed;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    l_company: Record "Company TEC";
                begin
                    l_company.Reset();
                    if l_company.FindSet() then begin
                        repeat
                            l_company.Select := true;
                            l_company.Modify();
                        until l_company.Next() = 0;
                    end;
                end;
            }
            action("Clear Select")
            {
                ApplicationArea = All;
                Image = ResetStatus;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    l_company: Record "Company TEC";
                begin
                    l_company.Reset();
                    if l_company.FindSet() then begin
                        repeat
                            l_company.Select := false;
                            l_company.Modify();
                        until l_company.Next() = 0;
                    end;
                end;
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
