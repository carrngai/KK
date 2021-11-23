page 50101 "Company Information Change"
{
    PageType = List;
    ApplicationArea = All;
    PromotedActionCategories = 'New,Process,Report,Related';
    UsageCategory = Administration;
    SourceTable = "Company Information Change";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Company; Rec.Company)
                {
                    ToolTip = 'Specifies the value of the Company field';
                    ApplicationArea = All;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ToolTip = 'Specifies the value of the Start Date field';
                    ApplicationArea = All;
                }
                field("Holding Company/Investor Chg."; Rec."Holding Company/Investor Chg.")
                {
                    ToolTip = 'Specifies the value of the Holding Company/Investor Change field.';
                    ApplicationArea = All;
                }
                field("List of Director Change"; Rec."List of Director Change")
                {
                    ToolTip = 'Specifies the value of the List of Director Change field.';
                    ApplicationArea = All;
                }
                field("Company Name"; Rec."Company Name")
                {
                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = All;
                }
                field("Former Name"; Rec."Former Name")
                {
                    ToolTip = 'Specifies the value of the Former Name field';
                    ApplicationArea = All;
                }
                field("Date of Reg. as non-HK company"; Rec."Date of Reg. as non-HK company")
                {
                    ToolTip = 'Specifies the value of the Date of Registration as non-HK company under CO field';
                    ApplicationArea = All;
                }
                field("Company Secretary"; Rec."Company Secretary")
                {
                    ToolTip = 'Specifies the value of the Company Secretary field';
                    ApplicationArea = All;
                }
                field("Business Nature"; Rec."Business Nature")
                {
                    ToolTip = 'Specifies the value of the Business Nature field';
                    ApplicationArea = All;
                }
                field("Year-end Month"; Rec."Year-end Month")
                {
                    ToolTip = 'Specifies the value of the Year-end Date field';
                    ApplicationArea = All;
                }
                field(Auditor; Rec.Auditor)
                {
                    ToolTip = 'Specifies the value of the Auditor field';
                    ApplicationArea = All;
                }
                field("Tax representative"; Rec."Tax representative")
                {
                    ToolTip = 'Specifies the value of the Tax representative field';
                    ApplicationArea = All;
                }
                field("IRD File Number"; Rec."IRD File Number")
                {
                    ToolTip = 'Specifies the value of the IRD File Number field';
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("Holding Company/Investor")
            {
                ApplicationArea = All;
                RunObject = page "Holding Company/Investor";
                RunPageLink = Company = field(Company), "Start Date" = field("Start Date");
                Promoted = true;
                PromotedCategory = Category4;
                Image = Line;
                trigger OnAction()
                begin

                end;
            }
            action("List of Director")
            {
                ApplicationArea = All;
                RunObject = page "List of Director";
                RunPageLink = Company = field(Company), "Start Date" = field("Start Date");
                Promoted = true;
                PromotedCategory = Category4;
                Image = Line;
                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}