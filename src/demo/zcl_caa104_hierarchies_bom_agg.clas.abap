class zcl_caa104_hierarchies_bom_agg definition
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
endclass.



class zcl_caa104_hierarchies_bom_agg implementation.
  method test_hierarchy_bom_cds.

    select * from hierarchy_ancestors_aggregate( source zcaa104_bom_hierarchy
                                                 start where parent = 'Car'
                                                 measures product( quantity ) as total_quantity  " new aggregate function
                                                 where material = 'Screw' )
      into table @data(result).

    out->write( data = result name = `CDS` ).
  endmethod.

  method test_hierarchy_bom_abap.

    with +demo_asql_bom as ( select from zcaa104_bom fields material, parent, quantity )
           with associations ( join to one +demo_asql_bom as _to_parent
                               on +demo_asql_bom~parent = _to_parent~material ),
          +hierarchy as ( select * from hierarchy( source +demo_asql_bom
                                                   child to parent association _to_parent
                                                   start where parent is initial
                                                   siblings order by material ) as h )
                         with hierarchy h
                         with associations ( \_to_parent as to_parent )
     select from hierarchy_ancestors_aggregate( source +hierarchy
                                                start where parent = 'Car'
                                                measures product( quantity ) as total_quantity
                                                where material = 'Screw' )
     fields *
     into table @data(result).
    out->write( data = result name = `ABAP` ).
  endmethod.

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

endclass.
