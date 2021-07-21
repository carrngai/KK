pageextension 50100 CompanyInformationExt extends "Company Information"
{
    layout
    {
        // Add changes to page layout here
        addlast(General)
        {
            field("Sort Code"; Rec."Sort Code")
            {
                ToolTip = 'Specifies the value of the Sort Code field';
                ApplicationArea = All;
            }
            field("Place of Incorporation"; Rec."Place of Incorporation")
            {
                ToolTip = 'Specifies the value of the Place of Incorporation field';
                ApplicationArea = All;
            }
            field("Date of Incorporation"; Rec."Date of Incorporation")
            {
                ToolTip = 'Specifies the value of the Date of Incorporation field';
                ApplicationArea = All;
            }
            field("Company Number"; Rec."Company Number")
            {
                ToolTip = 'Specifies the value of the Company Number field';
                ApplicationArea = All;
            }
            field("B.R. Number"; Rec."B.R. Number")
            {
                ToolTip = 'Specifies the value of the B.R. Number field';
                ApplicationArea = All;
            }
            field("Ledger Code"; Rec."Ledger Code")
            {
                ToolTip = 'Specifies the value of the Ledger Code field';
                ApplicationArea = All;
            }
            field(Remarks; Rec.Remarks)
            {
                ToolTip = 'Specifies the value of the Remarks field';
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addfirst("System Settings")
        {
            action("Tax Return")
            {
                ApplicationArea = All;
                Image = TaxDetail;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    TaxReturn: Record "Tax Return";
                begin
                    TaxReturn.SetRange("Company", CompanyName);
                    Page.RunModal(Page::"Tax Return", TaxReturn);
                end;
            }
            action("Company Information Change")
            {
                ApplicationArea = All;
                Image = Company;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    CompanyInfoChange: Record "Company Information Change";
                begin
                    CompanyInfoChange.SetRange("Company", CompanyName);
                    Page.RunModal(Page::"Company Information Change", CompanyInfoChange);
                end;
            }
        }

    }

}
