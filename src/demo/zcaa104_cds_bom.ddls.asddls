@AbapCatalog.sqlViewName: 'ZCAA104_V_BOM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Demo Windowing TechEd 2019 Sales Order Item'
define view ZCAA104_CDS_BOM as select from zcaa104_bom
 association [1] to ZCAA104_CDS_BOM as _to_parent on  $projection.parent = _to_parent.material {
  //demo_bom
  key material,
  parent,
  quantity,
  _to_parent
}
