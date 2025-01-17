/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Utils

Rectangle {
	id: root

	property real minBatteryVoltage
	property real maxBatteryVoltage
	property real maxBatteryCurrent

	property real timeInBulk
	property real timeInAbsorption
	property real timeInFloat

	property bool smallTextMode

	function _formatTime(minutes) {
		if (isNaN(minutes)) {
			return "--"
		} else {
			return Math.floor(minutes / 60) + ":" + Utils.pad(minutes % 60, 2)
		}
	}

	width: parent.width
	height: batteryColumn.height + (2 * Theme.geometry.solarDetailBox.content.spacing)
	border.color: Theme.color.solarDetailBox.border
	color: "transparent"
	radius: Theme.geometry.solarDetailBox.radius

	Column {
		id: batteryColumn

		anchors.verticalCenter: parent.verticalCenter
		x: Theme.geometry.listItem.content.horizontalMargin - Theme.geometry.solarDetailBox.horizontalMargin
		width: parent.width * Theme.geometry.solarDetailBox.leftColumn.proportionateWidth
		spacing: Theme.geometry.solarDetailBox.content.spacing

		Label {
			text: CommonWords.battery
			width: parent.width
			font.pixelSize: Theme.font.size.caption
			color: Theme.color.solarDetailBox.columnTitle
		}

		Row {
			width: parent.width

			Repeater {
				model: [
					{
						//% "Min Voltage"
						"title": qsTrId("charger_history_box_min_voltage"),
						"value": root.minBatteryVoltage,
						"unit": VenusOS.Units_Volt
					},
					{
						//% "Max Voltage"
						"title": qsTrId("charger_history_box_max_voltage"),
						"value": root.maxBatteryVoltage,
						"unit": VenusOS.Units_Volt
					},
					{
						//% "Max Current"
						"title": qsTrId("charger_history_box_max_current"),
						"value": root.maxBatteryCurrent,
						"unit": VenusOS.Units_Amp
					},
				]
				delegate: Column {
					width: parent.width / 3

					Label {
						width: parent.width - Theme.geometry.solarDetailBox.content.spacing
						elide: Text.ElideRight
						font.pixelSize: Theme.font.size.caption
						text: modelData.title
						color: Theme.color.solarDetailBox.quantityTitle
					}

					QuantityLabel {
						value: modelData.value
						unit: modelData.unit
						font.pixelSize: root.smallTextMode ? Theme.font.size.body1 : Theme.font.size.body2
					}
				}
			}
		}
	}

	Rectangle {
		anchors {
			left: batteryColumn.right
			top: parent.top
			topMargin: Theme.geometry.solarDetailBox.content.spacing
			bottom: parent.bottom
			bottomMargin: Theme.geometry.solarDetailBox.content.spacing
		}
		width: root.border.width
		height: parent.height
		color: Theme.color.solarDetailBox.border
	}

	Column {
		anchors {
			verticalCenter: parent.verticalCenter
			left: batteryColumn.right
			leftMargin: Theme.geometry.solarDetailBox.content.spacing
			right: parent.right
		}
		spacing: Theme.geometry.solarDetailBox.content.spacing

		Label {
			//: Statistics for battery charging time
			//% "Charge time"
			text: qsTrId("charger_history_charge_time")
			width: parent.width
			elide: Text.ElideRight
			font.pixelSize: Theme.font.size.caption
			color: Theme.color.solarDetailBox.columnTitle
		}

		Row {
			width: parent.width

			Repeater {
				model: [
					{
						//: Battery: time spent in 'Bulk' mode
						//% "Bulk"
						"title": qsTrId("charger_history_box_bulk"),
						"text": root._formatTime(root.timeInBulk)
					},
					{
						//: Battery: time spent in 'Absorption' mode
						//% "Abs"
						"title": qsTrId("charger_history_box_abs"),
						"text": root._formatTime(root.timeInAbsorption)
					},
					{
						//: Battery: time spent in 'Float' mode
						//% "Float"
						"title": qsTrId("charger_history_box_float"),
						"text": root._formatTime(root.timeInFloat)
					},
				]
				delegate: Column {
					width: parent.width / 3

					Label {
						width: parent.width - Theme.geometry.solarDetailBox.content.spacing
						elide: Text.ElideRight
						font.pixelSize: Theme.font.size.caption
						text: modelData.title
						color: Theme.color.solarDetailBox.quantityTitle
					}

					Label {
						width: implicitWidth + hourLabel.implicitWidth
						text: modelData.text
						font.pixelSize: root.smallTextMode ? Theme.font.size.body1 : Theme.font.size.body2

						Label {
							id: hourLabel

							x: parent.implicitWidth + Theme.geometry.quantityLabel.spacing
							//: Abbreviation of "hour"
							//% "hr"
							text: qsTrId("charger_history_hr")
							font.pixelSize: root.smallTextMode ? Theme.font.size.body1 : Theme.font.size.body2
							color: Theme.color.font.secondary
						}
					}
				}
			}
		}
	}
}
