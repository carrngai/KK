page 50108 "IC Gen. Jnl. Allocations"
{
    AutoSplitKey = true;
    Caption = 'Allocations';
    DataCaptionFields = "Journal Batch Name";
    PageType = Worksheet;
    PromotedActionCategories = 'New,Process,Report,Line,Account';
    SourceTable = "IC Gen. Jnl. Allocation";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;

                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the amount that will be posted from the allocation journal line.';

                }
                field("Bal. Dimension Set ID"; Rec."Bal. Dimension Set ID")
                {
                    ToolTip = 'Specifies the value of the Dimension Set ID field';
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            part("Dimension Set"; "Dimension Set Entries FactBox")
            {
                ApplicationArea = all;
                SubPageLink = "Dimension Set ID" = field("Bal. Dimension Set ID");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                        CurrPage.SaveRecord;
                    end;
                }
            }

        }
    }

    trigger OnAfterGetCurrRecord()
    begin

    end;

    trigger OnAfterGetRecord()
    begin

    end;

    trigger OnInit()
    begin

    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin

    end;


}

