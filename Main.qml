import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.OnlineAccounts 0.1
import Ubuntu.OnlineAccounts.Client 0.1

import "weiboapi.js" as API

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    id: main
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "qml-weibo.ubuntu"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    property string accesstoken:""

    width: units.gu(100)
    height: units.gu(90)

    Page {
        id: root
        clip:true
        title: i18n.tr("Weibo")

        Column {
            spacing: units.gu(2)
            width: parent.width

            ListView {
                id: accountsList

                anchors.horizontalCenter: parent.Center
                anchors.verticalCenter: parent.Center

                height: contentHeight
                width: root.width

                spacing: units.gu(1)
                model: accountsModel

                delegate: Rectangle {
                    id: wrapper
                    width: accountsList.width
                    height: units.gu(10)
                    color: accts.enabled ? "green" : "red"

                    AccountService {
                        id: accts
                        objectHandle: accountServiceHandle
                        onAuthenticated: {
                            console.log("reply: " + JSON.stringify(reply));
                            var obj = JSON.parse(JSON.stringify(reply));
                            console.log("AccessToken: " + obj.AccessToken);
                            main.accesstoken = obj.AccessToken;

                            // Make the authenticate button invisile
                            accountsList.visible = false;

                            // Start to get the data
                            API.getStatus();
                        }
                        onAuthenticationError: {
                            console.log("Authentication failed, code " + error.code)
                            authenticateBtn.text = displayName + " Error " + error.code + " please do it again";
                        }
                    }

                    Button {
                        id: authenticateBtn

                        anchors.fill: parent
                        anchors.margins: units.gu(2)
                        text: i18n.tr("Authenticate %1").arg(model.displayName + " " + model.providerName)

                        onClicked: {
                            var params = {}
                            accts.authenticate(params)
                        }
                    }
                }

            }

            Button {
                id: createAccountBtn

                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: units.gu(8)
                text: i18n.tr("Request access")
                onClicked: setup.exec()
            }


            ListModel {
                id: modelWeibo
            }

            ListView {
                id: weiboList
                width: parent.width
                height: parent.height
                spacing: units.gu(1)


                model: modelWeibo

                delegate: Rectangle {
                    width: parent.width
                    height: units.gu(8)
                    color: "lightgrey"

                    BorderImage {
                        id: image
                        source: {return JSON.parse('' + JSON.stringify(user) + '').profile_image_url}
                        width: parent.height; height: parent.height
                        border.left: 5; border.top: 5
                        border.right: 5; border.bottom: 5
                    }

                    Column {
                        spacing: units.gu(1)
                        x: image.width + 10
                        width: parent.width - image.width - 20
                        height: parent.height

                        Text {
                            id: title

                            text: {return JSON.parse('' + JSON.stringify(user) + '').name }
                        }

                        Text {
                            id: subtitle

                            text: {return model.text }
                        }
                    }
                }
            }
        }
    }

    AccountServiceModel {
        id: accountsModel
        applicationId: "qml-weibo.ubuntu_qmlweibo"
    }

    Setup {
        id: setup
        providerId: "qml-weibo.ubuntu_plugin"
        applicationId: "qml-weibo.ubuntu_qmlweibo"
        onFinished: {
            createAccountBtn.visible = false;
        }
    }

    Component.onCompleted: {
        if ( accountsModel.count == 0 ) {
            // If there is no such an account, we need to create such one
            setup.exec();
        } else {
            // hide the button since the account has already been created
             createAccountBtn.visible = false
        }
    }
}
