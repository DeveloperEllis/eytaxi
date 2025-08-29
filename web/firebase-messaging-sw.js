importScripts('https://www.gstatic.com/firebasejs/10.14.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.14.0/firebase-messaging-compat.js');

// Inicializa Firebase con tu config
firebase.initializeApp({
  apiKey: "AIzaSyB7S5IpWuSN9GUGWEmpLJI6oZv8NbmEElM",
  authDomain: "taxibookingcuba.firebaseapp.com",
  projectId: "taxibookingcuba",
  storageBucket: "taxibookingcuba.firebasestorage.app",
  messagingSenderId: "230009861369",
  appId: "1:230009861369:web:2f6d7bfe7a6caacb249e28",
});

const messaging = firebase.messaging();
