class zcl_caa104_hierarchies_demo definition
  public
  final
  create public .

  public section.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    METHODS:
      define_hierarchy_in_asql importing out type ref to if_oo_adt_classrun_out,
      select_special_fields importing out type ref to if_oo_adt_classrun_out,
      select_from_cds_hierarchy importing out type ref to if_oo_adt_classrun_out,
      select_special_from_cds importing out type ref to if_oo_adt_classrun_out,
      select_hierarchy_descendants importing out type ref to if_oo_adt_classrun_out,
      select_hierarchy_ancestors importing out type ref to if_oo_adt_classrun_out,
      hierarchy_desc_aggregate importing out type ref to if_oo_adt_classrun_out,
      setup.
endclass.



class zcl_caa104_hierarchies_demo implementation.

  METHOD define_hierarchy_in_asql.

    WITH +base_view AS ( SELECT * FROM zcaa104_employee ) WITH ASSOCIATIONS
      ( JOIN TO ONE +base_view AS _to_manager ON +base_view~sales_org = _to_manager~sales_org AND
                                                   +base_view~manager   = _to_manager~employee ),
        +hierarchy AS ( SELECT * FROM HIERARCHY( SOURCE +base_view
                                                 CHILD TO PARENT ASSOCIATION _to_manager
                                                 START WHERE manager IS INITIAL ) )
   SELECT FROM +hierarchy FIELDS * INTO TABLE @DATA(result).
   out->write(  data = result name = 'define_hierarchy_in_asql' )->write( '------------------------------------------------------------------------------------------' ).
  ENDMETHOD.

  METHOD select_special_fields.

   WITH +base_view AS ( SELECT * FROM zcaa104_employee ) WITH ASSOCIATIONS ( JOIN TO ONE +base_view AS _to_manager ON +base_view~sales_org = _to_manager~sales_org AND
                                                                                                                    +base_view~manager   = _to_manager~employee ),
         +hierarchy AS ( SELECT * FROM HIERARCHY( SOURCE +base_view
                                                  CHILD TO PARENT ASSOCIATION _to_manager
                                                  START WHERE manager IS INITIAL ) AS h ) WITH HIERARCHY h WITH ASSOCIATIONS ( \_to_manager )
    SELECT FROM +hierarchy FIELDS +hierarchy~sales_org as h_sales_org, +hierarchy~employee as h_employee, +hierarchy~manager as h_manager,+hierarchy~department as h_departement,
    +hierarchy~hierarchy_rank,
     +hierarchy~hierarchy_level, \_to_manager-employee AS manager
     INTO TABLE @DATA(result).
   out->write(  data = result name = 'select_special_fields' )->write( '------------------------------------------------------------------------------------------' ).
ENDMETHOD.



  METHOD select_from_cds_hierarchy.

    SELECT FROM zcaa104_Employee_Hierarchy
           FIELDS *
      INTO TABLE @DATA(result).
   out->write(  data = result name = 'select_from_cds_hierarchy' )->write( '------------------------------------------------------------------------------------------' ).
  ENDMETHOD.


  METHOD select_special_from_cds.

    SELECT FROM zcaa104_Employee_Hierarchy AS h
           FIELDS h~sales_org, h~Employee, h~manager, h~my_Hierarchy_Rank, hierarchy_rank,
           hierarchy_level, hierarchy_is_orphan
      INTO TABLE @DATA(result).
   out->write(  data = result name = 'select_special_from_cds' )->write( '------------------------------------------------------------------------------------------' ).
  ENDMETHOD.


  METHOD select_hierarchy_descendants.

    DATA employee TYPE c LENGTH 30 VALUE `Thorsten`.
    SELECT employee, hierarchy_level FROM HIERARCHY_DESCENDANTS( SOURCE zcaa104_employee_hierarchy
                                         START WHERE employee = @employee
                                          distance from 0 to 5 )
      INTO TABLE @DATA(result).
   out->write(  data = result name = 'select_hierarchy_descendants' )->write( '------------------------------------------------------------------------------------------' ).
  ENDMETHOD.


  METHOD select_hierarchy_ancestors.

    DATA employee TYPE c LENGTH 30 VALUE `Thilo`.
    SELECT FROM HIERARCHY_ANCESTORS( SOURCE zcaa104_employee_hierarchy
                                       START WHERE employee = @employee ) as h
       fields employee, hierarchy_distance
      INTO TABLE @DATA(result).
   out->write(  data = result name = 'select_hierarchy_ancestors' )->write( '------------------------------------------------------------------------------------------' ).
  ENDMETHOD.


  METHOD hierarchy_desc_aggregate.

    DATA sales_org TYPE c LENGTH 30 VALUE `Startup Company`.
    DATA employee TYPE c LENGTH 30 VALUE `Thorsten`.

    SELECT employee, salary FROM HIERARCHY_DESCENDANTS_AGGREGATE( SOURCE zcaa104_employee_hierarchy AS h
                                                                  JOIN zcaa104_salary AS s ON h~sales_org = s~sales_org AND
                                                                                           h~employee  = s~employee
                                                                  MEASURES SUM( s~salary ) AS salary
                                                                  WHERE sales_org = @sales_org AND
                                                                        employee = @employee )
      INTO TABLE @DATA(result).
   out->write(  data = result name = 'hierarchy_desc_aggregate' )->write( '------------------------------------------------------------------------------------------' ).
  ENDMETHOD.


  method setup.
    data employee type table of zcaa104_employee.

    employee = value #( ( sales_org = 'My Company' employee = 'Harald'                      department = 'Department 1' )
                        ( sales_org = 'My Company' employee = 'Thomas'   manager = 'Harald' department = 'Department 1' )
                        ( sales_org = 'My Company' employee = 'Sonja'    manager = 'Thomas' department = 'Department 1' )
                        ( sales_org = 'My Company' employee = 'Philipp'  manager = 'Sonja'  department = 'Department 1' )
                        ( sales_org = 'My Company' employee = 'Klaus'    manager = 'Sonja'  department = 'Department 1' )
                        ( sales_org = 'My Company' employee = 'Thilo'    manager = 'Thomas' department = 'Department 1' )
                        ( sales_org = 'My Company' employee = 'Anna'     manager = 'Thilo'  department = 'Department 1' )

                        ( sales_org = 'My Company' employee = 'Börn'                        department = 'Department 2' )
                        ( sales_org = 'My Company' employee = 'Felix'    manager = 'Björn'  department = 'Department 2' )

                        ( sales_org = 'Startup Company' employee = 'Annabell'                          department = 'Department 1' )
                        ( sales_org = 'Startup Company' employee = 'Thorsten'    manager = 'Annabell'  department = 'Department 1' )
                        ( sales_org = 'Startup Company' employee = 'Philippa'    manager = 'Thorsten'  department = 'Department 1' )
                        ( sales_org = 'Startup Company' employee = 'Henriette'   manager = 'Philippa'  department = 'Department 1' )
                        ( sales_org = 'Startup Company' employee = 'Klaus'       manager = 'Henriette' department = 'Department 1' )
                        ( sales_org = 'Startup Company' employee = 'Thilo'       manager = 'Henriette' department = 'Department 1' )
                        ( sales_org = 'Startup Company' employee = 'Anna'        manager = 'Philippa'  department = 'Department 1' )
    ).

    modify zcaa104_employee from table @employee.

    data salary type table of zcaa104_salary.

    salary = value #(   ( sales_org = 'My Company' employee = 'Harald'   salary = '120000' currency = 'EUR' )
                        ( sales_org = 'My Company' employee = 'Thomas'   salary = '100000' currency = 'EUR' )
                        ( sales_org = 'My Company' employee = 'Sonja'    salary = '90000' currency = 'EUR' )
                        ( sales_org = 'My Company' employee = 'Philipp'  salary = '80000' currency = 'EUR' )
                        ( sales_org = 'My Company' employee = 'Klaus'    salary = '60000' currency = 'EUR' )
                        ( sales_org = 'My Company' employee = 'Thilo'    salary = '50000' currency = 'EUR' )
                        ( sales_org = 'My Company' employee = 'Anna'     salary = '30000' currency = 'EUR' )

                        ( sales_org = 'My Company' employee = 'Börn'     salary = '500000' currency = 'EUR' )
                        ( sales_org = 'My Company' employee = 'Felix'    salary = '250000' currency = 'EUR' )

                        ( sales_org = 'Startup Company' employee = 'Annabell'   salary = '75000' currency = 'EUR'   )
                        ( sales_org = 'Startup Company' employee = 'Thorsten'   salary = '50000' currency = 'EUR'   )
                        ( sales_org = 'Startup Company' employee = 'Philippa'   salary = '30000' currency = 'EUR'   )
                        ( sales_org = 'Startup Company' employee = 'Henriette'  salary = '20000' currency = 'EUR'   )
                        ( sales_org = 'Startup Company' employee = 'Klaus'      salary = '15000' currency = 'EUR'   )
                        ( sales_org = 'Startup Company' employee = 'Thilo'      salary = '14325' currency = 'EUR'   )
                        ( sales_org = 'Startup Company' employee = 'Anna'       salary = '12100' currency = 'EUR'   )
    ).

    modify zcaa104_salary from table @salary.

  endmethod.

  METHOD if_oo_adt_classrun~main.
    setup( ).
    define_hierarchy_in_asql( out ).
    select_special_fields( out ).
    select_from_cds_hierarchy( out ).
    select_special_from_cds( out ).
    select_hierarchy_descendants( out ).
    select_hierarchy_ancestors( out ).
    hierarchy_desc_aggregate( out ).
  ENDMETHOD.
endclass.
