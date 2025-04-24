const functions = require("firebase-functions");
const admin = require("firebase-admin");
const moment = require("moment");
admin.initializeApp();

const db = admin.firestore();
const bucket = admin.storage().bucket();

// 🔥 Realtime DB - Notify when Heat Index is too high
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

// 📦 Scheduled Function - Archive logs to JSON in Storage
exports.archiveOldLogs = functions.pubsub
  .schedule("every day 00:00")
  .onRun(async (context) => {
    const devicesSnapshot = await db.collection("monitoring_logs").get();
    const deviceIds = devicesSnapshot.docs.map((doc) => doc.id);

    const cutoff = moment().subtract(7, "days").toDate();

    for (const deviceId of deviceIds) {
      const logRef = db
        .collection("monitoring_logs")
        .doc(deviceId)
        .collection("readings");

      const snapshot = await logRef.where("timestamp", "<", cutoff).get();
      if (snapshot.empty) {
        console.log(`No logs to archive for device ${deviceId}`);
        continue;
      }

      const logs = [];
      snapshot.forEach((doc) => logs.push(doc.data()));

      const logsByDay = logs.reduce((acc, log) => {
        const date = moment(log.timestamp.toDate()).format("YYYY-MM-DD");
        acc[date] = acc[date] || [];
        acc[date].push(log);
        return acc;
      }, {});

      for (const [day, dayLogs] of Object.entries(logsByDay)) {
        const dateMoment = moment(day);
        const filePath = `logs/${deviceId}/${dateMoment.year()}/${dateMoment.format(
          "MM"
        )}/week${dateMoment.week()}/${dateMoment.format("DD")}.json`;

        const file = bucket.file(filePath);
        const contents = JSON.stringify(dayLogs, null, 2);

        await file.save(contents, {
          contentType: "application/json",
        });

        console.log(
          `Archived ${dayLogs.length} logs for ${deviceId} to ${filePath}`
        );
      }

      const batch = db.batch();
      snapshot.docs.forEach((doc) => batch.delete(doc.ref));
      await batch.commit();
      console.log(`Deleted old logs from Firestore for device ${deviceId}`);
    }

    return null;
  });
