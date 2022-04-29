/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property string source
	property var sourceObject
	property int sourceType: dbusConnected && Global.demoManager == null
			? VenusOS.DataPoint_DBusSource
			: VenusOS.DataPoint_MockSource

	property var value: sourceObject ? sourceObject.value : undefined
	property var min: sourceObject ? sourceObject.min : undefined
	property var max: sourceObject ? sourceObject.max : undefined

	property var _dbusImpl

	function setValue(v) {
		if (sourceObject) {
			sourceObject.setValue(v)
		} else {
			console.warn("Set value() failed, no sourceObject for source", source)
		}
	}

	function _dbusImplStatusChanged() {
		if (!_dbusImpl) {
			return
		}
		if (_dbusImpl.status === Component.Error) {
			console.warn("Unable to load DataPointDBusImpl.qml", _dbusImpl.errorString())
		} else if (_dbusImpl.status === Component.Ready) {
			_createImpl()
		}
	}

	function _createImpl() {
		if (!_dbusImpl || _dbusImpl.status !== Component.Ready) {
			console.warn("Cannot create object from component", _dbusImpl ? _dbusImpl.url : "")
			return
		}
		if (sourceObject) {
			sourceObject.destroy()
			sourceObject = null
		}
		sourceObject = _dbusImpl.createObject(root, { uid: "dbus/" + root.source })
		if (!sourceObject) {
			console.warn("Failed to create object from DataPointDBusImpl.qml", _dbusImpl.errorString())
			return
		}
	}

	function _reset() {
		if (source.length === 0) {
			return
		}
		switch (sourceType) {
		case VenusOS.DataPoint_DBusSource:
			if (!_dbusImpl) {
				_dbusImpl = Qt.createComponent(Qt.resolvedUrl("DataPointDBusImpl.qml"),
						Component.Asynchronous)
				_dbusImpl.statusChanged.connect(_dbusImplStatusChanged)
			} else if (_dbusImpl.status === Component.Ready) {
				_createImpl()
			}

			break
		case VenusOS.DataPoint_MockSource:
			break
		default:
			console.warn("Unknown DataPoint source type:", sourceType)
			break
		}
	}

	onSourceTypeChanged: _reset()
	Component.onCompleted: _reset()
	Component.onDestruction: {
		if (_dbusImpl) {
			// Precaution for if asynchronous component creation finishes after object destruction.
			_dbusImpl.statusChanged.disconnect(_dbusImplStatusChanged)
			_dbusImpl = null
		}
	}
}