pageextension 50107 FixedAssetCardExt extends "Fixed Asset Card"
{
    layout
    {
        // Add changes to page layout here
        addafter("No.")
        {

            field("No. 2"; Rec."No. 2")
            {
                ToolTip = 'Specifies the value of the No. 2 field';
                ApplicationArea = All;
            }
        }
        addafter(Description)
        {
            field("Description Remarks"; Rec."Description Remarks")
            {
                ToolTip = 'Specifies the value of the Description Remarks field';
                ApplicationArea = All;
                MultiLine = true;
            }
            field(Remarks; Rec.Remarks)
            {
                ToolTip = 'Specifies the value of the Remarks field';
                ApplicationArea = All;
                MultiLine = true;
            }
        }
        addbefore(DepreciationStartingDate)
        {
            field("Straight-Line %"; FADepreciationBook."Straight-Line %")
            {
                ApplicationArea = FixedAssets;
                ShowMandatory = true;

                trigger OnValidate()
                begin
                    LoadFADepreciationBooks();
                    FADepreciationBook.Validate("Straight-Line %");
                    SaveSimpleDepreciationBook(xRec."No.");
                end;
            }
        }
        addafter(NumberOfDepreciationYears)
        {
            field("No. of Depreciation Months"; FADepreciationBook."No. of Depreciation Months")
            {
                ApplicationArea = FixedAssets;
                ShowMandatory = true;

                trigger OnValidate()
                begin
                    LoadFADepreciationBooks();
                    FADepreciationBook.Validate("No. of Depreciation Months");
                    SaveSimpleDepreciationBook(xRec."No.");
                end;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}