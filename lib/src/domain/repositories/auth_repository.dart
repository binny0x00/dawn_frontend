import 'dart:async';

import 'package:dawn_frontend/src/core/utils/constants/api_constants.dart';
import 'package:dawn_frontend/src/data/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

bool _gsiInitialized = false; // 클래스 상단에 추가

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final AuthService _authService = AuthService();

  // 구글 로그인 및 회원 가입
  // Future<String?> signInWithGoogle() async {
  //   try {
  //     final googleUser = await _googleSignIn.authenticate();
  //     if (googleUser != null) {
  //       final googleAuth = await googleUser.authentication;
  //       final credential = GoogleAuthProvider.credential(
  //         accessToken: googleAuth.accessToken,
  //         idToken: googleAuth.idToken,
  //       );
  //       final _userCredential = await _firebaseAuth.signInWithCredential(
  //         credential,
  //       ); // _userCredential.additionalUserInfo?.isNewUser 확인 가능
  //       return null; // 성공
  //     } else {
  //       return 'auth_cancelled'; // 취소
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     return _firebaseErrorKey(e);
  //   } catch (e, s) {
  //     debugPrint('Google Sign-In failed: $e');
  //     debugPrint('Stack trace: $s');
  //     return 'auth_google_failed';
  //   }
  // }
  // 구글 로그인 및 회원 가입 (google_sign_in ^7.x 기준)
  Future<String?> signInWithGoogle() async {
    try {
      // ✅ Web은 Firebase의 팝업 경로로 처리
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        provider.setCustomParameters({'prompt': 'select_account'});
        await _firebaseAuth.signInWithPopup(provider);
        return null;
      }

      // ✅ google_sign_in v7: 반드시 initialize 1회 필요
      if (!_gsiInitialized) {
        await _googleSignIn.initialize(
          // 반드시 "Web OAuth Client ID" 사용
          clientId: serverClientId,
        );
        _gsiInitialized = true;
      }

      // 일부 플랫폼에서 authenticate 미제공일 수 있어 사전 체크
      if (!_googleSignIn.supportsAuthenticate()) {
        return 'auth_platform_error';
      }

      // ✅ 인터랙티브 로그인(UI 띄움) — 버튼 탭 직후 호출 권장
      final googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return 'auth_cancelled';

      // ✅ Android에선 accessToken이 null일 수 있으므로 idToken 위주로 처리
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        return 'auth_google_failed';
      }

      // ✅ Firebase 연동
      final credential = GoogleAuthProvider.credential(
        idToken: idToken
      );
      await _firebaseAuth.signInWithCredential(credential);
      return null; // 성공
    } on GoogleSignInException catch (e) {
      // v7 예외 매핑 (원하면 더 세분화 가능)
      switch (e.code) {
        case GoogleSignInExceptionCode.canceled:
          return 'auth_cancelled';
        case GoogleSignInExceptionCode.uiUnavailable:
        case GoogleSignInExceptionCode.interrupted:
          return 'auth_platform_error';
        default:
          debugPrint('GoogleSignInException: ${e.code} ${e.description}');
          return 'auth_google_failed';
      }
    } on FirebaseAuthException catch (e) {
      return _firebaseErrorKey(e);
    } catch (e, s) {
      debugPrint('Google Sign-In failed: $e');
      debugPrint('Stack trace: $s');
      return 'auth_google_failed';
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      // Handle sign out error
    }
  }

  // 이메일로 회원 가입
  Future<String?> signUpWithEmail(String email, String password) async {
    try {
      final _userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      // 이메일 인증
      //await _userCredential.user?.sendEmailVerification();
      return null;
      //return 'email_verification_sent';
    } on FirebaseAuthException catch (e) {
      //throw Exception(_firebaseErrorKey(e));
      return _firebaseErrorKey(e);
    }
  }

  // 이메일 로그인
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _firebaseErrorKey(e);
    }

    // await _googleSignIn.disconnect(); // 구글 계정 연결 해제
    // await _firebaseAuth.signOut();    // Firebase 인증 로그아웃
  }

  String _firebaseErrorKey(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'error_email_already_in_use';
      case 'invalid-email':
        return 'error_invalid_email';
      case 'user-not-found':
        return 'error_user_not_found';
      case 'wrong-password':
        return 'error_wrong_password';
      case 'weak-password':
        return 'error_weak_password';
      default:
        return 'error_signup_failed';
    }
  }

  // JWT 로그인
  Future<String?> loginWithFirebaseToken(String idToken) {
    return _authService.loginWithFirebaseToken(idToken);
  }
}
