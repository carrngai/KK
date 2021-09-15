pageextension 50137 ConfigPackageSubformExt extends "Config. Package Subform"
{
    actions
    {
        addafter("F&unctions")
        {
            group("Master Company Function")
            {
                action("Import from Company")
                {
                    Caption = 'Import Package Records from Company';
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
                        ConfigPackage.Get(Rec."Package Code");
                        CompanyTEC.Reset();
                        CompanyTEC.SetRange(Select, true);

                        If Not CompanyTEC.FindFirst() then
                            Error('You Must Select Copy to Companies ');
                        //ConfigCompanyExchange.FunHideDialog();
                        ConfigCompanyExchange.fn_ExportRecordsFromCompanyPerTable(ConfigPackage.Code, ConfigPackageTable);

                    end;

                }
                action("Apply to Selected Company")
                {
                    Caption = 'Apply to Selected Companies';
                    Promoted = true;
                    PromotedIsBig = true;
                    Image = Export;
                    PromotedCategory = Category4;
                    ApplicationArea = all;
                    trigger OnAction()
                    var
                        ConfigPackage: Record "Config. Package";
                        ConfigPackageTable: Record "Config. Package Table";
                        ConfigPackageTable2: Record "Config. Package Table";
                        ConfigCompanyExchange: Codeunit "Config. Company Exchange";
                        ConfirmManagement: Codeunit "Confirm Management";
                        Text003: Label 'Apply data from package %1?';
                        CompanyTEC: Record "Company TEC";
                    begin
                        //Error('hi');
                        CurrPage.SetSelectionFilter(ConfigPackageTable2);
                        ConfigPackage.Get(Rec."Package Code");
                        ConfigPackage.TESTFIELD(Code);
                        IF Confirm(STRSUBSTNO(Text003, ConfigPackage.Code), TRUE) THEN BEGIN
                            CompanyTEC.Reset();
                            CompanyTEC.SetRange(Select, true);

                            If CompanyTEC.FindSet() then begin
                                repeat
                                    ConfigPackage."Copy to Company" := CompanyTEC."Company Name";
                                    ConfigPackage.Modify();
                                    ConfigPackageTable.Copy(ConfigPackageTable2);
                                    ConfigCompanyExchange.FunHideDialog();
                                    ConfigCompanyExchange.fn_ApplyCompanyPackage(ConfigPackage, ConfigPackageTable, TRUE);
                                    ConfigPackageTable.Copy(ConfigPackageTable2);
                                    ConfigCompanyExchange.fn_ExportRecordsFromCompanyPerTable(ConfigPackage.Code, ConfigPackageTable);
                                    ConfigPackage."Copy to Company" := '';
                                    ConfigPackage.Modify();

                                until CompanyTEC.Next() = 0;
                            end else
                                Error('You Must Select Copy to Companies ');
                        END;

                    end;

                }
            }
        }
    }
}