@EndUserText.label: 'Booking Consumption View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
//--------------------------------------------------------------------------------------------------------------------
//CDS PROYECCION VIEW DE RESERVAS
//--------------------------------------------------------------------------------------------------------------------
define view entity ZCP_BOOKING_7143
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
//Se puede redireccioar de las siguientes formas:
//REDIRECTED TO: redirects a simple association.
//REDIRECTED TO COMPOSITION CHILD: redirects a composition. The redirected association must be a CDS composition.
//REDIRECTED TO PARENT: redirects a to-parent association. The redirected association must be a to-parent association.  
      _Travel     : redirected to parent ZCP_TRAVEL_7143,
      _Supplement : redirected to composition child ZCP_BOOKPSUPL_7143,
      _Connection,
      _Customer
}
