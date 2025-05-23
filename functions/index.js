const functions = require('firebase-functions');
const admin     = require('firebase-admin');
const { CloudTasksClient } = require('@google-cloud/tasks');
admin.initializeApp();

const client   = new CloudTasksClient();
const QUEUE    = 'ReminderQueue';
const LOCATION = 'us-central1';
const PROJECT  = process.env.GCLOUD_PROJECT || process.env.GCP_PROJECT;

async function scheduleTask(itemId, payload, runAt) {
  const parent = client.queuePath(PROJECT, LOCATION, QUEUE);
  const task = {
    httpRequest: {
      httpMethod: 'POST',
      url: `https://${LOCATION}-${PROJECT}.cloudfunctions.net/sendReminder`,
      headers: { 'Content-Type': 'application/json' },
      body: Buffer.from(JSON.stringify({ itemId, ...payload })).toString('base64'),
    },
    scheduleTime: { seconds: Math.floor(runAt.getTime() / 1000) },
  };
  await client.createTask({ parent, task });
}

// Fire on new reminder doc
exports.onReminderCreated = functions
  .runWith({ region: LOCATION })
  .firestore
  .document('users/{uid}/items/{itemId}')
  .onCreate(async (snap, ctx) => {
    const data = snap.data();
    const { startTime, intervalMs, title, category } = data;
    const uid       = ctx.params.uid;
    const itemId    = ctx.params.itemId;
    const userDoc   = await admin.firestore().collection('users').doc(uid).get();
    const fcmToken  = userDoc.data()?.fcmToken;
    if (!fcmToken) return console.warn("No FCM token for", uid);

    const payload = {
      uid,
      fcmToken,
      title,
      body: `⏰ Time for ${category=='reminder'?'your meds':'your event'}: ${title}`,
      intervalMs,
    };
    await scheduleTask(itemId, payload, startTime.toDate());
  });

// HTTP function triggered by Cloud Tasks
exports.sendReminder = functions
  .runWith({ region: LOCATION })
  .https
  .onRequest(async (req, res) => {
    const { itemId, uid, fcmToken, title, body, intervalMs } = req.body;
    try {
      // send FCM
      await admin.messaging().send({ token: fcmToken,
        notification:{ title, body },
        android: { priority: "high" }
      });
      // write into Firestore notifications collection
      await admin.firestore()
        .collection('users').doc(uid)
        .collection('notifications')
        .add({
          title, body,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          read: false, itemId
        });
      // schedule next run
      const nextRun = new Date(Date.now() + intervalMs);
      await scheduleTask(itemId, { uid, fcmToken, title, body, intervalMs }, nextRun);
      return res.status(200).send("OK");
    } catch (err) {
      console.error(err);
      return res.status(500).send("FAIL");
    }
  });
