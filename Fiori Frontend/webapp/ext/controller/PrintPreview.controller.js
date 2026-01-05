sap.ui.define(
  [
    "sap/ui/core/mvc/ControllerExtension",
    "sap/m/MessageToast",
    "sap/m/MessageBox",
  ],
  function (ControllerExtension, MessageToast, MessageBox) {
    "use strict";

    return ControllerExtension.extend(
      "zprintpreview.ext.controller.PrintPreview",
      {
        // this section allows to extend lifecycle hooks or hooks provided by Fiori elements
        override: {
          /**
           * Called when a controller is instantiated and its View controls (if available) are already created.
           * Can be used to modify the View before it is displayed, to bind event handlers and do other one-time initialization.
           * @memberOf zprintpreview.ext.controller.PrintPreview
           */
          onInit: function () {
            // you can access the Fiori elements extensionAPI via this.base.getExtensionAPI
            var oModel = this.base.getExtensionAPI().getModel();
          },
        },
        onPrintPreview: function (oContext, aSelectedContexts) {
          const oModel = this.base.getExtensionAPI().getModel();
          const sBaseUrl = oModel.getServiceUrl();

          const sDeliveryDocument =
            aSelectedContexts[0].getProperty("DeliveryDocument");

          const sUrl = `${sBaseUrl}/DnPdfPreview('${sDeliveryDocument}')/FileContent`;

          window.open(sUrl, "_blank");
        },
      }
    );
  }
);
