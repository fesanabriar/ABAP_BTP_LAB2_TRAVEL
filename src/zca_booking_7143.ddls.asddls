@EndUserText.label: 'Approver Consumption Booking'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
//--------------------------------------------------------------------------------------------------------------------
//CDS PARA ROL APROBADOR VIEW DE RESERVAS
//--------------------------------------------------------------------------------------------------------------------
define view entity ZCA_BOOKING_7143
  as projection on ZCD_BOOKING_7143
{
  key TravelId,
  key BookingId,
      BookingDate,
      CustomerId,
      CarrierId,
      _Carrier.Name as CarrierName,
      ConnectionId,
      FlightDate,
      FlightPrice,
      CurrencyCode,
      BookingStatus,
      LastChangedAt,
      /* Associations */
      //      _Carrier,
      _Travel : redirected to parent ZCA_TRAVEL_7143,
      _Connection,
      _Customer,
      _Supplement
}
