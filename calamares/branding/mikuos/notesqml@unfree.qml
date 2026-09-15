import io.calamares.core

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Page {
    ColumnLayout {
        width: parent.width
        spacing: Kirigami.Units.smallSpacing

        Column {
            Layout.fillWidth: true

            Text {
                text: qsTr("MiKuOS is built on the Nix package system. Some software does not fully respect users' freedom to run, copy, distribute, study, change and improve the software, and is commonly not open source. By default such \"unfree\" packages are not allowed, but you can enable them here. If you check this box, you accept that proprietary software may be installed — some hardware (notably Nvidia GPUs and some WiFi chips) might otherwise not work or not work optimally.<br/>")
                width: parent.width
                wrapMode: Text.WordWrap
            }

            CheckBox {
                text: qsTr("Allow unfree software")

                onCheckedChanged: {
                    Global.insert("nixos_allow_unfree", checked)
                }
            }
        }
    }
}