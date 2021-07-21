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
                DBCompany: Record Company;
            begin
                //need update value twice to get BU conso % calculated ?
                if DBcompany.Get("Holding Company/Investor Name") then
                    UpadteHoldingPrec("Start Date");
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


    local procedure UpadteHoldingPrec(StartDate: date)
    var
        Companies: Record Company;
        BU: Record "Business Unit";
        CompanyInfo: Record "Company Information";
        ConsoCompany: Text[30];
        ConsoPath: Text[1000];
        ConsoPrec: Decimal;
        l_BU: Record "Business Unit";
        l_HC: Record "Holding Company/Investor";
        IsHandled1: Boolean;
        IsHandled2: Boolean;

    begin
        Companies.Reset();
        if Companies.FindSet() then
            ConsoCompany := '';
        repeat
            BU.Reset();
            BU.ChangeCompany(Companies.Name);
            BU.SetRange("Starting Date", StartDate);
            if BU.FindSet() then begin
                repeat
                    //Get Conso Company
                    l_BU.Reset();
                    l_BU.ChangeCompany(Companies.Name);
                    l_BU.SetRange("Parent Company", true);
                    if l_BU.FindFirst() then
                        ConsoCompany := l_BU."Company Name"
                    else
                        Error('A Business Unit must be selected as Parent Company in conso company %1', CompanyProperty.DisplayName);

                    ConsoPath := '';
                    ConsoPrec := 0;
                    //Find Conso Path and %
                    if BU."Company Name" <> ConsoCompany then begin
                        IsHandled1 := false;
                        IsHandled2 := false;
                        ConsoPath := GenerateConsoPath(ConsoPath, BU."Company Name", ConsoCompany, BU."Starting Date", BU."Ending Date", IsHandled1); //for checking
                        ConsoPrec := GenerateHoldingPrec(ConsoPrec, BU."Company Name", ConsoCompany, BU."Starting Date", BU."Ending Date", IsHandled2);

                        if (ConsoPrec <> 0) and (ConsoPrec <> BU."Consolidation %") then begin
                            BU."Conso Path" := ConsoPath;
                            BU."Consolidation %" := ConsoPrec;
                            BU.Modify();
                        end;
                    end;
                until BU.Next() = 0;
            end;
        until Companies.Next() = 0;
    end;



    local procedure GenerateConsoPath(var ConsoPath: Text[1000]; BUName: text[30]; ConsoCompany: Text[30]; StartDate: date; EndDate: Date; var IsHandled: Boolean): Text[1000]
    var
        l_HoldingCompany: Record "Holding Company/Investor";
        l_HoldingCompany2: Record "Holding Company/Investor";
    begin
        if IsHandled then
            exit(ConsoPath);

        l_HoldingCompany.Reset();
        l_HoldingCompany.SetRange(Company, BUName);
        l_HoldingCompany.SetFilter("Start Date", '%1', StartDate);
        if l_HoldingCompany.FindSet() then begin
            repeat
                if ConsoPath = '' then
                    ConsoPath := l_HoldingCompany.Company + '.' + l_HoldingCompany."Holding Company/Investor Name"
                else
                    ConsoPath := ConsoPath + '.' + l_HoldingCompany."Holding Company/Investor Name";

                if l_HoldingCompany."Holding Company/Investor Name" = ConsoCompany then begin
                    IsHandled := true;
                    exit(ConsoPath);
                end else begin
                    l_HoldingCompany2.Reset();
                    l_HoldingCompany2.SetRange(Company, l_HoldingCompany."Holding Company/Investor Name");
                    l_HoldingCompany2.SetFilter("Start Date", '%1', StartDate);
                    if l_HoldingCompany2.FindSet() then begin
                        GenerateConsoPath(ConsoPath, l_HoldingCompany."Holding Company/Investor Name", ConsoCompany, StartDate, EndDate, IsHandled);
                        if IsHandled then
                            exit(ConsoPath);
                    end else
                        ConsoPath := '';
                end;
            until l_HoldingCompany.Next() = 0;
        end;
    end;

    local procedure GenerateHoldingPrec(var HoldingPrec: Decimal; BUName: text[30]; ConsoCompany: Text[30]; StartDate: date; EndDate: Date; var IsHandled: Boolean): Decimal
    var
        l_HoldingCompany: Record "Holding Company/Investor";
        l_HoldingCompany2: Record "Holding Company/Investor";
    begin
        if IsHandled then
            exit(HoldingPrec);

        l_HoldingCompany.Reset();
        l_HoldingCompany.SetRange(Company, BUName);
        l_HoldingCompany.SetFilter("Start Date", '%1', StartDate);
        if l_HoldingCompany.FindSet() then begin
            repeat
                if HoldingPrec = 0 then
                    HoldingPrec := l_HoldingCompany."Percentage of Holding"
                else
                    HoldingPrec := HoldingPrec * l_HoldingCompany."Percentage of Holding" / 100;

                if l_HoldingCompany."Holding Company/Investor Name" = ConsoCompany then begin
                    IsHandled := true;
                    exit(HoldingPrec);
                end else begin
                    l_HoldingCompany2.Reset();
                    l_HoldingCompany2.SetRange(Company, l_HoldingCompany."Holding Company/Investor Name");
                    l_HoldingCompany2.SetFilter("Start Date", '%1', StartDate);
                    if l_HoldingCompany2.FindSet() then begin
                        GenerateHoldingPrec(HoldingPrec, l_HoldingCompany."Holding Company/Investor Name", ConsoCompany, StartDate, EndDate, IsHandled);
                        if IsHandled then
                            exit(HoldingPrec);
                    end else
                        HoldingPrec := 0;
                end;
            until l_HoldingCompany.Next() = 0;
        end;
    end;
}