import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 현재 사용자
  firebase_auth.User? get currentUser => _auth.currentUser;
  
  // 로그인 상태 스트림
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // Google 로그인
  Future<firebase_auth.UserCredential?> signInWithGoogle() async {
    try {
      // Google 로그인 프로세스 시작
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // 사용자가 로그인 취소
        return null;
      }

      // Google 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 토큰 검증
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Google 인증 토큰을 가져올 수 없습니다');
      }

      // Firebase 인증 자격 증명 생성
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken!,
        idToken: googleAuth.idToken!,
      );

      // Firebase에 로그인
      final firebase_auth.UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Firestore에 사용자 정보 저장/업데이트
      if (userCredential.user != null) {
        await _createOrUpdateUser(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Google 로그인 오류: $e');
      }
      rethrow;
    }
  }

  // 게스트 로그인 (익명 로그인)
  Future<firebase_auth.UserCredential?> signInAnonymously() async {
    try {
      final firebase_auth.UserCredential userCredential = await _auth.signInAnonymously();
      
      // Firestore에 게스트 사용자 정보 저장
      if (userCredential.user != null) {
        await _createOrUpdateUser(userCredential.user!, isGuest: true);
      }
      
      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('게스트 로그인 오류: $e');
      }
      rethrow;
    }
  }

  // Kakao 로그인
  Future<firebase_auth.UserCredential?> signInWithKakao() async {
    try {
      // 카카오톡 설치 여부 확인
      final installed = await isKakaoTalkInstalled();
      
      OAuthToken token;
      if (installed) {
        // 카카오톡으로 로그인
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        // 카카오 계정으로 로그인
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      // 카카오 사용자 정보 가져오기
      final kakaoUser = await UserApi.instance.me();
      
      // Firebase Custom Token 생성을 위한 정보
      // 실제 배포 시에는 백엔드 서버에서 Custom Token을 생성해야 합니다
      // 현재는 Firestore에 카카오 사용자 정보만 저장합니다
      
      // 임시로 익명 로그인 후 카카오 정보로 업데이트
      final firebase_auth.UserCredential userCredential = await _auth.signInAnonymously();
      
      if (userCredential.user != null) {
        await _createOrUpdateUser(
          userCredential.user!,
          isKakao: true,
          kakaoId: kakaoUser.id.toString(),
          kakaoName: kakaoUser.kakaoAccount?.profile?.nickname ?? '카카오 사용자',
          kakaoEmail: kakaoUser.kakaoAccount?.email ?? '',
          kakaoProfileUrl: kakaoUser.kakaoAccount?.profile?.profileImageUrl ?? '',
        );
      }
      
      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Kakao 로그인 오류: $e');
      }
      rethrow;
    }
  }

  // Firestore에 사용자 정보 생성/업데이트
  Future<void> _createOrUpdateUser(
    firebase_auth.User user, {
    bool isGuest = false,
    bool isKakao = false,
    String? kakaoId,
    String? kakaoName,
    String? kakaoEmail,
    String? kakaoProfileUrl,
  }) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      // 새 사용자 생성
      await userDoc.set({
        'uid': user.uid,
        'email': isKakao ? (kakaoEmail ?? '') : (user.email ?? ''),
        'name': isGuest 
            ? '게스트' 
            : (isKakao ? (kakaoName ?? '') : (user.displayName ?? '')),
        'phone': user.phoneNumber ?? '',
        'photoURL': isKakao ? (kakaoProfileUrl ?? '') : (user.photoURL ?? ''),
        'isAdmin': false,
        'isGuest': isGuest,
        'isKakao': isKakao,
        'kakaoId': kakaoId ?? '',
        'provider': isGuest ? 'anonymous' : (isKakao ? 'kakao' : 'google'),
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } else {
      // 기존 사용자 로그인 시간 업데이트
      final updateData = <String, dynamic>{
        'lastLogin': FieldValue.serverTimestamp(),
      };
      
      // 카카오 로그인 시 정보 업데이트
      if (isKakao) {
        updateData['name'] = kakaoName ?? '';
        updateData['email'] = kakaoEmail ?? '';
        updateData['photoURL'] = kakaoProfileUrl ?? '';
      }
      
      await userDoc.update(updateData);
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      // Kakao 로그아웃
      try {
        await UserApi.instance.logout();
      } catch (e) {
        // 카카오 로그인이 아닌 경우 무시
      }
      
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('로그아웃 오류: $e');
      }
      rethrow;
    }
  }

  // 사용자 정보 가져오기
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('사용자 정보 가져오기 오류: $e');
      }
      return null;
    }
  }

  // 관리자 권한 확인
  Future<bool> isAdmin() async {
    if (currentUser == null) return false;
    
    try {
      final userData = await getUserData(currentUser!.uid);
      return userData?['isAdmin'] == true;
    } catch (e) {
      return false;
    }
  }
}
