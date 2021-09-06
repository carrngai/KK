page 50107 "IC Trans. Account Mapping Dim."
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "IC Trans. Account Mapping Dim.";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(ID; Rec.ID)
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field("Type ID"; Rec."Type ID")
                {
                    ApplicationArea = all;
                    Visible = false;
                    ToolTip = 'Input 1 for Account Type and 2 for Bal. Account Type';
                }
                field("Dimension Code"; Rec."Dimension Code")
                {
                    ApplicationArea = all;
                }
                field("Dimension Value Code"; Rec."Dimension Value Code")
                {
                    ApplicationArea = all;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {

        }
    }
}