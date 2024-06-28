@EndUserText.label: 'Approver Consumption Travel'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
//--------------------------------------------------------------------------------------------------------------------
//CDS PARA ROL APROBADOR VIEW ROOT DE VIAJES
//--------------------------------------------------------------------------------------------------------------------
define root view entity ZCA_TRAVEL_7143
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
      _Booking : redirected to composition child ZCA_BOOKING_7143,
      _Agency,
      _Customer
}
