/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Units

Page {
	id: root

	property string bindPrefix

	DataPoint {
		id: sustainDataPoint

		source: root.bindPrefix + "/Hub4/Sustain"
	}

	DataPoint {
		id: lowSocDataPoint

		source: root.bindPrefix + "/Hub4/LowSoc"
	}

	DataPoint {
		id: maxChargePower

		source: "com.victronenergy.hub4/MaxChargePower"
	}

	DataPoint {
		id: maxDischargePower

		source: "com.victronenergy.hub4/MaxDischargePower"
	}

	GradientListView {
		model: ObjectModel {

			ListNavigationItem {
				text: CommonWords.ac_sensors
				onClicked: Global.pageManager.pushPage("/pages/vebusdevice/PageAcSensors.qml", {
														   "title": text,
														   "bindPrefix": root.bindPrefix + "/AcSensor"
													   }
													   )
			}

			ListNavigationItem {
				text: "kWh Counters"
				onClicked: Global.pageManager.pushPage("/pages/vebusdevice/PageVeBusKwhCounters.qml", {
														   "title": text,
														   "bindPrefix": root.bindPrefix + "/Energy",
														   "service": root.bindPrefix
													   }
													   )
			}

			ListTextItem {
				text: "Multi SOC"
				dataSource: root.bindPrefix + "/Soc"
			}

			ListTextGroup {
				text: "Flags"
				textModel: [
					"Sustain: " + Units.getDisplayText(VenusOS.Units_None, sustainDataPoint.value).number,
					"Low SOC: " + Units.getDisplayText(VenusOS.Units_None, lowSocDataPoint.value).number
				]
			}

			ListQuantityGroup {
				text: "AC power setpoint"
				minimumDelegateWidth: 80
				textModel: [
					{ value: remoteSetpointL1.value, unit: VenusOS.Units_Watt },
					{ value: remoteSetpointL2.value, unit: VenusOS.Units_Watt },
					{ value: remoteSetpointL3.value, unit: VenusOS.Units_Watt }
				]
			}

			ListTextGroup {
				text: "Limits"
				textModel: [
					"Charge: " + Units.getDisplayText(VenusOS.Units_None, maxChargePower.value).number,
					"Discharge: " + Units.getDisplayText(VenusOS.Units_None, maxDischargePower.value).number
				]
			}

			ListSwitch {
				id: doSend

				text: "Send setpoints"
				Timer {
					id: hub4Control

					property bool toggle

					interval: 1000
					repeat: true
					running: doSend.checked

					onTriggered: {
						toggle = !toggle
						let noise = (toggle ? 0 : 1)

						// FIXME: only do this if the paths are valid (but that is unknown yet)
						remoteSetpointL1.setValue(sliderL1.slider.value + noise)
						remoteSetpointL2.setValue(sliderL2.slider.value + noise)
						remoteSetpointL3.setValue(sliderL3.slider.value + noise)
					}
				}

				DataPoint {
					id: remoteSetpointL1

					source: root.bindPrefix + "/Hub4/L1/AcPowerSetpoint"
				}

				DataPoint {
					id: remoteSetpointL2

					source: root.bindPrefix + "/Hub4/L2/AcPowerSetpoint"
				}

				DataPoint {
					id: remoteSetpointL3

					source: root.bindPrefix + "/Hub4/L3/AcPowerSetpoint"
				}
			}

			ListSlider {
				id: sliderL1
				slider.from: -5000
				slider.to: 5000
				slider.stepSize: 50
			}

			ListSlider {
				id: sliderL2
				slider.from: -5000
				slider.to: 5000
				slider.stepSize: 50
			}

			ListSlider {
				id: sliderL3
				slider.from: -5000
				slider.to: 5000
				slider.stepSize: 50
			}

			ListSwitch {
				text: "Disable Charge"
				dataSource: root.bindPrefix + "/Hub4/DisableCharge"
			}

			ListSwitch {
				text: "Disable Feed In"
				dataSource: root.bindPrefix + "/Hub4/DisableFeedIn"
			}
		}
	}
}

