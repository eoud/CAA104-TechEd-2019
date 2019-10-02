class zcl_caa104_airports definition public final create public .

  public section.

    types:
      tt_airports type standard table of zcaa104_cds_airport with default key.

    interfaces:
      if_oo_adt_classrun.

    methods:
       create_data,
       select_airports_asql
         returning
           value(rt_airports) type tt_airports,

       select_airports_cds
         returning
           value(rt_airports) type tt_airports.

  protected section.

  private section.
    methods:
      _new_airport
        importing
          !iv_code             type zcaa104_airports-code
          !iv_tracka           type zcaa104_airports-tracka_size
          !iv_trackb           type zcaa104_airports-trackb_size
          !iv_construction     type zcaa104_airports-construction_date
          !iv_next_maintenance type zcaa104_airports-next_maintenance
          !iv_x                type f
          !iv_y                type f.

endclass.

class zcl_caa104_airports implementation.

  method create_data.

    delete from zcaa104_airports.

    _new_airport( iv_code = 'FRA'  iv_tracka = 3000  iv_trackb = '2700.12' iv_construction = '19360708' iv_next_maintenance = '20200101' iv_x = 50 iv_y = 8 ).
    _new_airport( iv_code = 'BER'  iv_tracka = 3600  iv_trackb = '4000.00' iv_construction = '20200101' iv_next_maintenance = '20201231' iv_x = 52 iv_y = 13 ).
    _new_airport( iv_code = 'JFK'  iv_tracka = 4423  iv_trackb = '3682.00' iv_construction = '19480701' iv_next_maintenance = '20220102' iv_x = 40 iv_y = -73 ).
    _new_airport( iv_code = 'BCN'  iv_tracka = 3352  iv_trackb = '2528.00' iv_construction = '19180101' iv_next_maintenance = '20230102' iv_x = 41 iv_y = -2 ).

  endmethod.

  method _new_airport.

    data(ls_airport) = value zcaa104_airports( code              = iv_code
                                               tracka_size       = iv_tracka
                                               trackb_size       = iv_trackb
                                               construction_date = iv_construction
                                               next_maintenance  = iv_next_maintenance
                                               location          = zcl_caa104_geometry=>point2bin( iv_x = iv_x iv_y = iv_y )
                                              ).
    insert into zcaa104_airports values @ls_airport.


  endmethod.

  method select_airports_cds.

    select *
      from zcaa104_cds_airport( iv_current_date = '20191008' )
     order by nextMaintenance
      into table @rt_airports.

  endmethod.

  method select_airports_asql.

    data:
      lv_date type d.

    lv_date = '20191008'.

    select code, next_maintenance, construction_date
      from zcaa104_airports
      into table @data(lt_airports).

    rt_airports = value #( for ls_airport in lt_airports ( code              = ls_airport-code
                                                           days2maintenance  = ls_airport-next_maintenance - lv_date
                                                           construction_date = ls_airport-construction_date
                                                           NextMaintenance   = ls_airport-next_maintenance - lv_date
                                                           Age               = lv_date - ls_airport-construction_date ) ).

*    "-----------------------------------------------------------------------------------------------
*    " ABAP SQL function coming in the next Release
*    "-----------------------------------------------------------------------------------------------
*    select from zcaa104_airports
*    fields code,
*           construction_date as ConstructionDate,
*           datn_days_between( cast( @lv_date as datn ), next_maintenance ) as NextMaintenance,
*           datn_days_between( construction_date, cast( @lv_date as datn ) ) as Age
*      into table @data(lt_airports1).


  endmethod.

  method if_oo_adt_classrun~main.

    data:
      oHandler type ref to zcl_caa104_airports.

    oHandler = new zcl_caa104_airports( ).

    oHandler->create_data( ).

    data(lt_airports_cds) = oHandler->select_airports_cds( ).

    out->write( data = lt_airports_cds name = 'CDS' ).

*    data(lt_airports_asql) = oHandler->select_airports_asql( ).
*    out->write( data = lt_airports_asql name = 'ABAP SQL' ).


  endmethod.

endclass.
