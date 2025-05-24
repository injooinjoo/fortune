
// Import the functions you need from the SDKs you need
import { initializeApp, getApps, getApp, type FirebaseApp } from "firebase/app";
import { getAuth, type Auth } from "firebase/auth";
import { getFirestore, type Firestore } from "firebase/firestore";
// getAnalytics is not directly used by the app right now, can be added later if needed.
// import { getAnalytics } from "firebase/analytics";

// Your web app's Firebase configuration (values provided by user)
// IMPORTANT: Hardcoding API keys and sensitive information directly in the source code
// is NOT recommended for production. This is a temporary setup.
// Please use environment variables (.env file) for better security in production.
const firebaseConfig = {
  apiKey: "AIzaSyB7n-RpmPvrkxsA05-Q24slWTluWC5fA-M",
  authDomain: "fortune-3f6a2.firebaseapp.com",
  projectId: "fortune-3f6a2",
  storageBucket: "fortune-3f6a2.firebasestorage.app",
  messagingSenderId: "668458108279",
  appId: "1:668458108279:web:4713f40aa316fd69564d72",
  measurementId: "G-94Z1C97D3L"
};

// Initialize Firebase
let app: FirebaseApp;
if (!getApps().length) {
  app = initializeApp(firebaseConfig);
} else {
  app = getApp();
}

const auth: Auth = getAuth(app);
const db: Firestore = getFirestore(app);
// const analytics = getAnalytics(app); // Uncomment if analytics is needed

export { app, auth, db };
