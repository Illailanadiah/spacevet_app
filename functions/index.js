const functions = require('firebase-functions');
const admin     = require('firebase-admin');
admin.initializeApp();

// Trigger whenever a new reminder/plan is created
exports.scheduleReminders = functions.firestore
  .document('users/{uid}/items/{itemId}')
  .onCreate(async (snap, ctx) => {
    const data       = snap.data();
    const uid        = ctx.params.uid;
    const fcmToken   = (await admin.firestore()
      .collection('users').doc(uid).get()).data()?.fcmToken;
    if (!fcmToken) return console.warn('No FCM token for user', uid);

    const { title, startTime, timesPerDay, intervalMs } = data;
    const startMs = startTime.toDate().getTime();

    for (let i = 0; i < timesPerDay; i++) {
      const sendAt = startMs + i * intervalMs;
      const delay  = sendAt - Date.now();
      if (delay < 0) continue;  // skip past times

      setTimeout(() => {
        admin.messaging().send({
          token: fcmToken,
          notification: {
            title: `Reminder: ${title}`,
            body: `Time for dose ${i+1} of ${timesPerDay}`,
          },
        }).catch(console.error);
      }, delay);
    }
  });
