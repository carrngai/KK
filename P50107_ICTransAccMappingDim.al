page 50107 "IC Trans. Account Mapping Dim."
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "IC Trans. Default Dim.";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Table ID"; Rec."Table ID")
                {
                    ToolTip = 'Specifies the value of the Table ID field.';
                    ApplicationArea = All;
                    // Visible = false;
                    Editable = false;
                }
                field("Key 1"; Rec."Key 1")
                {
                    ToolTip = 'Specifies the value of the Key 1 field.';
                    ApplicationArea = All;
                    // Visible = false;
                    Editable = false;
                }
                field("Key 2"; Rec."Key 2")
                {
                    ToolTip = 'Specifies the value of the Key 2 field.';
                    ApplicationArea = All;
                    // Visible = false;
                    Editable = false;
                }
                field("Type"; Rec."Type")
                {
                    ToolTip = 'Specifies the value of the Type field.';
                    ApplicationArea = All;
                    // Visible = false;
                    Editable = false;
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