@AbapCatalog.sqlViewName: 'ZCAA104DDICT1'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Teched 2019: CDS New data types'
define view ZCAA104_CDS_AIRPORT 
  with parameters 
    @Environment.systemField: #SYSTEM_DATE
    iv_current_date : abap.dats
 as select from zcaa104_airports as base 
 {
  key base.code,
  base.construction_date,
  datn_days_between(dats_to_datn($parameters.iv_current_date,'NULL','INITIAL'),base.next_maintenance) as Days2Maintenance,
  datn_add_days(base.next_maintenance, 180 ) as NextMaintenance,
  utcl_current() as Now,
  DATN_DAYS_BETWEEN(base.construction_date,dats_to_datn($parameters.iv_current_date,'NULL','INITIAL')) as Age
}
