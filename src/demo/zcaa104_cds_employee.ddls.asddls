@AbapCatalog.sqlViewName: 'ZCAA104_V_EMPL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'TechEd 2019 Hierarchies Demo'
define view zcaa104_cds_employee as select from zcaa104_employee
  association [*] to zcaa104_cds_employee as _to_manager on  $projection.Sales_Org = _to_manager.sales_org
                                                          and $projection.Manager   = _to_manager.employee
  association [1] to zcaa104_salary       as _to_salary  on  $projection.Sales_Org = _to_salary.sales_org
                                                         and $projection.Employee  = _to_salary.employee
{
      //DEMO_EMPLOYEE
  key sales_org  as Sales_Org,
  key manager    as Manager,
  key employee   as Employee,
      department as Department,


      _to_manager,
      _to_salary // Make association public

}
where
  sales_org = 'Startup Company'
