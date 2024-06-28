@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplement'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}    
//--------------------------------------------------------------------------------------------------------------------
//CDS DE CONSUMO SUPLEMENTOS DE LAS RESERVAS
//--------------------------------------------------------------------------------------------------------------------
define view entity ZCD_BOOKPSUPL_7143
  as select from ztb_booksup_7143 as BookingSupplement
  association        to parent ZCD_BOOKING_7143 as _Booking        on  $projection.TravelId  = _Booking.TravelId
                                                                   and $projection.BookingId = _Booking.BookingId
  association [1..1] to ZCD_TRAVEL_7143         as _Travel         on  $projection.TravelId = _Travel.TravelId
  association [1..1] to /DMO/I_Supplement       as _Product        on  $projection.SupplementId = _Product.SupplementID
  association [1..*] to /DMO/I_SupplementText   as _SupplementText on  $projection.SupplementId = _SupplementText.SupplementID
{
  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      //      @Semantics.currencyCode: true
      currency_code         as CurrencyCode,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      //Asociations
      _Booking,
      _Travel,
      _Product,
      _SupplementText
}
