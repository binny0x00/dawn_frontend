import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase 및 Google 인증 세션 초기화 (로그아웃)
Future<void> forceLogout() async {
  // 수정 이유:
  // 1. GoogleSignIn()을 여러 번 호출하여 불필요한 인스턴스를 생성하는 것을 방지합니다.
  // 2. 릴리즈 모드에서 로그가 남지 않도록 print() 대신 debugPrint()를 사용합니다.
  final googleSignIn = GoogleSignIn.instance;
  try {
    await googleSignIn.signOut();
    await googleSignIn.disconnect();
    await FirebaseAuth.instance.signOut();
  } catch (e) {
    debugPrint('Logout failed: $e');
  }
}
