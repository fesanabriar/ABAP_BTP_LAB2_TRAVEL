@EndUserText.label: 'Booking Supplement Consumption View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true //Esta proyeccion permite la creacion de Metadata
@Search.searchable: true        //Permite busqueda avanzada
//--------------------------------------------------------------------------------------------------------------------
//CDS PROYECCION VIEW DE SUPLEMENTOS DE RESERVAS
//--------------------------------------------------------------------------------------------------------------------
define view entity ZCP_BOOKPSUPL_7143
  as projection on ZCD_BOOKPSUPL_7143
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      SupplementId,
      _SupplementText.Description as SupplementDescription : localized, //Traduce al lenguaje de sesion
      Price,
      CurrencyCode,
      LastChangedAt,
      /* Associations */
//Se puede redireccioar de las siguientes formas:
//REDIRECTED TO: redirects a simple association.
//REDIRECTED TO COMPOSITION CHILD: redirects a composition. The redirected association must be a CDS composition.
//REDIRECTED TO PARENT: redirects a to-parent association. The redirected association must be a to-parent association.      
      _Travel  : redirected to ZCP_TRAVEL_7143,          // Redireccion simple
      _Booking : redirected to parent ZCP_BOOKING_7143,  // Redirecciona a Padre
      _Product
      //      _SupplementText,
}
