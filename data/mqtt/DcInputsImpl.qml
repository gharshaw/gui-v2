/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib
import "/components/Utils.js" as Utils

QtObject {
	id: root

	property var veServiceIds
	onVeServiceIdsChanged: Qt.callLater(_getInputs)

	property var _monitorModes: ({
		"-1": VenusOS.DcInputs_InputType_DcGenerator,
		// -2 AC charger
		// -3 DC charger
		// -4 Water generator
		// -7 Shaft generator
		// -8 Wind charger
		"-8": VenusOS.DcInputs_InputType_Wind,
	})

	property var _inputs: []

	function _getInputs() {
		let inputIds = []
		for (let i = 0; i < veServiceIds.length; ++i) {
			let id = veServiceIds[i]
			if (id.startsWith("alternator")
					|| id.startsWith("fuelcell")
					|| id.startsWith("dcsource")) {
				inputIds.push(id)
			}
		}

		if (Utils.arrayCompare(_inputs, inputIds) !== 0) {
			_inputs = inputIds
		}
	}

	property Instantiator inputObjects: Instantiator {
		model: _inputs || null

		delegate: QtObject {
			id: input

			property string uid: modelData
			property string serviceUid: "mqtt/" + modelData

			property int source: {
				if (uid.startsWith("alternator")) {
					return VenusOS.DcInputs_InputType_Alternator
				} else if (uid.startsWith("fuelcell")) {
					return VenusOS.DcInputs_InputType_FuelCell
				} if (uid.startsWith("dcsource")) {
					// Use DC Generator as the catch-all type for any DC power source that isn't
					// specifically handled.
					return root._monitorModes[monitorMode.toString()] || VenusOS.DcInputs_InputType_DcGenerator
				}
			}

			property real voltage: NaN
			property real current: NaN
			property real power: isNaN(voltage) || isNaN(current) ? NaN : voltage * current
			property real temperature_celsius: NaN
			property int monitorMode

			Component.onCompleted: {
				Global.dcInputs.addInput(input)
			}
			Component.onDestruction: {
				const index = Utils.findIndex(Global.dcInputs.model, input)
				if (index >= 0) {
					Global.dcInputs.removeInput(index)
				}
			}

			property var _voltage: VeQuickItem {
				uid: input.serviceUid + "/Dc/0/Voltage"
				onValueChanged: {
					input.voltage = value === undefined ? NaN : value
					Qt.callLater(Global.dcInputs.updateTotals)
				}
			}

			property var _current: VeQuickItem {
				uid: input.serviceUid + "/Dc/0/Current"
				onValueChanged: {
					input.current = value === undefined ? NaN : value
					Qt.callLater(Global.dcInputs.updateTotals)
				}
			}

			property var _temperature: VeQuickItem {
				uid: input.serviceUid + "/Dc/0/Temperature"
				onValueChanged: input.temperature_celsius = value === undefined ? NaN : value
			}

			property var _monitorMode: VeQuickItem {
				uid: input.serviceUid + "/Settings/MonitorMode"
				onValueChanged: input.monitorMode = value === undefined ? NaN : value
			}
		}
	}
}