/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Slider {
	id: root

	property alias source: dataPoint.source
	property alias dataPoint: dataPoint

	property real _emittedValue

	signal valueChanged(value: real)

	implicitWidth: parent ? parent.width : 0
	implicitHeight: Theme.geometry.settingsListItem.height
	live: false
	from: dataPoint.min !== undefined ? dataPoint.min : 0
	to: dataPoint.max !== undefined ? dataPoint.max : 1
	stepSize: (to-from) / Theme.geometry.settingsListItem.slider.stepDivsion
	value: to > from && dataPoint.valid ? dataPoint.value : 0
	enabled: source === "" || dataPoint.valid

	onPressedChanged: {
		if (root.value !== root._emittedValue) {
			root._emittedValue = root.value
			root.valueChanged(root.value)
		}
	}

	onValueChanged: function(value) {
		if (source.length > 0) {
			dataPoint.setValue(value)
		}
	}

	leftPadding: Theme.geometry.settingsListItem.content.horizontalMargin
		+ Theme.geometry.settingsListItem.slider.button.size
		+ Theme.geometry.settingsListItem.slider.spacing
	rightPadding: Theme.geometry.settingsListItem.content.horizontalMargin
		+ Theme.geometry.settingsListItem.slider.button.size
		+ Theme.geometry.settingsListItem.slider.spacing

	Button {
		id: minusButton
		anchors {
			verticalCenter: parent.verticalCenter
			left: parent.left
			leftMargin: Theme.geometry.settingsListItem.content.horizontalMargin
		}
		icon.width: Theme.geometry.settingsListItem.slider.button.size
		icon.height: Theme.geometry.settingsListItem.slider.button.size
		icon.source: "/images/icon_minus.svg"

		onClicked: {
			if (root.value > root.from) {
				root.decrease()
				root._emittedValue = root.value
				root.valueChanged(root.value)
			}
		}
	}

	Button {
		anchors {
			verticalCenter: parent.verticalCenter
			right: parent.right
			rightMargin: Theme.geometry.settingsListItem.content.horizontalMargin
		}
		icon.width: Theme.geometry.settingsListItem.slider.button.size
		icon.height: Theme.geometry.settingsListItem.slider.button.size
		icon.source: "/images/icon_plus.svg"

		onClicked: {
			if (root.value < root.to) {
				root.increase()
				root._emittedValue = root.value
				root.valueChanged(root.value)
			}
		}
	}

	DataPoint {
		id: dataPoint

		hasMin: true
		hasMax: true
	}
}
