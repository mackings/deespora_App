import 'dart:async';
import 'dart:convert';
import 'package:deespora/View/model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;



final FirebaseAuth _auth = FirebaseAuth.instance;

// Replace with your backend base URL
const String backendUrl = "https://deespora-backend.onrender.com";

/// Request OTP via Firebase
/// Returns [verificationId] for manual OTP entry
Future<String> requestOtp(String phoneNumber) async {
  final completer = Completer<String>();

  await _auth.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    timeout: const Duration(seconds: 60),
    verificationCompleted: (PhoneAuthCredential credential) async {
      // Auto verification (Android only)
      final userCred = await _auth.signInWithCredential(credential);
      final idToken = await userCred.user?.getIdToken();
      if (idToken != null) {
        completer.complete(idToken);
      }
    },
    verificationFailed: (FirebaseAuthException e) {
      completer.completeError(e.message ?? "Verification failed");
    },
    codeSent: (String verificationId, int? resendToken) {
      // Return verificationId so user can enter OTP manually
      completer.complete(verificationId);
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      // Auto retrieval timed out
      completer.complete(verificationId);
    },
  );

  return completer.future;
}

/// Verify OTP with Firebase, then confirm with backend
/// Returns updated [UserModel] after verification
Future<UserModel> verifyOtp({
  required String verificationId,
  required String smsCode,
  required String uid,
}) async {
  try {
    // Sign in with the OTP
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final userCred = await _auth.signInWithCredential(credential);

    // Get Firebase idToken
    final idToken = await userCred.user?.getIdToken();
    if (idToken == null) {
      throw Exception("Failed to retrieve Firebase ID token");
    }

    // Send to backend for verification
    final res = await http.post(
      Uri.parse("$backendUrl/auth/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "uid": uid,
        "idToken": idToken,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Backend error: ${res.body}");
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;

    // Return updated UserModel
    return UserModel.fromJson({
      "uid": data["uid"] ?? uid,
      "phoneVerified": true,
      "phoneNumber": data["phone"],
    });
  } catch (e) {
    rethrow;
  }
}
