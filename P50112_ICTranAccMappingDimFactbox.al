page 50112 "IC Trans. Default Dim. FactBox"
{
    Caption = 'Dimensions';
    Editable = false;
    PageType = ListPart;
    SourceTable = "IC Trans. Default Dim.";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Dimension Code"; Rec."Dimension Code")
                {
                    ApplicationArea = Dimensions;
                }
                field("Dimension Value Code"; Rec."Dimension Value Code")
                {
                    ApplicationArea = Dimensions;
                }

            }
        }
    }

    actions
    {
    }
}

