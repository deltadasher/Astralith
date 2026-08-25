pragma Singleton

import QtQuick
import Quickshell.Services.Notifications
import ".."

QtObject {
    id: root

    property int nextUid: 0
    property int unreadCount: 0
    property var liveNotifications: ({})
    property ListModel history: ListModel {}
    property ListModel popups: ListModel {}

    function notificationFor(uid) {
        return liveNotifications[uid] || null;
    }

    function receive(notification) {
        notification.tracked = true;
        const uid = ++nextUid;
        liveNotifications[uid] = notification;

        const actions = [];
        if (notification.actions) {
            for (let index = 0; index < notification.actions.length; index++) {
                const action = notification.actions[index];
                if (action.identifier !== "default") {
                    actions.push({
                        "identifier": action.identifier || "action-" + index,
                        "text": action.text || action.identifier || "OPEN"
                    });
                }
            }
        }

        const entry = {
            "uid": uid,
            "appName": notification.appName || "System",
            "summary": notification.summary || "Notification",
            "body": notification.body || "",
            "icon": notification.image || notification.appIcon || "",
            "time": Qt.formatTime(new Date(), "HH:mm"),
            "critical": notification.urgency === NotificationUrgency.Critical,
            "actions": actions
        };

        history.insert(0, entry);
        while (history.count > 100)
            history.remove(history.count - 1);
        unreadCount++;

        if (!Settings.doNotDisturb)
            popups.insert(0, entry);
    }

    function preview(summary, body) {
        const entry = {
            "uid": ++nextUid,
            "appName": "Astralith",
            "summary": summary || "Transit link online",
            "body": body || "This toast is local to the active Astralith shell.",
            "icon": "",
            "time": Qt.formatTime(new Date(), "HH:mm"),
            "critical": false,
            "actions": []
        };
        history.insert(0, entry);
        unreadCount++;
        if (!Settings.doNotDisturb)
            popups.insert(0, entry);
    }

    function removePopup(uid) {
        for (let index = 0; index < popups.count; index++) {
            if (popups.get(index).uid === uid) {
                popups.remove(index);
                return;
            }
        }
    }

    function removeHistory(uid) {
        for (let index = 0; index < history.count; index++) {
            if (history.get(index).uid === uid) {
                history.remove(index);
                break;
            }
        }
        const notification = notificationFor(uid);
        if (notification)
            notification.dismiss();
        delete liveNotifications[uid];
        removePopup(uid);
    }

    function invokeDefault(uid) {
        const notification = notificationFor(uid);
        if (!notification || !notification.actions)
            return;
        for (let index = 0; index < notification.actions.length; index++) {
            if (notification.actions[index].identifier === "default") {
                notification.actions[index].invoke();
                break;
            }
        }
        removePopup(uid);
    }

    function invokeAction(uid, identifier) {
        const notification = notificationFor(uid);
        if (!notification || !notification.actions)
            return;
        for (let index = 0; index < notification.actions.length; index++) {
            if (notification.actions[index].identifier === identifier) {
                notification.actions[index].invoke();
                break;
            }
        }
        removePopup(uid);
    }

    function clearHistory() {
        history.clear();
        popups.clear();
        liveNotifications = ({});
        unreadCount = 0;
    }

    function markRead() {
        unreadCount = 0;
    }

    property NotificationServer server: NotificationServer {
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: false
        actionsSupported: true
        imageSupported: true
        onNotification: function(notification) { root.receive(notification); }
    }
}
