CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalFlightPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateTotalFlightPrice.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateStatus.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD calculateTotalFlightPrice.
  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITY zcd_travel_7143\\Booking
    FIELDS ( BookingStatus )
    WITH VALUE #( FOR <root_key> IN keys ( %key = <root_key> ) )
    RESULT DATA(lt_booking_result).

    LOOP AT lt_booking_result INTO DATA(ls_booking_result).

      CASE ls_booking_result-BookingStatus.
        WHEN 'N'. " New
        WHEN 'X'. " Canceled
        WHEN 'B'. " Booked
        WHEN OTHERS.

          APPEND VALUE #( %key = ls_booking_result-%key  ) TO failed-booking.
          APPEND VALUE #( %key = ls_booking_result-%key
             %msg = new_message( id = /dmo/cx_flight_legacy=>status_is_not_valid-msgid
           number = /dmo/cx_flight_legacy=>status_is_not_valid-msgno
               v1 = ls_booking_result-BookingStatus
         severity = if_abap_behv_message=>severity-error )
            %element-BookingStatus = if_abap_behv=>mk-on ) TO reported-booking.

      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
