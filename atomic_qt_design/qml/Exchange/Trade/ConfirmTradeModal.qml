import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../../Components"
import "../../Constants"
import ".."

DefaultModal {
    id: root

    width: 1100

    onOpened: reset()

    function reset() {

    }

    // Inside modal
    ColumnLayout {
        id: modal_layout

        width: parent.width

        ModalHeader {
            title: API.get().empty_string + (qsTr("Confirm Exchange Details"))
        }

        OrderContent {
            Layout.topMargin: 25
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: Layout.leftMargin
            height: 120
            Layout.alignment: Qt.AlignHCenter

            details: ({
                    base_coin: getTicker(sell_mode),
                    rel_coin: getTicker(!sell_mode),
                    base_amount: sell_mode ? getCurrentForm().field.text : getCurrentForm().total_amount,
                    rel_amount: sell_mode ? getCurrentForm().total_amount : getCurrentForm().field.text,

                    order_id: '',
                    date: '',
                   })
            in_modal: true
        }

        PriceLine {
            Layout.alignment: Qt.AlignHCenter
        }

        HorizontalLine {
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            Layout.fillWidth: true
        }

        FloatingBackground {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 10

            color: Style.colorTheme5

            width: warning_texts.width + 20
            height: warning_texts.height + 20

            ColumnLayout {
                id: warning_texts
                anchors.centerIn: parent

                DefaultText {
                    Layout.alignment: Qt.AlignHCenter

                    text_value: API.get().empty_string + (qsTr("This swap request can not be undone and is a final event!"))
                }

                DefaultText {
                    Layout.alignment: Qt.AlignHCenter

                    text_value: API.get().empty_string + (qsTr("This transaction can take up to 10 mins - DO NOT close this application!"))
                    font.pixelSize: Style.textSizeSmall4
                }
            }
        }

        ColumnLayout {
            Layout.bottomMargin: 10
            Layout.alignment: Qt.AlignHCenter


            // Enable custom config
            DefaultCheckBox {
                Layout.alignment: Qt.AlignHCenter
                id: enable_custom_config
                text: API.get().empty_string + (qsTr("Use custom protection settings"))
            }

            // Configuration settings
            ColumnLayout {
                id: custom_config
                visible: enable_custom_config.checked

                Layout.alignment: Qt.AlignHCenter
                Layout.leftMargin: 40

                // dPoW configuration switch
                Switch {
                    id: enable_dpow_confs
                    Layout.alignment: Qt.AlignHCenter

                    checked: true
                    onCheckedChanged: {
                        if(checked) enable_normal_confs.checked = true
                    }

                    text: API.get().empty_string + (qsTr("Enable Komodo dPoW security"))
                }

                // Normal configuration switch
                Switch {
                    id: enable_normal_confs
                    Layout.alignment: Qt.AlignHCenter

                    enabled: !enable_dpow_confs.checked
                    checked: true

                    text: API.get().empty_string + (qsTr("Change required confirmations"))
                }

                // Normal configuration settings
                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    visible: !enable_dpow_confs.checked && enable_normal_confs.checked
                    Layout.leftMargin: custom_config.Layout.leftMargin

                    DefaultText {
                        Layout.alignment: Qt.AlignHCenter
                        text_value: API.get().empty_string + (qsTr("Confirmations") + ": " + required_confirmation_count.value
                                                              + (required_confirmation_count.value === required_confirmation_count.default_confirmation_count ?
                                                                     " (" + qsTr("Recommended") + ")" : ""))
                    }

                    Slider {
                        readonly property int default_confirmation_count: 3
                        Layout.alignment: Qt.AlignHCenter
                        id: required_confirmation_count
                        stepSize: 1
                        from: 1
                        to: 5
                        live: true
                        snapMode: Slider.SnapAlways
                        value: default_confirmation_count
                    }
                }
            }

            // Warning when both are off
            DefaultText {
                visible: enable_custom_config.visible && enable_custom_config.enabled && enable_custom_config.checked &&
                         !enable_dpow_confs.checked
                Layout.alignment: Qt.AlignHCenter
                text_value: API.get().empty_string + (qsTr("Warning, this atomic swap is not dPoW protected"))
                color: Style.colorRed
            }
        }

        // Buttons
        RowLayout {
            DefaultButton {
                text: API.get().empty_string + (qsTr("Cancel"))
                Layout.fillWidth: true
                onClicked: root.close()
            }

            PrimaryButton {
                text: API.get().empty_string + (qsTr("Confirm"))
                Layout.fillWidth: true
                onClicked: {
                    root.close()

                    trade(getTicker(true), getTicker(false), {
                            enable_custom_config: enable_custom_config.visible && enable_custom_config.enabled && enable_custom_config.checked,
                            enable_dpow_confs: enable_dpow_confs.visible && enable_dpow_confs.enabled && enable_dpow_confs.checked,
                            enable_normal_confs: enable_normal_confs.visible && enable_normal_confs.enabled && enable_normal_confs.checked,
                            normal_configuration: {
                                  required_confirmation_count: required_confirmation_count.value
                            },
                          })
                }
            }
        }
    }
}
