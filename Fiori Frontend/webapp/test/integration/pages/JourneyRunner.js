sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"zprintpreview/test/integration/pages/DeliveryHeaderList",
	"zprintpreview/test/integration/pages/DeliveryHeaderObjectPage"
], function (JourneyRunner, DeliveryHeaderList, DeliveryHeaderObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('zprintpreview') + '/test/flp.html#app-preview',
        pages: {
			onTheDeliveryHeaderList: DeliveryHeaderList,
			onTheDeliveryHeaderObjectPage: DeliveryHeaderObjectPage
        },
        async: true
    });

    return runner;
});

