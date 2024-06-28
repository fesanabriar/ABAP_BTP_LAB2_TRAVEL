@EndUserText.label: 'Travel Consumtion Procesor'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
//--------------------------------------------------------------------------------------------------------------------
//CDS PROYECCION VIEW ROOT DE VIAJES
//--------------------------------------------------------------------------------------------------------------------
define root view entity ZCP_TRAVEL_7143
  as projection on ZCD_TRAVEL_7143
{
  key TravelId,
      AgencyId,
      _Agency.Name       as AgencyName,
      CustomerId,
      _Customer.LastName as CustomerName,
      BeginDate,
      EndDate,
      BookingFee,
      TotalPrice,
      CurrencyCode,
      OverallStatus,
      Description,
      LastChangedAt,
      /* Associations */
      //Se puede redireccioar de las siguientes formas:
      //REDIRECTED TO: redirects a simple association.
      //REDIRECTED TO COMPOSITION CHILD: redirects a composition. The redirected association must be a CDS composition.
      //REDIRECTED TO PARENT: redirects a to-parent association. The redirected association must be a to-parent association.
      _Booking : redirected to composition child ZCP_BOOKING_7143,
      _Agency,
      _Customer
}
