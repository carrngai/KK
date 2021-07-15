page 50107 "FA Cash Flow Dimension Mapping"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "FA Cash Flow Dimension Mapping";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("FA Movement Dimension"; Rec."FA Movement Dimension")
                {
                    ToolTip = 'Specifies the value of the FA Movement Dimension field';
                    ApplicationArea = All;
                }
                field("FA Posting Type"; Rec."FA Posting Type")
                {
                    ToolTip = 'Specifies the value of the FA Posting Type field';
                    ApplicationArea = All;
                }
                field("Cash Flow Dimension"; Rec."Cash Flow Dimension")
                {
                    ToolTip = 'Specifies the value of the Cash Flow Dimension field';
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