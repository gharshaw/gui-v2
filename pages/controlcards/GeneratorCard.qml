/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import "/components/Utils.js" as Utils

ControlCard {
	id: root

	property var generator

	title.icon.source: "qrc:/images/generator.svg"
	//% "Generator"
	title.text: qsTrId("controlcard_generator")

	status.text: {
		switch (state) {
		case VenusOS.Generators_State_Running:
			//% "Running"
			return qsTrId("controlcard_generator_status_running")
		case VenusOS.Generators_State_Error:
			//% "ERROR"
			return qsTrId("controlcard_generator_status_error")
		default:
			//% "Stopped"
			return qsTrId("controlcard_generator_status_stopped")
		}
	}

	GeneratorIconLabel {
		id: timerDisplay
		anchors {
			right: parent.right
			rightMargin: Theme.geometry.controlCard.contentMargins
			top: parent.status.top
			topMargin: parent.status.topMargin
			bottom: parent.status.bottom
			bottomMargin: parent.status.bottomMargin
		}
		generator: root.generator
	}

	Label {
		id: substatus
		anchors {
			top: timerDisplay.bottom
			left: parent.left
			leftMargin: Theme.geometry.controlCard.contentMargins
		}

		color: root.generator.state === VenusOS.Generators_State_Error ? Theme.color.critical
			: Theme.color.font.secondary
		text: root.generator.state !== VenusOS.Generators_State_Running ?
				"" // not running, empty substatus.
			: root.generator.runningBy === VenusOS.Generators_RunningBy_Manual ?
				//% "Manual started"
				qsTrId("controlcard_generator_substatus_manualstarted")
			: root.generator.runningBy === VenusOS.Generators_RunningBy_TestRun ?
				//% "Test run"
				qsTrId("controlcard_generator_substatus_testrun")
			: ( //% "Auto-started"
				qsTrId("controlcard_generator_substatus_autostarted")
				+ " \u2022 " + substatusForRunningBy(root.generator.runningBy))

		function substatusForRunningBy(runningBy) {
			switch (root.generator.runningBy) {
			case VenusOS.Generators_RunningBy_LossOfCommunication:
				//% "Loss of comm"
				return qsTrId("controlcard_generator_substatus_lossofcomm")
			case VenusOS.Generators_RunningBy_Soc:
				//% "State of charge"
				return qsTrId("controlcard_generator_substatus_stateofcharge")
			case VenusOS.Generators_RunningBy_Acload:
				return CommonWords.ac_load
			case VenusOS.Generators_RunningBy_BatteryCurrent:
				return CommonWords.battery_current
			case VenusOS.Generators_RunningBy_BatteryVoltage:
				return CommonWords.battery_voltage
			case VenusOS.Generators_RunningBy_InverterHighTemp:
				//% "Inverter high temp"
				return qsTrId("controlcard_generator_substatus_inverterhigh_temp")
			case VenusOS.Generators_RunningBy_InverterOverload:
				return CommonWords.inverter_overload
			default: return "" // unknown substatus.
			}
		}
	}

	SwitchControlValue {
		id: autostartSwitch

		property var _confirmationDialog

		anchors.top: substatus.bottom

		//% "Auto-start"
		label.text: qsTrId("controlcard_generator_label_autostart")
		button.checked: root.generator.autoStart
		button.checkable: false     // user might not be allowed to change this setting
		separator.visible: false

		// TODO should also disable if user is not allowed to change autostart property
		enabled: root.generator.state !== VenusOS.Generators_State_Running

		onClicked: {
			if (root.generator.autoStart) {
				// check if they really want to disable
				if (!_confirmationDialog) {
					_confirmationDialog = confirmationDialogComponent.createObject(Global.dialogLayer)
				}
				_confirmationDialog.open()
			} else {
				root.generator.setAutoStart(false)
			}
		}

		Component {
			id: confirmationDialogComponent

			ModalWarningDialog {
				dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel

				//% "Disable auto-start?"
				title: qsTrId("controlcard_generator_disableautostartdialog_title")

				onAccepted: root.generator.setAutoStart(true)
			}
		}
	}

	Item {
		id: subcard
		anchors {
			left: parent.left
			leftMargin: Theme.geometry.controlCard.subCard.margins
			right: parent.right
			rightMargin: Theme.geometry.controlCard.subCard.margins
			top: autostartSwitch.bottom
			topMargin: Theme.geometry.controlCard.subCard.margins
			bottom: parent.bottom
			bottomMargin: Theme.geometry.controlCard.subCard.margins
		}

		Rectangle {
			id: subcardBgRect
			anchors.fill: parent
			color: Theme.color.card.panel.background
			radius: Theme.geometry.panel.radius
		}

		Label {
			id: subcardHeader
			anchors {
				left: parent.left
				leftMargin: Theme.geometry.controlCard.contentMargins
				right: parent.right
				rightMargin: Theme.geometry.controlCard.contentMargins
			}

			height: Theme.geometry.controlCard.subCard.header.height
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignLeft
			font.pixelSize: Theme.font.size.caption
			//% "Manual control"
			text: qsTrId("controlcard_generator_subcard_header_manualcontrol")
			color: Theme.color.font.secondary
		}
		SeparatorBar {
			id: subcardHeaderSeparator
			anchors {
				top: subcardHeader.bottom
				left: parent.left
				right: parent.right
			}
		}
		SwitchControlValue {
			id: timedRunSwitch

			anchors.top: subcardHeaderSeparator.bottom
			//% "Timed run"
			label.text: qsTrId("controlcard_generator_subcard_label_timedrun")
			enabled: root.generator.state !== VenusOS.Generators_State_Running
		}
		ButtonControlValue {
			id: durationButton

			property int duration: root.generator.manualStartTimer
			property var _durationDialog

			anchors.top: timedRunSwitch.bottom
			//% "Duration"
			label.text: qsTrId("controlcard_generator_subcard_label_duration")

			button.height: Theme.geometry.generatorCard.durationButton.height
			button.width: Theme.geometry.generatorCard.durationButton.width
			button.enabled: timedRunSwitch.button.checked
					&& root.generator.state !== VenusOS.Generators_State_Running
			button.text: Utils.formatAsHHMM(durationButton.duration)

			onClicked: {
				if (!_durationDialog) {
					_durationDialog = durationSelectorComponent.createObject(Global.dialogLayer)
				}
				_durationDialog.duration = duration
				_durationDialog.open()
			}

			Component {
				id: durationSelectorComponent

				GeneratorDurationSelectorDialog {
					onAccepted: durationButton.duration = duration
				}
			}
		}
		ActionButton {
			id: startButton
			anchors {
				margins: Theme.geometry.controlCard.contentMargins
				bottom: parent.bottom
				left: parent.left
				right: parent.right
			}
			height: Theme.geometry.generatorCard.startButton.height

			enabled: root.generator.state !== VenusOS.Generators_State_Error

			text: root.generator.state === VenusOS.Generators_State_Running ?
					//% "Stop"
					qsTrId("controlcard_generator_subcard_button_stop")
				: /* stopped */
					//% "Start"
					qsTrId("controlcard_generator_subcard_button_start")

			checked: root.generator.state === VenusOS.Generators_State_Running

			onClicked: {
				if (root.generator.state === VenusOS.Generators_State_Running) {
					Global.generators.manualRunningNotification(false)
					root.generator.stop()
					durationButton.duration = 0
				} else {
					Global.generators.manualRunningNotification(true, durationButton.duration)
					root.generator.start(durationButton.duration)
				}
			}
		}
	}
}