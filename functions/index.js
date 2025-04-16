const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.notifyHeatIndex = functions.database
  .ref("/sensors/heatIndex/value")
  .onUpdate(async (change, context) => {
    const newValue = change.after.val();
    console.log(`Heat Index changed to: ${newValue}`);

    if (newValue >= 32) {
      const payload = {
        notification: {
          title: "🚨 Heat Emergency!",
          body: `Heat index is dangerously high (${newValue}°C).`,
        },
        topic: "alerts",
      };

      try {
        await admin.messaging().send(payload);
        console.log("Notification sent.");
      } catch (error) {
        console.error("Notification failed:", error);
      }
    }

    return null;
  });
