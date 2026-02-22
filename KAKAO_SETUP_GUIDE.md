# 🔐 Kakao 로그인 설정 가이드

## ✅ 현재 상태

- ✅ Kakao Flutter SDK 설치 완료 (v1.10.0)
- ✅ AuthService에 Kakao 로그인 메서드 추가
- ✅ 로그인 화면에 Kakao 버튼 연동
- ✅ AndroidManifest.xml 설정 완료
- ⚠️ **Native App Key 입력 필요**

---

## 📋 Kakao Developers 설정 절차

### STEP 1: Kakao Developers 앱 생성

1. **Kakao Developers 접속**
   - URL: https://developers.kakao.com/
   - 카카오 계정으로 로그인

2. **애플리케이션 추가**
   - "내 애플리케이션" → "애플리케이션 추가하기"
   - 앱 이름: `ESCO VIP Chauffeur`
   - 사업자명: `ESCO`
   - 카테고리: 비즈니스/여행

3. **Native App Key 확인**
   - 앱 설정 → 요약 정보
   - **Native App Key** 복사 (예: `abc123def456...`)

---

### STEP 2: Android 플랫폼 등록

1. **플랫폼 추가**
   - 앱 설정 → 플랫폼 → Android 플랫폼 등록
   - 패키지명: `com.vipchauffeur.chauffeur`

2. **키 해시 등록**
   
   **Release 키 해시 (배포용)**:
   ```
   HSplCKO+3d8EMY2uRQwl2JUU3Qk=
   ```
   
   이 키 해시를 Kakao Developers → 앱 설정 → 플랫폼 → Android → 키 해시에 등록하세요.

---

### STEP 3: Kakao 로그인 활성화

1. **제품 설정 → 카카오 로그인**
   - 활성화 설정: **ON**

2. **Redirect URI 설정**
   - `kakao{YOUR_NATIVE_APP_KEY}://oauth`
   - 예: `kakaoabc123def456://oauth`

3. **동의 항목 설정**
   - 필수 동의:
     - ✅ 닉네임
     - ✅ 프로필 사진 (선택)
   - 선택 동의:
     - ✅ 카카오계정(이메일)
     - ✅ 전화번호 (선택)

---

## 🔧 코드에 Native App Key 입력

### 1. main.dart 수정

파일: `lib/main.dart`

```dart
KakaoSdk.init(
  nativeAppKey: 'YOUR_NATIVE_APP_KEY',  // ← 여기에 발급받은 Native App Key 입력
);
```

**예시**:
```dart
KakaoSdk.init(
  nativeAppKey: 'abc123def456ghi789',  // 실제 키로 교체
);
```

### 2. AndroidManifest.xml 수정

파일: `android/app/src/main/AndroidManifest.xml`

**수정 필요한 부분 (2곳)**:

1. **meta-data 부분**:
```xml
<meta-data
    android:name="com.kakao.sdk.AppKey"
    android:value="YOUR_NATIVE_APP_KEY" />  <!-- 여기에 실제 키 입력 -->
```

2. **Redirect URI 부분**:
```xml
<data
    android:host="oauth"
    android:scheme="kakaoYOUR_NATIVE_APP_KEY" />  <!-- 여기에 실제 키 입력 -->
```

**예시**:
```xml
<!-- 예: Native App Key = abc123def456 -->
<meta-data
    android:name="com.kakao.sdk.AppKey"
    android:value="abc123def456" />

<data
    android:host="oauth"
    android:scheme="kakaoabc123def456" />
```

---

## 🧪 테스트 방법

### Web 테스트 (현재 가능)
```
URL: https://5060-i76e406wb2tl2m9knfse5-583b4d74.sandbox.novita.ai

⚠️ Web에서는 Kakao 로그인이 제한적입니다.
완전한 테스트를 위해서는 Android APK를 빌드하여 실제 기기에서 테스트하세요.
```

### Android 테스트 (권장)

1. **Native App Key 입력 완료 후 APK 빌드**:
```bash
cd /home/user/flutter_app
flutter build apk --release
```

2. **APK 다운로드 및 설치**:
   - 파일: `build/app/outputs/flutter-apk/app-release.apk`
   - Android 기기로 전송 및 설치

3. **Kakao 로그인 테스트**:
   - "Kakao로 로그인" 버튼 클릭
   - 카카오톡 앱이 설치되어 있으면 → 카카오톡으로 로그인
   - 카카오톡 앱이 없으면 → 카카오 계정으로 로그인
   - 동의 항목 확인 후 로그인
   - 메인 화면으로 자동 이동

---

## 📊 로그인 플로우

```
사용자가 "Kakao로 로그인" 버튼 클릭
           ↓
카카오톡 설치 여부 확인
           ↓
  ┌────────┴────────┐
  │                 │
설치됨            설치 안 됨
  │                 │
카카오톡 로그인   카카오 계정 로그인
  │                 │
  └────────┬────────┘
           ↓
   OAuth Token 획득
           ↓
  Kakao 사용자 정보 조회
           ↓
  Firebase 익명 로그인
           ↓
  Firestore에 Kakao 정보 저장
           ↓
     메인 화면 이동
```

---

## 🔥 Firebase 연동

Kakao 로그인으로 인증된 사용자는 Firebase Firestore에 다음 정보가 저장됩니다:

```json
{
  "uid": "firebase_uid",
  "email": "user@kakao.com",
  "name": "카카오 닉네임",
  "photoURL": "프로필 이미지 URL",
  "isKakao": true,
  "kakaoId": "123456789",
  "provider": "kakao",
  "createdAt": "2025-02-18T05:00:00Z",
  "lastLogin": "2025-02-18T05:00:00Z"
}
```

---

## ⚠️ 주의사항

### 1. Native App Key 보안
- Native App Key는 클라이언트 앱에서 사용되므로 외부 노출이 불가피합니다
- 이는 정상적인 Kakao SDK 사용 방식입니다
- 중요: Admin Key는 절대 앱에 포함하지 마세요

### 2. Release 빌드 전 체크리스트
- [ ] Native App Key를 `main.dart`에 입력
- [ ] Native App Key를 `AndroidManifest.xml`에 2곳 입력
- [ ] Release 키 해시를 Kakao Developers에 등록
- [ ] Kakao 로그인 활성화 확인
- [ ] Redirect URI 설정 확인
- [ ] 동의 항목 설정 확인

### 3. Firebase Custom Token (선택사항)
현재는 **익명 로그인 + Kakao 정보 저장** 방식을 사용합니다.

더 안전한 방법:
- 백엔드 서버에서 Firebase Custom Token 생성
- Kakao OAuth Token을 서버로 전송
- 서버에서 검증 후 Custom Token 발급
- Custom Token으로 Firebase 인증

---

## 📝 빠른 설정 요약

1. **Kakao Developers**:
   - 앱 생성
   - Native App Key 발급
   - Android 플랫폼 등록 (패키지명 + 키 해시)
   - Kakao 로그인 활성화
   - Redirect URI 설정

2. **코드 수정**:
   - `lib/main.dart`: Native App Key 입력
   - `android/app/src/main/AndroidManifest.xml`: Native App Key 2곳 입력

3. **빌드 & 테스트**:
   - APK 빌드
   - Android 기기에 설치
   - Kakao 로그인 테스트

---

## 🎯 완료 상태 확인

### 코드 준비 상태: ✅ 완료
- ✅ Kakao Flutter SDK 설치
- ✅ AuthService 구현
- ✅ 로그인 화면 연동
- ✅ AndroidManifest.xml 설정
- ✅ Firebase 연동

### 설정 필요 사항: ⏳ 대기 중
- ⏳ Kakao Developers 앱 생성
- ⏳ Native App Key 발급
- ⏳ Native App Key 코드 입력
- ⏳ Release 키 해시 등록
- ⏳ Kakao 로그인 활성화

---

## 📞 문의

Kakao 설정 관련 문의:
- Kakao Developers 고객센터: https://devtalk.kakao.com/

Firebase 연동 문의:
- Firebase 문서: https://firebase.google.com/docs

---

**설정을 완료하고 Native App Key를 입력하면 즉시 Kakao 로그인을 사용할 수 있습니다!** 🎉
