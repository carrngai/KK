page 50113 "PMS Import Setup"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "PMS Import Setup";

    layout
    {
        area(Content)
        {
            repeater("PMS Import Setup")
            {
                field("PMS Account No."; Rec."PMS Account No.")
                {
                    ApplicationArea = All;

                }
                field("Instrument Type"; Rec."Instrument Type")
                {
                    ApplicationArea = All;

                }
                field("G/L Account No."; Rec."G/L Account No.")
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("Dimensions")
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
                    ShowDocDim;
                    CurrPage.SaveRecord;
                end;
            }

        }
    }
    procedure ShowDocDim()
    var
        OldDimSetID: Integer;
        IsHandled: Boolean;
        DimMgt: Codeunit "DimensionManagement";
    begin
        OldDimSetID := Rec."Dimension Set ID";
        Rec."Dimension Set ID" :=
          DimMgt.EditDimensionSet(Rec."Dimension Set ID", StrSubstNo('%1 %2', Rec."PMS Account No.", Rec."Instrument Type"));

    end;
}