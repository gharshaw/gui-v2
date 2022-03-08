/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Rectangle {
	id: root

	enum Size {
		Zero, // i.e. not visible
		XS,
		S,
		M,
		L,
		XL
	}

	property int size: OverviewWidget.Size.M

	property bool overviewPageInteractive: true
	property alias interactive: mouseArea.enabled

	property alias physicalQuantity: valueDisplay.physicalQuantity
	property alias value: valueDisplay.value
	property alias precision: valueDisplay.precision
	property alias icon: valueDisplay.icon
	property alias title: valueDisplay.title

	property alias sideGaugeVisible: sideGauge.visible
	property alias sideGaugeValue: sideGauge.value

	property alias extraContent: extraContent

	property bool isSegment

	signal clicked()

	height: size === OverviewWidget.Size.XL ? overviewPageInteractive
			? Theme.geometry.overviewPage.widget.interactive.xl.height
			: Theme.geometry.overviewPage.widget.noninteractive.xl.height
		  : size === OverviewWidget.Size.L ? overviewPageInteractive
			? Theme.geometry.overviewPage.widget.interactive.l.height
			: Theme.geometry.overviewPage.widget.noninteractive.l.height
		  : size === OverviewWidget.Size.M ? overviewPageInteractive
			? Theme.geometry.overviewPage.widget.interactive.m.height
			: Theme.geometry.overviewPage.widget.noninteractive.m.height
		  : size === OverviewWidget.Size.S ? overviewPageInteractive
			? Theme.geometry.overviewPage.widget.interactive.s.height
			: Theme.geometry.overviewPage.widget.noninteractive.s.height
		  : /* OverviewWidget.Size.XS */ overviewPageInteractive
			? Theme.geometry.overviewPage.widget.interactive.xs.height
			: Theme.geometry.overviewPage.widget.noninteractive.xs.height

	visible: size !== OverviewWidget.Size.Zero
	radius: isSegment ? 0 : Theme.geometry.overviewPage.widget.radius
	border.width: interactive && !isSegment ? Theme.geometry.overviewPage.widget.border.width : 0
	border.color: Theme.color.overviewPage.widget.border
	color: isSegment ? "transparent" : Theme.color.overviewPage.widget.background

	Behavior on height {
		enabled: PageManager.navBarAnimating
		NumberAnimation { duration: Theme.animation.overviewPage.interactive.duration; easing.type: Easing.InOutQuad }
	}

	MouseArea {
		id: mouseArea
		anchors.fill: parent
		enabled: true
		onClicked: root.clicked()
	}

	Rectangle {
		id: sideGauge
		anchors {
			top: parent.top
			bottom: parent.bottom
			right: parent.right
			margins: Theme.geometry.overviewPage.widget.sideGauge.margins
		}

		property real value: 0.0 // 0.0 -> 1.0
		visible: false
		width: Theme.geometry.overviewPage.widget.sideGauge.width
		radius: Theme.geometry.overviewPage.widget.sideGauge.radius
		color: Theme.color.overviewPage.widget.sideGauge.background

		// We could do the highlight more accurately (and it would scale nicer)
		// with a single full-height rounded rectangle inside a clip item.
		// However, that would require adding a clip, which can affect performance.

		Rectangle {
			id: highlightTop
			anchors {
				top: parent.top
				left: parent.left
				right: parent.right
			}

			radius: parent.radius
			height: parent.value === 1.0 ? 2*radius : 0
			color: Theme.color.overviewPage.widget.sideGauge.highlight
		}

		Rectangle {
			id: highlight
			anchors {
				bottom: highlightBottom.verticalCenter
				left: parent.left
				right: parent.right
			}
			height: Math.max(0, (parent.value * parent.height) - 2*parent.radius)
			color: Theme.color.overviewPage.widget.sideGauge.highlight
		}

		Rectangle {
			id: highlightBottom
			anchors {
				bottom: parent.bottom
				left: parent.left
				right: parent.right
			}

			radius: parent.radius
			height: parent.value > 0.0004 ? 2*radius : 0
			color: Theme.color.overviewPage.widget.sideGauge.highlight
		}
	}

	ValueDisplay {
		id: valueDisplay
		anchors {
			top: parent.top
			topMargin: Theme.geometry.overviewPage.widget.content.verticalMargin
			left: parent.left
			leftMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
		}
		fontSize: root.size === OverviewWidget.Size.XS
				  ? Theme.font.size.l
				  : Theme.font.size.xl
	}

	Item {
		id: extraContent
		anchors {
			left: parent.left
			right: sideGauge.visible ? sideGauge.left : parent.right
			rightMargin: sideGauge.visible ? sideGauge.anchors.margins : 0
			top: valueDisplay.bottom
			bottom: parent.bottom
		}
		visible: root.size >= OverviewWidget.Size.M
	}
}