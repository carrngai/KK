page 50102 "Holding Company / Investor"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Holding Company / Investor";
    AutoSplitKey = true;

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
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Holding Company/Investor"; Rec."Holding Company/Investor")
                {
                    ToolTip = 'Specifies the value of the Holding Company/Investor field';
                    ApplicationArea = All;
                }

                field("Percentage of Holding"; Rec."Percentage of Holding")
                {
                    ToolTip = 'Specifies the value of the Percentage of Holding field';
                    ApplicationArea = All;
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}