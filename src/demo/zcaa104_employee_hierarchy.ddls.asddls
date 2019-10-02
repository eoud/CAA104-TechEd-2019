define hierarchy zcaa104_Employee_Hierarchy
  as parent child hierarchy(
    source zcaa104_cds_employee
    child to parent association _to_manager
    //    start where
    //      DEMO_CDS_EMPLOYEE.Manager = 'Phili'
    siblings order by
      Employee
    //    multiple parents allowed
  )
{

  sales_org            as Sales_Org,
  manager              as Manager,
  employee             as Employee,
  $node.node_id        as my_NodeId,
  $node.parent_id      as my_ParentId,
  $node.hierarchy_rank as my_Hierarchy_Rank,
  _to_manager
}
