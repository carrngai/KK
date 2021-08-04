page 50106 "IC Transaction Account Mapping"
{
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Related';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "IC Transaction Account Mapping";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Path Code"; Rec."Path Code")
                {
                    ToolTip = 'Specifies the value of the Path Code field';
                    ApplicationArea = All;
                }
                field("Account Type"; Rec."Account Type")
                {
                    ToolTip = 'Specifies the value of the Account Type field';
                    ApplicationArea = All;
                }
                field("Account No."; Rec."Account No.")
                {
                    ToolTip = 'Specifies the value of the Account No. field';
                    ApplicationArea = All;
                }
                field("Dimension Set ID"; Rec."Dimension Set ID")
                {
                    ToolTip = 'Specifies the value of the Dimension Set ID field';
                    ApplicationArea = All;
                }
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    ToolTip = 'Specifies the value of the Bal. Account Type field';
                    ApplicationArea = All;
                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ToolTip = 'Specifies the value of the Bal. Account No. field';
                    ApplicationArea = All;
                }

                field("Bal. Dimension Set ID"; Rec."Bal. Dimension Set ID")
                {
                    ToolTip = 'Specifies the value of the Bal. Dimension Set ID field';
                    ApplicationArea = All;
                }

                field(Elimination; Rec.Elimination)
                {
                    ToolTip = 'Specifies the value of the Elimination field';
                    ApplicationArea = All;
                }

            }
        }
        area(Factboxes)
        {
            part("Dimensions Set"; "Dimension Set Entries FactBox")
            {
                ApplicationArea = all;
                SubPageLink = "Dimension Set ID" = field("Dimension Set ID");
            }
            part("Bal. Dimensions Set"; "Dimension Set Entries FactBox")
            {
                ApplicationArea = all;
                SubPageLink = "Dimension Set ID" = field("Bal. Dimension Set ID");
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Dimensions)
            {
                AccessByPermission = TableData Dimension = R;
                ApplicationArea = Dimensions;
                Caption = 'Dimensions';
                Image = Dimensions;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                trigger OnAction()
                begin
                    rec.ShowDimensions();
                    CurrPage.SaveRecord;
                end;
            }
            action("Bal. Dimensions")
            {
                AccessByPermission = TableData Dimension = R;
                ApplicationArea = Dimensions;
                Caption = 'Bal. Dimensions';
                Image = Dimensions;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                trigger OnAction()
                begin
                    rec.ShowDimensions2();
                    CurrPage.SaveRecord;
                end;
            }

        }
    }

}