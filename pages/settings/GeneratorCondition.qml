/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

ListNavigationItem {
	id: root

	property string bindPrefix
	property string unit: ""
	property string timeUnit: "s"
	property int decimals: 1
	property bool startValueIsGreater: true
	property string name: text

	//% "Use %1 value to start/stop"
	property string enableDescription: qsTrId("generator_condition_use_value_to_start_stop").arg(name)

	//% "Start when %1 is higher than"
	readonly property string startValueDescriptionHigher: qsTrId("generator_condition_start_when_property_is_higher_than").arg(root.name)

	//% "Start when %1 is lower than"
	readonly property string startValueDescriptionLower: qsTrId("generator_condition_start_when_property_is_lower_than").arg(root.name)
	readonly property string startValueDescription: startValueIsGreater ? startValueDescriptionHigher : startValueDescriptionLower
	property string startTimeDescription: CommonWords.start_after_the_condition_is_reached_for

	//% "Stop when %1 is higher than"
	readonly property string stopValueDescriptionHigher: qsTrId("generator_condition_stop_when_property_is_higher_than").arg(root.name)

	//% "Stop when %1 is lower than"
	readonly property string stopValueDescriptionLower: qsTrId("generator_condition_stop_when_property_is_lower_than").arg(root.name)
	readonly property string stopValueDescription: !startValueIsGreater ? stopValueDescriptionHigher : stopValueDescriptionLower
	property string stopTimeDescription: CommonWords.stop_after_the_condition_is_reached_for
	readonly property alias value: dataPoint.value

	// Autocalculate step size based on number of decimals
	readonly property real stepSize: Math.pow(10, -decimals)

	secondaryText: dataPoint.value === 1 ? CommonWords.enabled : CommonWords.disabled
	onClicked: Global.pageManager.pushPage(subpage)

	DataPoint {
		id: dataPoint

		source: bindPrefix + "/Enabled"
	}

	Component {
		id: subpage

		Page {
			title: root.text

			GradientListView {

				model: ObjectModel {

					ListSwitch {
						text: root.enableDescription
						source: bindPrefix + "/Enabled"
					}

					ListSpinBox {
						id: startValue

						text: startValueDescription
						visible: valid
						source: bindPrefix + "/StartValue"
						suffix: root.unit
						decimals: root.decimals
						from: stopValue.valid && root.startValueIsGreater ? stopValue.value + stepSize : 0
						to: stopValue.valid && !root.startValueIsGreater ? stopValue.value - stepSize : 100
					}

					ListSpinBox {
						id: quietHoursStartValue

						text: CommonWords.start_value_during_quiet_hours
						visible: valid
						source: bindPrefix + "/QuietHoursStartValue"
						suffix: root.unit
						decimals: root.decimals
						from: quietHoursStopValue.valid && root.startValueIsGreater ? quietHoursStopValue.value + stepSize : 0
						to: quietHoursStopValue.valid && !root.startValueIsGreater ? quietHoursStopValue.value - stepSize : 100
					}

					ListSpinBox {
						id: startTime

						text: startTimeDescription
						visible: valid
						source: bindPrefix + "/StartTimer"
						suffix: root.timeUnit
					}

					ListSpinBox {
						id: stopValue

						text: stopValueDescription
						visible: valid
						source: bindPrefix + "/StopValue"
						suffix: root.unit
						decimals: root.decimals
						to: startValue.valid && root.startValueIsGreater ? startValue.value - stepSize : 100
						from: startValue.valid && !root.startValueIsGreater ? startValue.value + stepSize : 0
					}

					ListSpinBox {
						id: quietHoursStopValue

						text: CommonWords.stop_value_during_quiet_hours
						visible: valid
						source: bindPrefix + "/QuietHoursStopValue"
						suffix: root.unit
						decimals: root.decimals
						to: quietHoursStartValue.valid && root.startValueIsGreater ? quietHoursStartValue.value - stepSize : 100
						from: quietHoursStartValue.valid && !root.startValueIsGreater ? quietHoursStartValue.value + stepSize : 1
					}

					ListSpinBox {
						id: stopTime

						text: stopTimeDescription
						visible: valid
						source: bindPrefix + "/StopTimer"
						suffix: root.timeUnit
					}
				}
			}
		}
	}
}
