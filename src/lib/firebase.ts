// 임시 Firebase 모의 설정 - 실제 Firebase 프로젝트 없이도 동작
// 실제 Firebase 프로젝트 생성 후 아래 설정을 실제 값으로 변경 필요

// 모의 auth 객체
export const auth = {
  currentUser: null,
  signInWithRedirect: () => Promise.reject(new Error("Firebase 프로젝트가 설정되지 않았습니다.")),
  getRedirectResult: () => Promise.resolve(null),
  onAuthStateChanged: () => () => {},
} as any;

// 모의 db 객체
export const db = {} as any;

// 모의 app 객체
export const app = {} as any;

// 실제 Firebase 설정 (주석 처리)
/*
import { initializeApp, getApps, getApp, type FirebaseApp } from "firebase/app";
import { getAuth, type Auth } from "firebase/auth";
import { getFirestore, type Firestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "YOUR_ACTUAL_API_KEY",
  authDomain: "YOUR_PROJECT.firebaseapp.com", 
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT.firebasestorage.app",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID",
  measurementId: "YOUR_MEASUREMENT_ID"
};

let app: FirebaseApp;
if (!getApps().length) {
  app = initializeApp(firebaseConfig);
} else {
  app = getApp();
}

const auth: Auth = getAuth(app);
const db: Firestore = getFirestore(app);

export { app, auth, db };
*/
