@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Delivery Note Header - Print Preview SF'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZZR_DNHEADER_SF
  as select from I_DeliveryDocument as _header
  composition [0..*] of ZZR_DNITEM_SF as _items
{
      @UI.facet         : [{
                             id            : 'Basis',
                             purpose       : #STANDARD,
                             type          : #IDENTIFICATION_REFERENCE,
                             label         : 'Header Information',
                             position      : 10
                           },
                           {
                             id            : 'Items',
                             purpose       : #STANDARD,
                             type          : #LINEITEM_REFERENCE,
                             targetElement : '_items',
                             label         : 'Items',
                             position      : 20
                           }
                          ]
      @UI.lineItem      : [{ position: 10, type: #WITH_URL, url: 'LinkToPDF' }]
      @UI.identification: [{ position: 10, type: #WITH_URL, url: 'LinkToPDF' }]
      @UI.selectionField: [{ position: 10 }]
  key cast( _header.DeliveryDocument as vbeln preserving type )        as DeliveryDocument,

      @UI.lineItem      : [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      cast( _header.IncotermsClassification as inco1 preserving type ) as IncotermsClassification,

      @UI.lineItem      : [{ position: 30 }]
      @UI.identification: [{ position: 30 }]
      _header.IncotermsTransferLocation                                as IncotermsTransferLocation,

      @UI.lineItem      : [{ position: 40 }]
      @UI.identification: [{ position: 40 }]
      cast( _header.ProposedDeliveryRoute as route preserving type )   as ProposedDeliveryRoute,

      @UI.lineItem      : [{ position: 50 }]
      @UI.identification: [{ position: 50 }]
      @UI.selectionField: [{ position: 20 }]
      _header.DeliveryDate                                             as DeliveryDate,

      @UI.lineItem      : [{ position: 60 }]
      @UI.identification: [{ position: 60 }]
      @UI.selectionField: [{ position: 30 }]
      _header.PlannedGoodsIssueDate                                    as PlannedGoodsIssueDate,

      @UI.lineItem      : [{ position: 70 }]
      @UI.identification: [{ position: 70 }]
      _header.GoodsIssueTime                                           as GoodsIssueTime,

      @UI.lineItem      : [{ position: 80 }]
      @UI.identification: [{ position: 80 }]
      cast( _header.SoldToParty as kunag preserving type )             as SoldToParty,

      @UI.lineItem      : [{ position: 90 }]
      @UI.identification: [{ position: 90 }]
      cast( _header.ShipToParty as kunnr preserving type )             as ShipToParty,

      @UI.hidden        : true
      concat('/sap/opu/odata4/sap/zui_dn_sf/srvd/sap/zui_dn_sf/0001/DnPdfPreview(''',
             concat(DeliveryDocument, ''')/FileContent'))              as LinkToPDF,

      _items
}
