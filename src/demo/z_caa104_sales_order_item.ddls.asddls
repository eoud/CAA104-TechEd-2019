@AbapCatalog.sqlViewName: 'ZCAA104_V_SOITEM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Sales order item'
define view Z_CAA104_SALES_ORDER_ITEM as select from zcaa104_items {
  key sales_order_nr,
  key item_nr,
  item_category,
  price,
  currency
}
