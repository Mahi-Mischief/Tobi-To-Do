import admin from 'firebase-admin';
import dotenv from 'dotenv';

dotenv.config();

let firebaseApp = null;

export function initializeFirebase() {
  if (firebaseApp) {
    return firebaseApp;
  }

  try {
    // Firebase credentials from environment variables
    const credentials = {
      type: 'service_account',
      project_id: process.env.FIREBASE_PROJECT_ID || 'tobi-to-do',
      private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
      private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
      client_email: process.env.FIREBASE_CLIENT_EMAIL,
      client_id: process.env.FIREBASE_CLIENT_ID,
      auth_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_uri: 'https://oauth2.googleapis.com/token',
      auth_provider_x509_cert_url: 'https://www.googleapis.com/oauth2/v1/certs',
    };

    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert(credentials),
      projectId: process.env.FIREBASE_PROJECT_ID || 'tobi-to-do',
    });

    console.log('✓ Firebase Admin SDK initialized');
    return firebaseApp;
  } catch (error) {
    console.warn('⚠️  Firebase not configured - using JWT authentication instead');
    console.warn('Error:', error.message);
    return null;
  }
}

export function getFirebaseApp() {
  return firebaseApp;
}

// Verify Firebase ID Token
export async function verifyFirebaseToken(token) {
  try {
    if (!firebaseApp) {
      throw new Error('Firebase not initialized');
    }
    const decodedToken = await admin.auth().verifyIdToken(token);
    return decodedToken;
  } catch (error) {
    throw new Error('Invalid Firebase token');
  }
}

// Create Firebase user
export async function createFirebaseUser(email, password) {
  try {
    if (!firebaseApp) {
      throw new Error('Firebase not initialized');
    }
    const userRecord = await admin.auth().createUser({
      email,
      password
    });
    return userRecord;
  } catch (error) {
    throw new Error(`Failed to create Firebase user: ${error.message}`);
  }
}

// Get Firebase user by email
export async function getFirebaseUserByEmail(email) {
  try {
    if (!firebaseApp) {
      throw new Error('Firebase not initialized');
    }
    const userRecord = await admin.auth().getUserByEmail(email);
    return userRecord;
  } catch (error) {
    throw new Error(`Failed to get Firebase user: ${error.message}`);
  }
}

// Get Firebase user by UID
export async function getFirebaseUserByUID(uid) {
  try {
    if (!firebaseApp) {
      throw new Error('Firebase not initialized');
    }
    const userRecord = await admin.auth().getUser(uid);
    return userRecord;
  } catch (error) {
    throw new Error(`Failed to get Firebase user: ${error.message}`);
  }
}

// Delete Firebase user
export async function deleteFirebaseUser(uid) {
  try {
    if (!firebaseApp) {
      throw new Error('Firebase not initialized');
    }
    await admin.auth().deleteUser(uid);
  } catch (error) {
    throw new Error(`Failed to delete Firebase user: ${error.message}`);
  }
}

export { admin };
