page 50100 "Tax Return"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Tax Return";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Company"; Rec."Company")
                {
                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = All;
                }
                field("Year End Date"; Rec."Year End Date")
                {
                    ToolTip = 'Specifies the value of the Year End Date field';
                    ApplicationArea = All;
                }
                field("Year of Assessment"; Rec."Year of Assessment")
                {
                    ToolTip = 'Specifies the value of the Year of Assessment field';
                    ApplicationArea = All;
                }
                field("Tax Return Submitted"; Rec."Tax Return Submitted")
                {
                    ToolTip = 'Specifies the value of the Tax Return Submitted field';
                    ApplicationArea = All;
                }
                field("Tax Return Filing Date"; Rec."Tax Return Filing Date")
                {
                    ToolTip = 'Specifies the value of the Tax Return Filing Date field';
                    ApplicationArea = All;
                }
                field("Audit Fin. Stmt. Submitted"; Rec."Audit Fin. Stmt. Submitted")
                {
                    ToolTip = 'Specifies the value of the Audit Financial Statement Submitted field';
                    ApplicationArea = All;
                }
                field("Audit Fin. Stmt. Subm. Date"; Rec."Audit Fin. Stmt. Subm. Date")
                {
                    ToolTip = 'Specifies the value of the Audit Financial Statement Submission Date field';
                    ApplicationArea = All;
                }
                field(BIR51; Rec.BIR51)
                {
                    ToolTip = 'Specifies the value of the BIR51 field';
                    ApplicationArea = All;
                }
                field(IRC1811; Rec.IRC1811)
                {
                    ToolTip = 'Specifies the value of the IRC1811 field';
                    ApplicationArea = All;
                }
                field(IRC1812; Rec.IRC1812)
                {
                    ToolTip = 'Specifies the value of the IRC1812 field';
                    ApplicationArea = All;
                }
                field(IRC1902; Rec.IRC1902)
                {
                    ToolTip = 'Specifies the value of the IRC1902 field';
                    ApplicationArea = All;
                }
                field(IRC1931; Rec.IRC1931)
                {
                    ToolTip = 'Specifies the value of the IRC1931 field';
                    ApplicationArea = All;
                }
                field(IRC1937; Rec.IRC1937)
                {
                    ToolTip = 'Specifies the value of the IRC1937 field';
                    ApplicationArea = All;
                }
                field(Others; Rec.Others)
                {
                    ToolTip = 'Specifies the value of the Others field';
                    ApplicationArea = All;
                }
                field(Remarks; Rec.Remarks)
                {
                    ToolTip = 'Specifies the value of the Remarks field';
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin

                end;
            }
        }
    }
}