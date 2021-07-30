tableextension 50104 FixedAssetExt extends "Fixed Asset"
{
    fields
    {
        // Add changes to table fields here
        field(50100; "No. 2"; Code[35])
        {
            DataClassification = ToBeClassified;
        }
        field(50101; "Remarks"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(50102; "Description Remarks"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}