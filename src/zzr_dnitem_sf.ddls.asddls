@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Delivery Note Item - Print Preview SF'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZZR_DNITEM_SF
  as select from I_DeliveryDocumentItem as _items
  association        to parent ZZR_DNHEADER_SF as _header on  _header.DeliveryDocument = $projection.DeliveryDocument
  association [0..1] to I_MaterialTypeText     as _text   on  _text.MaterialType = _items.MaterialTypePrimary
                                                          and _text.Language     = $session.system_language
{
//      @UI.lineItem: [{ position: 10 }]
  key cast( _items.DeliveryDocument as vbeln preserving type )     as DeliveryDocument,

      @UI.lineItem: [{ position: 20 }]
  key cast( _items.DeliveryDocumentItem as posnr preserving type ) as DeliveryDocumentItem,

      @UI.lineItem: [{ position: 30 }]
      cast( _items.Material as matnr preserving type )             as Material,

      @UI.lineItem: [{ position: 40 }]
      cast( _items.MaterialTypePrimary as mtart preserving type )  as MaterialTypePrimary,

      @UI.lineItem: [{ position: 50 }]
      _text.MaterialTypeName                                       as MaterialTypeName,

      @UI.lineItem: [{ position: 60 }]
      _items.DeliveryDocumentItemText                              as DeliveryDocumentItemText,

      @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
      @UI.lineItem: [{ position: 70 }]
      _items.ActualDeliveryQuantity                                as ActualDeliveryQuantity,

      @UI.hidden: true
      cast( _items.DeliveryQuantityUnit as vrkme preserving type ) as DeliveryQuantityUnit,

      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      @UI.lineItem: [{ position: 80 }]
      _items.ActualDeliveredQtyInBaseUnit                          as ActualDeliveredQtyInBaseUnit,

      @UI.hidden: true
      cast( _items.BaseUnit as meins preserving type )             as BaseUnit,


      _header

}
