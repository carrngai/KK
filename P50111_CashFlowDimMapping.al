page 50111 "Cash Flow Dimension Mapping"
{
    //20200422 G019 Map CF Movement to CF Nature

    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Cash Flow Dimension Mapping";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("CF Movement Dimension"; Rec."CF Movement Dimension")
                {
                    ToolTip = 'Specifies the value of the FA Movement Dimension field';
                    Caption = 'Cash Flow Movement Dimension';
                    ApplicationArea = All;
                }

                field("CF Nature Dimension"; Rec."CF Nature Dimension")
                {
                    ToolTip = 'Specifies the value of the Cash Flow Dimension field';
                    Caption = 'Cash Flow Nature Dimension';
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

        }
    }
}