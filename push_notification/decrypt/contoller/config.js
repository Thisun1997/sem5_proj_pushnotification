const admin = require('firebase-admin');
const serviceAccount = require('../config/sem5proj-4c149-firebase-adminsdk-km5ja-1d94745744.json');

let firebaseInstance = null;

const getFirebase = (callback) => {
  if (firebaseInstance !== null) {
    return callback(firebaseInstance);
  }

  admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });
  
  firebaseInstance = admin;
  return callback(firebaseInstance);
}

module.exports.getFirebase = getFirebase;