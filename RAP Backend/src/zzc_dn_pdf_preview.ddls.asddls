@EndUserText.label: 'DN PDF Preview - Print Preview SF'
@ObjectModel.query.implementedBy: 'ABAP:ZZCL_DN_PDF_QRY'
define custom entity ZZC_DN_PDF_PREVIEW
{
  key DeliveryDocument : vbeln;

  @Semantics.largeObject: {
    mimeType: 'MimeType',
    fileName: 'FileName',
    contentDispositionPreference: #INLINE
  }
  FileContent : abap.rawstring(0);

  @Semantics.mimeType: true
  MimeType : abap.char(128);

  FileName : abap.char(128);
}
