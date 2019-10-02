class ZCL_CAA104_GEOMETRY definition public final create public.

  public section.
    interfaces:
      if_amdp_marker_hdb.

    types:
      ty_char10 type c length 10.
    class-methods:
      point2text
        importing
          !iv_srid type ty_char10 default '4326'
          !iv_type type zcaa104_geotype default 'POINT'
          !iv_x    type f
          !iv_y    type f
        returning
          value(rv_text) type string,

      point2bin
        importing
          !iv_srid type ty_char10 default '4326'
          !iv_type type zcaa104_geotype default 'POINT'
          !iv_x    type f
          !iv_y    type f
        returning
          value(rv_ewkb) type xstring,

      text2bin
        importing
          value(iv_ewkt) type string
        exporting
          value(ev_ewkb) type xstring
        raising
          cx_amdp_execution_failed.


  protected section.
  private section.

ENDCLASS.

CLASS ZCL_CAA104_GEOMETRY IMPLEMENTATION.

  method point2bin.
    text2bin( exporting iv_ewkt = point2text( iv_srid = iv_srid iv_type = iv_type iv_x = iv_x iv_y = iv_y ) importing ev_ewkb = rv_ewkb ).
  endmethod.

  method point2text.

    DATA:
      lv_ewkt_template       TYPE string VALUE `SRID=$SRSID;$GEOTYPE($XVAL$SPACE$YVAL)`,
      lv_ewkt_template_empty TYPE string VALUE `SRID=$SRSID;$GEOTYPE$SPACEEMPTY`,
      ls_value               TYPE string.

    IF iv_x IS INITIAL AND iv_y IS INITIAL.

      REPLACE `$SRSID` IN lv_ewkt_template_empty WITH iv_srid.
      CONDENSE lv_ewkt_template_empty NO-GAPS.
      REPLACE `$SPACE` IN lv_ewkt_template_empty WITH ` `.
      REPLACE `$GEOTYPE` IN lv_ewkt_template_empty WITH iv_type.
      rv_text = lv_ewkt_template_empty.
    ELSE.

      REPLACE `$SRSID` IN lv_ewkt_template WITH iv_srid.
      ls_value = iv_x.
      REPLACE `$XVAL` IN lv_ewkt_template WITH ls_value.
      ls_value = iv_y.
      REPLACE `$YVAL` IN lv_ewkt_template WITH ls_value.
      CONDENSE lv_ewkt_template NO-GAPS.
      REPLACE `$SPACE` IN lv_ewkt_template WITH ` `.
      REPLACE `$GEOTYPE` IN lv_ewkt_template WITH iv_type.
      rv_text = lv_ewkt_template.
    ENDIF.

  endmethod.

  method text2bin by database procedure for hdb language sqlscript options read-only.

    declare asewkt clob;

    asewkt = to_clob(:iv_ewkt);

    ev_ewkb = st_geomfromewkt(:asewkt).st_asewkb();

  endmethod.

ENDCLASS.
