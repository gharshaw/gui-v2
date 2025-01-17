/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property alias pvCharger: _pvCharger
	property alias pvOnAcIn1: _pvOnAcIn1
	property alias pvOnAcIn2: _pvOnAcIn2
	property alias pvOnAcOut: _pvOnAcOut
	property alias vebusAcOut: _vebusAcOut
	property alias acLoad: _acLoad

	QtObject {
		id: _pvCharger
		property DataPoint power: DataPoint { source: "com.victronenergy.system/Dc/Pv/Power" }
	}

	ObjectAcConnection {
		id: _pvOnAcOut
		bindPrefix: "com.victronenergy.system/Ac/PvOnOutput"
	}

	ObjectAcConnection {
		id: _pvOnAcIn1
		bindPrefix: "com.victronenergy.system/Ac/PvOnGenset"
	}

	ObjectAcConnection {
		id: _pvOnAcIn2
		bindPrefix: "com.victronenergy.system/Ac/PvOnGrid"
	}

	ObjectAcConnection {
		id: _vebusAcOut
		bindPrefix: Global.system.veBus.serviceUid ? Global.system.veBus.serviceUid + "/Ac/Out" : ""
		powerKey: "P"
	}

	/*
	 * Single Multis that can be split-phase reports NrOfPhases of 2
	 * When L2 is disconnected from the input the output L1 and L2
	 * are shorted. This item indicates if L2 is passed through
	 * from AC-in to AC-out.
	 * 1: L2 is being passed through from AC-in to AC-out.
	 * 0: L1 and L2 are shorted together.
	 * invalid: The unit is configured in such way that its L2 output is not used.
	 */

	DataPoint {
		id: _splitPhaseL2Passthru
		source: Global.system.veBus.serviceUid ? Global.system.veBus.serviceUid + "/Ac/State/SplitPhaseL2Passthru" : ""
	}

	ObjectAcConnection {
		id: _acLoad
		splitPhaseL2PassthruDisabled: _splitPhaseL2Passthru.value === 0
		isAcOutput: true
		bindPrefix: "com.victronenergy.system/Ac/Consumption"
	}
}
