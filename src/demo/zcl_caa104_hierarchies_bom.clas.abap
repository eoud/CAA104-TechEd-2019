class zcl_caa104_hierarchies_bom definition
  public
  final
  create public .

  public section.
    interfaces if_oo_adt_classrun.
  protected section.
  private section.
    methods test_hierarchy_bom_cds importing out type ref to if_oo_adt_classrun_out.
    methods test_hierarchy_bom_abap importing out type ref to if_oo_adt_classrun_out.
    methods setup.
ENDCLASS.



CLASS ZCL_CAA104_HIERARCHIES_BOM IMPLEMENTATION.


  method if_oo_adt_classrun~main.
    setup( ).
    test_hierarchy_bom_cds( out ).
    test_hierarchy_bom_abap( out ).
  endmethod.


  method setup.
    delete from zcaa104_bom.
    insert zcaa104_bom from table @(  value #( ( material = 'Car'           parent = ''          quantity = 1 )
                   ( material = 'Tire'          parent = 'Car'       quantity = 4 )
                   ( material = 'Screw'         parent = 'Tire'      quantity = 5 ) ) ).
  endmethod.


  method test_hierarchy_bom_abap.

    with +demo_asql_bom as ( select from zcaa104_bom fields material, parent, quantity )
           with associations ( join to one +demo_asql_bom as _to_parent
                               on +demo_asql_bom~parent = _to_parent~material ),
          +hierarchy as ( select * from hierarchy( source +demo_asql_bom
                                                   child to parent association _to_parent
                                                   start where parent is initial ) as h )
                         with hierarchy h
                         with associations ( \_to_parent as to_parent )
     select from +hierarchy as h fields h~material, h~parent, h~quantity, \to_parent-material  as parent_material, h~hierarchy_level
     into table @data(result).

    out->write( data = result name = `ABAP` ).
  endmethod.


  method test_hierarchy_bom_cds.

    select from zcaa104_bom_hierarchy as h fields h~material,
        h~parent,  h~quantity, \_to_parent-material as parent_material, h~hierarchy_level
        into table @data(result).

    out->write( data = result name = `CDS` ).
  endmethod.
ENDCLASS.
