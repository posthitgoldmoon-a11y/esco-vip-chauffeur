import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  fb.User? get currentUser => _auth.currentUser;
  Stream<fb.User?> get authStateChanges => _auth.authStateChanges();

  // ─── Google 로그인 ────────────────────────────────────────────
  Future<fb.User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Google 인증 토큰을 가져올 수 없습니다.');
      }

      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final fb.UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final fb.User? user = userCredential.user;
      if (user != null) await _createOrUpdateUser(user);
      return user;
    } catch (e) {
      throw Exception('Google 로그인 실패: $e');
    }
  }

  // ─── 익명 로그인 ──────────────────────────────────────────────
  Future<fb.User?> signInAnonymously() async {
    try {
      final fb.UserCredential userCredential =
          await _auth.signInAnonymously();
      final fb.User? user = userCredential.user;
      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': null,
          'name': '게스트',
          'photoURL': null,
          'isAnonymous': true,
          'isAdmin': false,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      return user;
    } catch (e) {
      throw Exception('익명 로그인 실패: $e');
    }
  }

  // ─── 카카오 로그인 ────────────────────────────────────────────
  Future<fb.User?> signInWithKakao() async {
    try {
      final OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }
      debugPrint('Kakao token expires: ${token.expiresAt}');

      final kakaoUser = await UserApi.instance.me();
      final fb.UserCredential userCredential =
          await _auth.signInAnonymously();
      final fb.User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        await _db.collection('users').doc(firebaseUser.uid).set({
          'uid': firebaseUser.uid,
          'email': kakaoUser.kakaoAccount?.email,
          'name':
              kakaoUser.kakaoAccount?.profile?.nickname ?? '카카오 사용자',
          'photoURL':
              kakaoUser.kakaoAccount?.profile?.profileImageUrl,
          'isKakao': true,
          'kakaoId': kakaoUser.id.toString(),
          'isAdmin': false,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      return firebaseUser;
    } catch (e) {
      throw Exception('카카오 로그인 실패: $e');
    }
  }

  // ─── 유저 문서 생성 또는 업데이트 ────────────────────────────
  Future<void> _createOrUpdateUser(fb.User user) async {
    final docRef = _db.collection('users').doc(user.uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName,
        'photoURL': user.photoURL,
        'isAdmin': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    }
  }

  // ─── 로그아웃 ─────────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      await UserApi.instance.logout();
    } catch (_) {}
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ─── 유저 데이터 가져오기 ─────────────────────────────────────
  Future<Map<String, dynamic>?> getUserData(String uid) async =>
      (await _db.collection('users').doc(uid).get()).data();

  // ─── 관리자 여부 확인 ─────────────────────────────────────────
  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final doc =
        await _db.collection('users').doc(user.uid).get();
    return doc.data()?['isAdmin'] as bool? ?? false;
  }
}
