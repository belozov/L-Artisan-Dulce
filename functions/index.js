const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendOrderNotification = functions.firestore
    .document("users/{userId}/orders/{orderId}")
    .onCreate(async (snap, context) => {

        const userId = context.params.userId;

        // получаем токен пользователя
        const userDoc = await admin.firestore()
            .collection("users")
            .doc(userId)
            .get();

        const token = userDoc.data().fcmToken;

        if (!token) return null;

        const payload = {
            notification: {
                title: "Order Created 🍰",
                body: "Your dessert is being prepared",
            }
        };

        return admin.messaging().sendToDevice(token, payload);
    });