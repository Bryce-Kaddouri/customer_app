importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: "AIzaSyBI0TsNQ6oLaJGtojPtmoNM2SbbdQsawO0",
    authDomain: "customer-app-2024.firebaseapp.com",
    projectId: "customer-app-2024",
    storageBucket: "customer-app-2024.appspot.com",
    messagingSenderId: "129875558924",
    appId: "1:129875558924:web:df694575635b67ec92a429",
    measurementId: "G-NQ55G5FSCD"
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
    console.log("onBackgroundMessage", m);
});