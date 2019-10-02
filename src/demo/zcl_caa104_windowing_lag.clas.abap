CLASS zcl_caa104_windowing_lag DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS special_window_functions importing out TYPE REF TO if_oo_adt_classrun_out.
    METHODS setup.
ENDCLASS.



CLASS zcl_caa104_windowing_lag IMPLEMENTATION.
  METHOD special_window_functions.

    WITH +ctgry AS ( SELECT FROM Z_CAA104_SALES_ORDER_ITEM AS item
                        FIELDS sales_order_nr, item_category, SUM( price ) AS sum
                      GROUP BY sales_order_nr, item_category ),
         +rank AS ( SELECT FROM +ctgry
                        FIELDS sales_order_nr,
                        item_category,
                        RANK( ) OVER( PARTITION BY sales_order_nr ORDER BY sum DESCENDING ) AS rank,
                        sum AS total_price,
                        sum / SUM( sum ) OVER( PARTITION BY sales_order_nr ) AS percentage,
                       lag( sum )
                         OVER( PARTITION BY sales_order_nr ORDER BY sum DESCENDING ) as lag,
                        coalesce( sum - lag( sum )
                         OVER( PARTITION BY sales_order_nr ORDER BY sum DESCENDING ), 0 ) as difference_to_preceding )
    SELECT FROM +rank
      FIELDS sales_order_nr, item_category, rank, total_price, percentage, lag, difference_to_preceding,
             sum( difference_to_preceding ) over( partition by sales_order_nr order by rank ) as difference_to_first
      ORDER BY rank ascending
      INTO TABLE @DATA(result).

    loop at result assigning field-symbol(<wa>).
      <wa>-difference_to_first = round( val = <wa>-difference_to_first dec = 0 ).
    endloop.
    out->write( result ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    setup( ).
    special_window_functions( out ).
  ENDMETHOD.

  METHOD setup.
    delete from zcaa104_items.

    DATA soitem TYPE TABLE OF zcaa104_items.

    soitem = VALUE #( ( sales_order_nr = 1 item_category  = 'Laptop' item_nr        = 1 price          = '10000' currency       = 'EUR' )
                      ( sales_order_nr = 1 item_category  = 'Laptop' item_nr        = 2 price          = '12000' currency       = 'EUR' )
                      ( sales_order_nr = 1 item_category  = 'Laptop' item_nr        = 3 price          = '5000'  currency       = 'EUR' )
                      ( sales_order_nr = 1 item_category  = 'Desktop' item_nr        = 4 price          = '5000'  currency       = 'EUR' )
                      ( sales_order_nr = 1 item_category  = 'Desktop' item_nr        = 5 price          = '6000'  currency       = 'EUR' )
                      ( sales_order_nr = 1 item_category  = 'Desktop' item_nr        = 6 price          = '7500'  currency       = 'EUR' )
                      ( sales_order_nr = 1 item_category  = 'Smart Phone' item_nr        = 7 price          = '712'  currency       = 'EUR' )
                      ( sales_order_nr = 1 item_category  = 'Smart Phone' item_nr        = 8 price          = '613'  currency       = 'EUR' )
                      ( sales_order_nr = 1 item_category  = 'Smart Phone' item_nr        = 9 price          = '556'  currency       = 'EUR' )

    ).

    INSERT zcaa104_items FROM TABLE @soitem.
  endmethod.

ENDCLASS.
