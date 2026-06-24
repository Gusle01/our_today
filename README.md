# 오늘의 우리 (our_today)

> 나를 이해하고(혼자) → 서로를 이해하는(커플) **1일 1질문 리추얼 앱** · Flutter + Riverpod + (Phase 2) Firebase

혼자 쓸 땐 **오늘의 질문 · 칭찬일기 · 감정기록**으로 나를 돌아보고, 연인과 연결하면 **같은 질문에 둘 다 답해야 서로 공개되는 블라인드 리빌**로 매일을 나눕니다.

---

## 📌 현재 상태 (중요)

이 저장소는 **MVP 스캐폴드**입니다.

- ✅ **Clean Architecture + Riverpod** 구조, 12개 화면, 블라인드 리빌 상태머신까지 구현
- ✅ **Mock(인메모리) 모드로 즉시 실행** — Firebase 설정 없이 전체 플로우 데모 가능
- 🔜 **Firebase 연동은 Phase 2** (아래 절차) — `firestore.rules` / `firestore.indexes.json` 은 이미 포함
- ⚠️ 이 코드는 **Flutter SDK 가 없는 환경에서 작성**되어 컴파일 검증을 거치지 않았습니다. 설치 후 **`flutter analyze` 로 한 번 점검**하고 사소한 lint 는 정리하세요.

---

## 🚀 실행 방법

### 0) Flutter 설치
[flutter.dev/get-started](https://docs.flutter.dev/get-started/install) 참고. 설치 확인:
```bash
flutter --version
flutter doctor
```

### 1) 네이티브 플랫폼 폴더 생성
이 저장소에는 `lib/` 소스만 있고 `android/ios/` 는 없습니다. 기존 소스를 유지한 채 플랫폼 스캐폴드를 생성하세요:
```bash
cd our_today
flutter create . --project-name our_today --org com.ourtoday --platforms=android,ios
```
> `flutter create .` 는 기존 `lib/`·`pubspec.yaml` 을 보존하고 누락된 플랫폼 폴더만 추가합니다.

### 2) 의존성 설치 & 실행
```bash
flutter pub get
flutter analyze          # 코드 점검(권장)
flutter run              # 시뮬레이터/디바이스에서 실행 (Mock 모드)
```

### 3) 데모 시나리오
1. 온보딩에서 **Google/Apple로 시작** (Mock 즉시 로그인)
2. 홈 → **오늘의 질문 / 감정 / 칭찬** 작성 → 진행도·캘린더 확인
3. **우리 탭** → "받은 코드 입력"에 아무 코드나 넣고 **연결하기**(가상 연인 연결)
4. 오늘의 질문 **제출** → 🔒 잠금 → **"연인 답변 시뮬레이트(데모)"** 탭 → **공개(REVEALED)** + streak 증가

---

## 🧱 아키텍처

**Feature-first + 3-레이어 Clean Architecture.** 의존성 방향: `presentation → domain ← data` (domain 은 Flutter/Firebase 를 모름).

```
lib/
├─ main.dart / app.dart            # 진입점 · MaterialApp.router
├─ core/                           # config, theme, router, utils, error, widgets
├─ content/question_bank.dart      # 시드 질문 풀 + 결정적 선택
└─ features/
   ├─ auth/    { domain · data(mock) · presentation }   # 온보딩/세션/마이
   ├─ solo/    { ... }   # 질문·감정·칭찬·히스토리(캘린더+감정분포)
   └─ couple/  { ... }   # 연결·블라인드 리빌·우리기록
```

**핵심 패턴**
- Repository 는 **domain 인터페이스** → 기본은 `Mock*Repository`(인메모리), Phase 2 에서 `Firebase*Repository` 로 교체
- Riverpod `StreamProvider` 로 저장소를 구독 → 화면 자동 갱신
- 블라인드 리빌은 `RevealState { none, meOnly, partnerOnly, revealed }` 상태머신으로 표현

---

## 🔥 Firebase 연동 (Phase 2)

1. **FlutterFire 설정**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure        # Firebase 프로젝트 선택 → lib/firebase_options.dart 생성
   ```
   > `firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist` 는 `.gitignore` 처리됨(키 커밋 금지).

2. **패키지 추가** (`pubspec.yaml`)
   ```yaml
   firebase_core: ^3.6.0
   firebase_auth: ^5.3.1
   cloud_firestore: ^5.4.4
   firebase_messaging: ^15.1.3
   ```

3. **초기화** (`lib/main.dart` 의 주석 해제) + `lib/core/config/app_config.dart` 의 `useFirebase = true`

4. **Firebase 저장소 구현** — `data/repositories/firebase_*_repository.dart` 작성 후 provider 교체:
   ```dart
   // 예: auth_providers.dart
   final authRepositoryProvider = Provider<AuthRepository>((ref) =>
     AppConfig.useFirebase ? FirebaseAuthRepository() : MockAuthRepository());
   ```

5. **보안 규칙·인덱스 배포**
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes
   ```
   - `firestore.rules` — **블라인드 리빌 무결성**(내가 제출해야 상대 답 read 허용) 포함
   - `firestore.indexes.json` — 우리기록/질문풀 복합 인덱스

---

## 📚 설계 문서

서비스 분석 → 경쟁 분석 → MVP → 기능명세 → DB → 폴더구조 → 와이어프레임 → 로드맵 전체는 [docs/DESIGN.md](docs/DESIGN.md) 참고.

---

## 🗺️ 로드맵

| 스프린트 | 산출물 |
|---|---|
| **S0 (완료)** | 아키텍처 스캐폴드 · Mock 동작 · 보안규칙 |
| S1 | 인증 + FlutterFire + users 도큐 |
| S2 | 혼자 모드 Firestore 연동 |
| S3 | 커플 모드 + 보안규칙 적용 |
| S4 | FCM 알림 |
| S5 | 계정삭제·내보내기·정책·접근성 |
| S6 | QA · 베타(TestFlight/Play Internal) |

---

## 🛠 기술 스택
Flutter · Riverpod · go_router · (Phase 2) Firebase Auth / Cloud Firestore / FCM
