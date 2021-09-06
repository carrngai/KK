pageextension 50142 ConfigPackageSubformExt extends "Config. Package Subform"
{
    actions
    {
        addafter("F&unctions")
        {
            group("Master Company Function")
            {
                action("Import from Company")
                {
                    Caption = '2. Import Package Records from Company';
                    Promoted = true;
                    Image = Import;
                    PromotedIsBig = true;
                    PromotedCategory = Category4;
                    ApplicationArea = all;
                    trigger OnAction()
                    var
                        ConfigPackage: Record "Config. Package";
                        ConfigPackageTable: Record "Config. Package Table";
                        ConfigCompanyExchange: Codeunit "Config. Company Exchange";
                        CompanyTEC: Record "Company TEC";
                    begin
                        CurrPage.SetSelectionFilter(ConfigPackageTable);
                        ConfigPackage.Get("Package Code");
                        CompanyTEC.Reset();
                        CompanyTEC.SetRange(Select, true);

                        If Not CompanyTEC.FindFirst() then
                            Error('You Must Select Copy to Companies ');
                        //ConfigCompanyExchange.FunHideDialog();
                        ConfigCompanyExchange.fn_ExportRecordsFromCompanyPerTable(ConfigPackage.Code, ConfigPackageTable);

                    end;

                }
                action("Export to Selected Company")
                {
                    Caption = '3. Export to Selected Companies';
                    Promoted = true;
                    PromotedIsBig = true;
                    Image = Export;
                    PromotedCategory = Category4;
                    ApplicationArea = all;
                    trigger OnAction()
                    var
                        ConfigPackage: Record "Config. Package";
                        ConfigPackageTable: Record "Config. Package Table";
                        ConfigCompanyExchange: Codeunit "Config. Company Exchange";
                        ConfirmManagement: Codeunit "Confirm Management";
                        Text003: Label 'Apply data from package %1?';
                        CompanyTEC: Record "Company TEC";
                    begin
                        //Error('hi');
                        CurrPage.SetSelectionFilter(ConfigPackageTable);
                        ConfigPackage.Get("Package Code");
                        ConfigPackage.TESTFIELD(Code);
                        IF Confirm(STRSUBSTNO(Text003, ConfigPackage.Code), TRUE) THEN BEGIN
                            CompanyTEC.Reset();
                            CompanyTEC.SetRange(Select, true);

                            If CompanyTEC.FindFirst() then begin
                                repeat
                                    ConfigPackage."Copy to Company" := CompanyTEC."Company Name";
                                    ConfigPackage.Modify();

                                    ConfigCompanyExchange.fn_ApplyCompanyPackage(ConfigPackage, ConfigPackageTable, TRUE);
                                    ConfigCompanyExchange.fn_ExportRecordsFromCompanyPerTable(ConfigPackage.Code, ConfigPackageTable);
                                    ConfigPackage."Copy to Company" := '';
                                    ConfigPackage.Modify();
                                //ConfigCompanyExchange.FunHideDialog();
                                //ConfigCompanyExchange.fn_ExportRecordsFromCompany(Code);

                                until CompanyTEC.Next() = 0;

                                // CompanyTEC.Reset();
                                // CompanyTEC.SetRange(Select, true);
                                // If CompanyTEC.FindFirst() then begin
                                //     repeat
                                //         CompanyTEC.Select := false;
                                //         CompanyTEC.Modify();
                                //     until CompanyTEC.Next() = 0;
                                // end;
                            end else
                                Error('You Must Select Copy to Companies ');
                        END;

                    end;

                }
            }
        }
    }
}