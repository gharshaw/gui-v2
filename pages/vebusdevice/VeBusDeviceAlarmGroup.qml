/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQml

Item {
	property string bindPrefix
	property string alarmSuffix
	property bool errorItem: false
	property var alarms: [alarm, phase1Alarm, phase2Alarm, phase3Alarm]
	property int numOfPhases: 1

	property DataPoint alarm: DataPoint {
		property string displayText: getDisplayText(value)
		source: bindPrefix + "/Alarms" + alarmSuffix
	}

	property DataPoint phase1Alarm: DataPoint {
		property string displayText: (numOfPhases === 1 ? "" : "L1: ") + getDisplayText(value)
		source: bindPrefix + "/Alarms/L1" + alarmSuffix
	}

	property DataPoint phase2Alarm: DataPoint {
		property string displayText: "L2: " + getDisplayText(value)
		source: bindPrefix + "/Alarms/L2" + alarmSuffix
	}

	property DataPoint phase3Alarm: DataPoint {
		property string displayText: "L3: " + getDisplayText(value)
		source: bindPrefix + "/Alarms/L3" + alarmSuffix
	}

	function getDisplayText(value)
	{
		switch(value) {
		case 0:
			return CommonWords.ok
		case 1:
			//% "Warning"
			return qsTrId("vebus_device_alarm_group_warning")
		case 2:
			return errorItem ? CommonWords.error : CommonWords.alarm
		default:
			return "--"
		}
	}
}
