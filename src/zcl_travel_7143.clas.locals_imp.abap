CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS createTravelByTemplate FOR MODIFY
      IMPORTING keys FOR ACTION Travel~createTravelByTemplate RESULT result.

    METHODS reCalcTotPrice FOR MODIFY
      IMPORTING keys FOR ACTION Travel~reCalcTotPrice.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateStatus.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITY zcd_travel_7143
    FROM VALUE #( FOR keyval IN keys ( %key = keyval-%key ) )
    RESULT DATA(lt_travel_result).

    result = VALUE #( FOR ls_travel IN lt_travel_result ( %key                           = ls_travel-%key
*                                                       %field-TravelId                = if_abap_behv=>fc-f-read_only "PENDIENTE
                                                       %features-%action-rejectTravel = COND #( WHEN ls_travel-OverallStatus = 'X'
    THEN if_abap_behv=>fc-o-disabled
    ELSE if_abap_behv=>fc-o-enabled )
    %features-%action-acceptTravel = COND #( WHEN ls_travel-OverallStatus = 'A'
    THEN if_abap_behv=>fc-o-disabled
    ELSE if_abap_behv=>fc-o-enabled ) ) ).

  ENDMETHOD.

  METHOD get_instance_authorizations.

    DATA(lv_auth) = COND #( WHEN cl_abap_context_info=>get_user_technical_name( ) EQ 'CB9980007143' "Usuario'
    THEN if_abap_behv=>auth-allowed              "Permitido
    ELSE if_abap_behv=>auth-unauthorized ).      "No Permitido

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_keys>).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<ls_result>).
      <ls_result> = VALUE #( %key = <ls_keys>-%key
      %op-%update = lv_auth
      %delete = lv_auth
      %action-createTravelByTemplate = lv_auth
      %action-acceptTravel = lv_auth
      %action-rejectTravel = lv_auth
      %assoc-_Booking = lv_auth ).
    ENDLOOP.

  ENDMETHOD.

  METHOD acceptTravel.
*   Actualiza la entidad zcd_travel_7143
    MODIFY ENTITIES OF zcd_travel_7143 IN LOCAL MODE
             ENTITY travel
      UPDATE FIELDS ( OverallStatus )
      WITH VALUE #( FOR key IN keys ( TravelId      = key-TravelId
                                      OverallStatus = 'A' ) ) " Accepted
      FAILED failed
      REPORTED reported.

*   Consulta modificacion
    READ ENTITIES OF zcd_travel_7143 IN LOCAL MODE
    ENTITY travel
    FIELDS ( AgencyId
             CustomerId
             BeginDate
             EndDate
             BookingFee
             TotalPrice
             CurrencyCode
             OverallStatus
             Description
             CreatedBy
             CreatedAt
             LastChangedAt
             LastChangedBy )
    WITH VALUE #( FOR key IN keys ( TravelId = key-TravelId ) )
    RESULT DATA(lt_travel).

*   Carga el resultado
    result = VALUE #( FOR travel IN lt_travel ( TravelId = travel-TravelId
                                                %param   = travel ) ).

*   PARTE PARA EL APROBADOR
    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      APPEND VALUE #( TravelId = <ls_travel>-TravelId
      %msg = new_message( id = 'ZCM_MESSAGE'
      number = '001'
      v1 = <ls_travel>-OverallStatus
      severity = if_abap_behv_message=>severity-success )
      %element-OverallStatus = if_abap_behv=>mk-on ) TO reported-travel.

    ENDLOOP.

  ENDMETHOD.

  METHOD createTravelByTemplate.

*   Busca el maximo ID de Travel
    SELECT MAX( travel_id ) FROM ztb_travel_7143 INTO @DATA(lv_travel_id).

*   Busca el travel Id seleccionado
    READ ENTITY zcd_travel_7143 FIELDS ( TravelId AgencyId CustomerId BookingFee TotalPrice CurrencyCode )
    WITH VALUE #( FOR travel IN keys ( %key = travel-%key ) )
    RESULT DATA(lt_read_result)
    FAILED failed
    REPORTED reported.

*   Definicion de datos
    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).
    DATA lt_create TYPE TABLE FOR CREATE zcd_travel_7143\\travel.

    lt_create       = VALUE #( FOR row IN lt_read_result INDEX INTO idx
    ( TravelId      = lv_travel_id + idx
      AgencyId      = row-AgencyId
      CustomerId    = row-CustomerId
      BeginDate     = lv_today
      EndDate       = lv_today + 30
      BookingFee    = row-BookingFee
      TotalPrice    = row-TotalPrice
      CurrencyCode  = row-CurrencyCode
      description   = 'Comments here'
      OverallStatus = 'O' ) ).

*   Actualiza la entidad zcd_travel_7143
    MODIFY ENTITIES OF zcd_travel_7143
    IN LOCAL MODE ENTITY travel
    CREATE FIELDS ( TravelId
                    AgencyId
                    CustomerId
                    BeginDate
                    EndDate
                    BookingFee
                    TotalPrice
                    CurrencyCode
                    description
                    OverallStatus )
               WITH lt_create
             MAPPED mapped
             FAILED failed
           REPORTED reported.

*   Carga el resultado
    result = VALUE #( FOR create IN lt_create INDEX INTO idx
                    ( %cid_ref = keys[ idx ]-%cid_ref
                      %key     = keys[ idx ]-TravelId
                      %param   = CORRESPONDING #( create ) ) ).

  ENDMETHOD.

  METHOD reCalcTotPrice.
  ENDMETHOD.

  METHOD rejectTravel.

*   Actualiza la entidad zcd_travel_7143
    MODIFY ENTITIES OF zcd_travel_7143 IN LOCAL MODE
    ENTITY travel
    UPDATE FROM VALUE #( FOR key IN keys ( TravelId               = key-TravelId
                                           OverallStatus          = 'X' " Canceled
                                           %control-OverallStatus = if_abap_behv=>mk-on ) )
    FAILED failed
    REPORTED reported.

*   Consulta modificacion
    READ ENTITIES OF zcd_travel_7143 IN LOCAL MODE
    ENTITY travel
    FIELDS ( AgencyId
             CustomerId
             BeginDate
             EndDate
             BookingFee
             TotalPrice
             CurrencyCode
             OverallStatus
             Description
             CreatedBy
             CreatedAt
             LastChangedAt
             LastChangedBy )
    WITH VALUE #( FOR key IN keys ( TravelId = key-TravelId ) )
    RESULT DATA(lt_travel).

*   Carga el resultado
    result = VALUE #( FOR travel IN lt_travel ( TravelId = travel-TravelId
                                                  %param = travel ) ).
**************************************************************************************
*   PARTE PARA EL APROBADOR
**************************************************************************************
    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
      APPEND VALUE #( TraveliD = <ls_travel>-TravelId
      %msg = new_message( id = 'ZCM_MESSAGE'
      number = '002'
      v1 = <ls_travel>-OverallStatus
      severity = if_abap_behv_message=>severity-success )
      %element-OverallStatus = if_abap_behv=>mk-on ) TO reported-travel.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateCustomer.

    READ ENTITIES OF zcd_travel_7143 IN LOCAL MODE
    ENTITY Travel
    FIELDS ( CustomerId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    DATA lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.
    lt_customer = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING customer_id = CustomerId EXCEPT * ).

    DELETE lt_customer WHERE customer_id IS INITIAL.
    IF lt_customer IS NOT INITIAL.
      SELECT FROM /dmo/customer FIELDS customer_id
      FOR ALL ENTRIES IN @lt_customer
      WHERE customer_id = @lt_customer-customer_id
      INTO TABLE @DATA(lt_customer_db).
    ENDIF.

    LOOP AT lt_travel INTO DATA(ls_travel).
      IF ls_travel-CustomerId IS INITIAL
      OR NOT line_exists( lt_customer_db[ customer_id = ls_travel-CustomerId ] ).
        APPEND VALUE #( TravelId = ls_travel-TravelId ) TO failed-travel.
        APPEND VALUE #( travelId = ls_travel-TravelId
        %msg = new_message( id = '/DMO/CM_FLIGHT_LEGAC'
        number = '002'
        v1 = ls_travel-CustomerId
        severity = if_abap_behv_message=>severity-error )
        %element-CustomerID = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateDates.

    READ ENTITY zcd_travel_7143\\Travel FIELDS ( BeginDate EndDate ) WITH
    VALUE #( FOR <root_key> IN keys ( %key = <root_key> ) )
    RESULT DATA(lt_travel_result).

    LOOP AT lt_travel_result INTO DATA(ls_travel_result).

      IF ls_travel_result-EndDate < ls_travel_result-BeginDate.

        APPEND VALUE #( %key = ls_travel_result-%key
        TravelId = ls_travel_result-TravelId ) TO failed-travel.
        APPEND VALUE #( %key = ls_travel_result-%key
                        %msg = new_message( id = /dmo/cx_flight_legacy=>end_date_before_begin_date-msgid
                      number = /dmo/cx_flight_legacy=>end_date_before_begin_date-msgno
                          v1 = ls_travel_result-BeginDate
                          v2 = ls_travel_result-EndDate
                          v3 = ls_travel_result-TravelId
                    severity = if_abap_behv_message=>severity-error )
          %element-BeginDate = if_abap_behv=>mk-on
            %element-EndDate = if_abap_behv=>mk-on ) TO reported-travel.

      ELSEIF ls_travel_result-BeginDate < cl_abap_context_info=>get_system_date( ).

        APPEND VALUE #( %key = ls_travel_result-%key
                    TravelId = ls_travel_result-TravelId ) TO failed-travel.
        APPEND VALUE #( %key = ls_travel_result-%key
                        %msg = new_message( id = /dmo/cx_flight_legacy=>begin_date_before_system_date-msgid
                      number = /dmo/cx_flight_legacy=>begin_date_before_system_date-msgno
                    severity = if_abap_behv_message=>severity-error )
          %element-BeginDate = if_abap_behv=>mk-on
            %element-EndDate = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITY zcd_travel_7143\\Travel FIELDS ( OverallStatus ) WITH
    VALUE #( FOR <root_key> IN keys ( %key = <root_key> ) )
    RESULT DATA(lt_travel_result).

    LOOP AT lt_travel_result INTO DATA(ls_travel_result).
      CASE ls_travel_result-OverallStatus.
        WHEN 'O'. " Open
        WHEN 'X'. " Cancelled
        WHEN 'A'. " Accepted
        WHEN OTHERS.
          APPEND VALUE #( %key = ls_travel_result-%key ) TO failed-travel.
          APPEND VALUE #( %key = ls_travel_result-%key
                          %msg = new_message( id = /dmo/cx_flight_legacy=>status_is_not_valid-msgid
                        number = /dmo/cx_flight_legacy=>status_is_not_valid-msgno
                            v1 = ls_travel_result-OverallStatus
                      severity = if_abap_behv_message=>severity-error )
        %element-OverallStatus = if_abap_behv=>mk-on ) TO reported-travel.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZCD_TRAVEL_7143 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZCD_TRAVEL_7143 IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
