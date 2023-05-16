/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Rectangle {
	id: root

	property int type: VenusOS.OverviewWidget_Type_UnknownType
	property int size: VenusOS.OverviewWidget_Size_M

	property alias icon: widgetHeader.icon
	property alias title: widgetHeader.title
	property alias quantityLabel: quantityLabel

	property int rightPadding
	property alias extraContent: extraContent
	property var connectors: []

	property real compactY
	property real expandedY
	readonly property int compactHeight: getCompactHeight(size)
	readonly property int expandedHeight: getExpandedHeight(size)
	property real segmentCompactMargin
	property real segmentExpandedMargin
	property bool expanded
	property bool animateGeometry
	property bool animationEnabled

	function getCompactHeight(s) {
		return s === VenusOS.OverviewWidget_Size_XL
		  ? Theme.geometry.overviewPage.widget.compact.xl.height
		  : s === VenusOS.OverviewWidget_Size_L
			? Theme.geometry.overviewPage.widget.compact.l.height
			: s === VenusOS.OverviewWidget_Size_M
			  ? Theme.geometry.overviewPage.widget.compact.m.height
			  : s === VenusOS.OverviewWidget_Size_S
			  ? Theme.geometry.overviewPage.widget.compact.s.height
			  : Theme.geometry.overviewPage.widget.compact.xs.height
	}

	function getExpandedHeight(s) {
		return s === VenusOS.OverviewWidget_Size_XL
			? Theme.geometry.overviewPage.widget.expanded.xl.height
			: s === VenusOS.OverviewWidget_Size_L
			  ? Theme.geometry.overviewPage.widget.expanded.l.height
			  : s === VenusOS.OverviewWidget_Size_M
				? Theme.geometry.overviewPage.widget.expanded.m.height
				: s === VenusOS.OverviewWidget_Size_S
				? Theme.geometry.overviewPage.widget.expanded.s.height
				: Theme.geometry.overviewPage.widget.expanded.xs.height
	}

	y: compactY
	height: compactHeight
	visible: size !== VenusOS.OverviewWidget_Size_Zero
	radius: Theme.geometry.overviewPage.widget.radius
	color: Theme.color.overviewPage.widget.background

	states: State {
		name: "expanded"
		when: root.expanded

		PropertyChanges { target: root; y: root.expandedY; height: root.expandedHeight }
	}

	transitions: Transition {
		enabled: root.animateGeometry

		NumberAnimation {
			properties: "y,height"
			duration: Theme.animation.page.idleResize.duration
			easing.type: Easing.InOutQuad
		}
	}

	Item {
		id: header

		x: Theme.geometry.overviewPage.widget.content.horizontalMargin
		y: root.size > VenusOS.OverviewWidget_Size_S
		   ? Theme.geometry.overviewPage.widget.content.verticalMargin
		   : parent.height/2 - height/2
		width: parent.width - 2*Theme.geometry.overviewPage.widget.content.horizontalMargin
		height: widgetHeader.height + (quantityLabel.visible ? quantityLabel.height : 0)

		WidgetHeader {
			id: widgetHeader

			width: parent.width
		}

		ElectricalQuantityLabel {
			id: quantityLabel

			anchors {
				top: widgetHeader.bottom
				topMargin: Theme.geometry.overviewPage.widget.header.spacing
			}
			font.pixelSize: root.size === VenusOS.OverviewWidget_Size_XS
					  ? Theme.font.overviewPage.widget.quantityLabel.minimumSize
					  : Theme.font.overviewPage.widget.quantityLabel.maximumSize
		}
	}

	Item {
		id: extraContent
		anchors {
			left: parent.left
			right: parent.right
			rightMargin: root.rightPadding
			top: header.bottom
			bottom: parent.bottom
		}
		visible: root.size >= VenusOS.OverviewWidget_Size_M
	}
}
