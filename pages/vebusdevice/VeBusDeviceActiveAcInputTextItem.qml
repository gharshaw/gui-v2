/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListTextItem {
	property var veBusDevice

	DataPoint {
		id: acActiveInput

		source: veBusDevice.serviceUid + "/Ac/ActiveIn/ActiveInput"
	}

	//% "Active AC Input"
	text: qsTrId("vebus_device_active_ac_input")
	secondaryText: {
		switch(acActiveInput.value) {
		case 0:
		case 1:
			//% "AC in %1"
			return qsTrId("vebus_device_page_ac_in").arg(acActiveInput.value + 1)
		default:
			return CommonWords.disconnected
		}
	}
}
