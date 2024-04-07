/*
 *   Copyright 2018 Marian Arlt <marianarlt@icloud.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 3 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtGraphicalEffects 1.0
import QtQuick 2.2

FocusScope {
    id: backgroundComponent

    property alias imageSource: backgroundImage.source
    property bool isBlurActive: config.blur == "true"

    Image {
        id: backgroundImage

        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        clip: true
        focus: true
        smooth: true
    }
    
    RadialGradient {
        id: mask
        anchors.fill: backgroundImage
        gradient: Gradient {
            GradientStop {
                position: 0.2
                color: "#ffffffff"
            }

            GradientStop {
                position: 1
                color: "#00ffffff"
            }
        }
        horizontalOffset: 0
        verticalOffset: 0
        horizontalRadius: parent.height
        verticalRadius: parent.height
    }

    MaskedBlur {
        id: backgroundBlur

        anchors.fill: backgroundImage
        source: backgroundImage
        maskSource: mask
        radius: isBlurActive ? config.blurRadius : 0
        samples: isBlurActive ? config.blurSamples : 0
    }

    MouseArea {
        anchors.fill: parent
        onClicked: container.focus = true
    }

}
