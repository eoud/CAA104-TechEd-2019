class zcl_caa104_spacial_data_amdp definition public final create public.

public section.
  interfaces:
    if_amdp_marker_hdb,
    if_oo_adt_classrun.

  types:
    tt_customer type standard table of zcaa104_s_customer with default key.

  class-methods:
    generate_data,

    run
      returning
        value(rt_customer) type tt_customer.

  class-methods:
    coverage
      importing
        value(iv_state_id) type int4
      exporting
        value(et_customer) type tt_customer.

protected section.

private section.
  class-methods:
    _load_states,
    _load_customers,
    _new_customer
      importing
        !iv_id type zcaa104_customer-id.

endclass.

class zcl_caa104_spacial_data_amdp implementation.

  method _load_states.

    data:
      ls_state type zcaa104_state.

    select count( * ) from zcaa104_state.
    if sy-dbcnt >= 2.
      return.
    endif.
    delete from zcaa104_state.

    ls_state = value #( id       = 1000
                        name     = 'Baden-Württemberg'
                        boundary = '0103000020E610000001000000050000000000000000000000000000000000000000000000000024400000000000000000000000000000244000000000000024400000000000000000000000000000244000000000000000000000000000000000' ).
    insert into zcaa104_state values @ls_state.

    ls_state = value #( id       = 2000
                        name     = 'Bayern'
                        boundary = '0103000020E610000001000000050000000000000000002440000000000000000000000000000034400000000000000000000000000000344000000000000024400000000000002440000000000000244000000000000024400000000000000000' ).
    insert into zcaa104_state values @ls_state.

  endmethod.

  method generate_data.

    "Load States.
    _load_states( ).

    "Load Customers
    _load_customers( ).

  endmethod.

  method _load_customers.

    select count( * ) from zcaa104_customer.
    if sy-dbcnt >= 5000.
      return.
    endif.

    delete from zcaa104_customer.

    do 5000 times.
      _new_customer( iv_id = sy-index ).
    enddo.

  endmethod.

  method _new_customer.

    data:
      ls_customer type zcaa104_customer,
      lv_name     type zcaa104_customer-name,
      lv_location type string.

      lv_name  = |Customer { iv_id } |.

      data(lv_latitude)  = cl_abap_random_int=>create( seed = cl_abap_random=>seed( ) min  = -90  max  = 90 )->get_next( ).
      data(lv_longitude) = cl_abap_random_int=>create( seed = cl_abap_random=>seed( ) min  = -180 max  = 180 )->get_next( ).

      lv_location = zcl_caa104_geometry=>point2text( iv_srid = '4326' iv_type = 'POINT' iv_x = conv #( lv_longitude )  iv_y = conv #( lv_latitude ) ).

      ls_customer = value #( id       = iv_id
                             name     = lv_name
                             sales    = cl_abap_random_int=>create( seed = cl_abap_random=>seed( )  min  = 300  max  = 5000000 )->get_next( )
                           ).

      try.
        zcl_caa104_geometry=>text2bin( exporting iv_ewkt = lv_location importing ev_ewkb = ls_customer-location ).
      catch cx_amdp_execution_failed.
        "TODO
      endtry.

      insert into zcaa104_customer values @ls_customer.

  endmethod.

  method coverage by database procedure for hdb language sqlscript options read-only using zcaa104_customer zcaa104_state.

    et_customer = select id,  name, sales, location
             from zcaa104_customer as c
            where ( select  boundary.st_covers(c.location) from zcaa104_state
                     where id = :iv_state_id ) = 1
            order by id;

  endmethod.

  method run.

    COVERAGE( exporting iv_state_id = '1000' importing et_customer = rt_customer  ).

  endmethod.

  method if_oo_adt_classrun~main.

    zcl_caa104_spacial_data_amdp=>generate_data( ).

    data(lt_customers) = zcl_caa104_spacial_data_amdp=>run( ).

    out->write( lt_customers ).

  endmethod.

endclass.
