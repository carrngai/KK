table 50102 "Holding Company/Investor"
{
    DataClassification = ToBeClassified;
    DataPerCompany = false;

    fields
    {
        field(1; "Company"; Text[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = Company.Name;
        }
        field(2; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Holding Company/Investor Name"; Text[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = Company.Name;
            ValidateTableRelation = false;
        }
        field(5; "Percentage of Holding"; Decimal)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                Companies: Record Company;
                BU: Record "Business Unit";
                CompanyInfo: Record "Company Information";
                ConsoCompany: Text[30];
                ConsoPath: Text[1000];
                ConsoPrec: Decimal;

            begin

                Companies.Reset();
                if Companies.FindSet() then
                    repeat
                        BU.Reset();
                        BU.ChangeCompany(Companies.Name);
                        BU.SetRange("Company Name", Company);
                        BU.SetRange("Starting Date", "Start Date");
                        if BU.FindFirst() then begin

                            CompanyInfo.ChangeCompany(Companies.Name);
                            if CompanyInfo.Get() then
                                ConsoCompany := CompanyInfo."Consolidate Company"
                            else
                                Error('Consolidate Company must be defined in Company Information for %1', CompanyProperty.DisplayName);

                            ConsoPath := GenerateConsoPath(Company + '.' + "Holding Company/Investor Name", "Holding Company/Investor Name", ConsoCompany); //for checking
                            ConsoPrec := GenerateHoldingPrec("Percentage of Holding", "Holding Company/Investor Name", ConsoCompany);

                            BU."Consolidation %" := ConsoPrec;
                            BU.Modify();
                        end;
                    until Companies.Next() = 0;
            end;
        }
    }

    keys
    {
        key(Key1; Company, "Start Date", "Line No.")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;


    local procedure GenerateConsoPath(ConsoPath: Text[1000]; Parent: text[30]; ConsoCompany: Text[30]): Text[1000]
    var
        l_HoldingCompany: Record "Holding Company/Investor";
    begin
        if Parent = ConsoCompany then
            exit(ConsoPath);

        l_HoldingCompany.Reset();
        l_HoldingCompany.SetRange(Company, Parent);
        if l_HoldingCompany.FindSet() then begin
            repeat
                ConsoPath := ConsoPath + '.' + l_HoldingCompany."Holding Company/Investor Name";
                exit(GenerateConsoPath(ConsoPath, l_HoldingCompany."Holding Company/Investor Name", ConsoCompany));
            until l_HoldingCompany.Next() = 0
        end;
    end;

    local procedure GenerateHoldingPrec(HoldingPrec: Decimal; Parent: text[30]; ConsoCompany: Text[30]): Decimal
    var
        l_HoldingCompany: Record "Holding Company/Investor";
    begin
        if Parent = ConsoCompany then
            exit(HoldingPrec);

        l_HoldingCompany.Reset();
        l_HoldingCompany.SetRange(Company, Parent);
        if l_HoldingCompany.FindSet() then begin
            repeat
                HoldingPrec := HoldingPrec * l_HoldingCompany."Percentage of Holding" / 100;
                exit(GenerateHoldingPrec(HoldingPrec, l_HoldingCompany."Holding Company/Investor Name", ConsoCompany));
            until l_HoldingCompany.Next() = 0
        end;
    end;
}