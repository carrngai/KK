pageextension 50113 "FA Depr. Books Subform Ext" extends "FA Depreciation Books Subform"
{
    layout
    {
        // Add changes to page layout here
        modify("Straight-Line %")
        {
            Visible = true;
        }
        modify("No. of Depreciation Months")
        {
            Visible = true;
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}