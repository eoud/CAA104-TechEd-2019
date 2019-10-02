define hierarchy zcaa104_bom_hierarchy
  as parent child hierarchy(
    source ZCAA104_CDS_BOM
    child to parent association _to_parent
    start where
      parent is initial
    siblings order by
      material
  )
{
  material,
  parent,
  quantity,
  _to_parent
}
