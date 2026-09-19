const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

/**
 * 1. Background Trigger: Auto-initialize role on user profile creation
 * Whenever a user document is created in Firestore (e.g. from the client during registration),
 * this trigger ensures `role: 'employee'` is set server-side via Firebase Admin SDK.
 * It ignores any client attempts to set role and ensures single source of truth at `users/{uid}.role`.
 */
exports.onUserDocumentCreated = onDocumentCreated("users/{userId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) return;

  const data = snapshot.data();
  // If role is already set (e.g. via Admin Console or Admin script), do not overwrite.
  if (!data.role) {
    await snapshot.ref.update({
      role: "employee",
      roleAssignedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
});

/**
 * 2. Callable Function: initializeUserProfile
 * Callable endpoint for clients during registration/sign-in.
 * Accepts: { isl, name, department }
 * Explicitly rejects any client-supplied 'role' parameter.
 * Writes to `users/{uid}` with trusted `role: 'employee'`.
 */
exports.initializeUserProfile = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "User must be authenticated to initialize profile."
    );
  }

  const uid = request.auth.uid;
  const { isl, name, department } = request.data || {};

  // Reject if client attempts to pass role
  if (request.data && "role" in request.data) {
    throw new HttpsError(
      "invalid-argument",
      "Client is not permitted to specify role. Role is assigned server-side only."
    );
  }

  if (!isl || typeof isl !== "string") {
    throw new HttpsError("invalid-argument", "Bank Staff ISL is required.");
  }

  const userRef = db.collection("users").doc(uid);
  const userDoc = await userRef.get();

  if (!userDoc.exists) {
    await userRef.set({
      uid,
      isl: isl.trim().toUpperCase(),
      name: (name || "Bank Employee").trim(),
      department: (department || "Central Operations").trim(),
      role: "employee", // Server-side assignment only
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      lastLogin: admin.firestore.FieldValue.serverTimestamp(),
    });
  } else {
    // Preserve existing role, only update profile fields
    await userRef.update({
      isl: isl.trim().toUpperCase(),
      name: (name || userDoc.data().name || "Bank Employee").trim(),
      department: (department || userDoc.data().department || "Central Operations").trim(),
      lastLogin: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  return {
    success: true,
    role: userDoc.exists && userDoc.data().role ? userDoc.data().role : "employee",
  };
});

/**
 * 3. Callable Function: setUserRole (Admin-gated only)
 * Allows administrators to assign driver or admin roles to users.
 * Strictly verifies caller's role in `users/{callerUid}` is 'admin'.
 */
exports.setUserRole = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }

  const callerUid = request.auth.uid;
  const callerDoc = await db.collection("users").doc(callerUid).get();

  if (!callerDoc.exists || callerDoc.data().role !== "admin") {
    throw new HttpsError(
      "permission-denied",
      "Only administrators can assign user roles."
    );
  }

  const { targetUid, role } = request.data || {};
  if (!targetUid || typeof targetUid !== "string") {
    throw new HttpsError("invalid-argument", "Valid targetUid is required.");
  }

  const validRoles = ["employee", "driver", "admin"];
  if (!role || !validRoles.includes(role)) {
    throw new HttpsError(
      "invalid-argument",
      `Invalid role. Must be one of: ${validRoles.join(", ")}`
    );
  }

  const targetRef = db.collection("users").doc(targetUid);
  const targetDoc = await targetRef.get();
  if (!targetDoc.exists) {
    throw new HttpsError("not-found", `User document ${targetUid} not found.`);
  }

  await targetRef.update({
    role,
    roleUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
    roleUpdatedBy: callerUid,
  });

  return { success: true, targetUid, newRole: role };
});
