# safety_check

엘림주식회사 안전진단 업무용 모바일앱

# 전체 소통 구조

[View]
↓
[Controller]
↓
[Service]
↓
[AppRepository]
↓
[AppRestAPI] / [LocalDataService]

# 폴더 구조

constant : 앱 전체에서 자주 재사용되는 값들(상수, 설정, 스타일 등)을 한 곳에 모아서 관리하는 폴더

data - api - app_api.dart : Dio 기반의 HTTP 클라이언트를 설정하고, 서버와의 통신, 쿠키 관리, 세션 유지, 인터셉터 구성 등을 담당하는 API 요청 엔진 서비스

data - api - app_rest_api.dart : AppRestAPI(client)를 통해 실제 HTTP 요청. Dio + Retrofit 기반으로, 서버의 REST API 엔드포인트들을 메서드 형태로 정의하는 API 인터페이스 클래스야. 이 파일은 자동 생성된 코드(app_rest_api.g.dart)와 연결되어 실제 HTTP 요청을 실행할 수 있게 해준다.

data - models : 데이터 구조(모델 클래스)를 정의하는 공간으로 서버 응답, 로컬 저장, UI 바인딩 등 다양한 곳에서 데이터를 구조화된 형태로 안전하게 관리할 수 있게 도와준다.

data - repository - app_repository.dart : API 통신, 로컬 데이터 접근 등 데이터 소스와의 중계 역할을 담당하며, 상위 계층인 Service나 Controller가 데이터 출처에 의존하지 않고 비즈니스 로직을 수행할 수 있도록 추상화해주는 계층. 실제 데이터를 가져오는 건 API 또는 Hive인데 그 중간에서 추상화된 메서드를 제공하는 게 Repository이다.

services - app_service.dart : 앱 전역에서 사용되는 핵심 서비스 클래스입니다. 로그인, 로그아웃, 프로젝트/도면 관리, 결함 처리, 오프라인 모드 전환 등과 같은 주요 비즈니스 로직을 담당하며, 앱 상태를 중앙에서 관리합니다. AppRepository, LocalAppDataService, LocalGalleryDataService 등과 협력하여 서버 및 로컬 데이터를 통합적으로 다루며, 사용자 인터랙션의 결과를 기반으로 앱의 흐름을 제어하는 컨트롤 타워 역할을 수행합니다.

┌────────────┐
│ AppService │ ← 비즈니스 로직 (로그인, 업로드 등)
└──────┬─────┘
↓
┌────────────────────┐
│ LocalAppDataService│ ← 로컬 데이터 접근 추상화 (캐시 역할)
└──────┬─────────────┘
↓
┌────────────┐
│ Hive │ ← 로컬 NoSQL DB (Key-Value)
└────────────┘

services - local_app_data_service.dart : 로그인 유저 정보, 프로젝트 목록, 마커, 결함, 설정값 등 다양한 데이터를 로컬 DB(Hive)에 저장하여, 오프라인 모드에서도 원활하게 앱을 사용할 수 있도록 지원합니다. Hive Box를 각 데이터 타입별로 분리하여 관리하며, 앱 구동 시 `onInit()`에서 Hive를 초기화하고 필요한 Adapter를 등록합니다. AppService 또는 Controller에서 이 서비스를 통해 로컬 데이터를 읽고 쓰게 되며, 특히 오프라인 로그인, 자동 로그인, 프로젝트 캐시, 상태 복원 등에 중요한 역할을 합니다.

AppService는 비즈니스 로직과 앱 전역 상태 관리
AppRepository는 데이터 소스와 직접 통신하는 역할

# 네비게이션

Get.toNamed('/home') 현재 페이지 위에 새로운 페이지 push
Get.offNamed('/home') 현재 페이지 pop하고 새로운 페이지 push
Get.offAllNamed('/home') 모든 페이지 제거하고 새로운 페이지 push
Get.back() 이전 페이지로 pop

# 깃풀받고 할것

1. org.gradle.java.home=C:\\Program Files\\Java\\jdk-17 -> 이거 주석 처리

아디: test@eleng.co.kr
비번: test12345

# 사진이 업로드 되는 프로세스를 살펴보자

1. 왼쪽 바에서 카메라 클릭(await appService.cameraSelected();)하면 이함수 실행됨
2. ImagePicker 라이브러리가 발동되어 사진 찍을 수 있음
3. String savedFilePath = await savePhotoToExternal(File(file.path)); 가 호출됨
4. 기기에 저장된 사진의 주소가 나옴.
5. makeNewPicture()가 호출됨. 앱 안에있는 사진을 hive로컬 저장소에 저장함.
6. loadGalleryFromHive 해서 파일을 하이브에서 불러옴.
7. 이제 업로드 버튼을 누르면 FileUploadMenuItem 클래스의 onTapSendDataToServer가 실행됨(서버로 데이터 전송버튼)
8. element.state가 DataState.NEW, EDITED, DELETED 상태인 사진만 골라냄
9. 새로 추가된 사진은 appService에서 Future<int> uploadPicture가 실행됨.
10. 하이브 로컬저장소에서 state가 New인 사진을 뽑아서 그거를 \_appRepository.uploadPicture로 보냄.
11. 성공적으로 업로드하면 응답을 받음.
    {seq: 2821, project_seq: 217, drawing_seq: null, fault_seq: null, file_path: http://dev.eleng.co.kr/data/safety/2025/217/pictures/4fd71ce35117984e7cafef16e55bd73b.jpg?t=1746672275, file_name: scaled_c7b282d2-fc66-42e3-b0f3-4d6c6c38bd961645195, file_size: 308143, thumb: http://dev.eleng.co.kr/data/safety/2025/217/pictures/4fd71ce35117984e7cafef16e55bd73b_thumb.jpg?t=1746672275, no: 1072, kind: 기타, pid: 20250508112807901471, fid: null, before_picture: null, location: , cate1_seq: null, cate2_seq: null, cate1_name: null, cate2_name: null, width: null, length: null, dong: null, floor: null, floor_name: null, reg_time: 2025-05-08 11:44:35, update_time: 2025-05-08 11:44:35, state: 3}

12. 해당사진의 state를 DataState.NOT_CHANGED.index로 바꿈.

# 현장점검표에서 사진이 업로드 되는 순서

1. 드롭다운 버튼에서 사진찍기를 누름
2. takePictureAndSet 발동.
3. CustomPicture? newImage = await \_takePicture(cate, child, pic); 발동. 리턴값으로
   // {seq: null, project_seq: 3, drawing_seq: null,
   //fault_seq: null,
   //file_path: /storage/emulated/0/Pictures/Elim/Safety/scaled_62c44a77-9a06-4e0d-b8a3-32dd78f44c0b5946246287640078804.jpg,
   //file_name: null, file_size: null,
   //thumb: /storage/emulated/0/Pictures/Elim/Safety/scaled_62c44a77-9a06-4e0d-b8a3-32dd78f44c0b5946246287640078804.jpg,
   //no: null, kind: 현황, pid: 20250508145446344605, fid: null,
   //before_picture: null, location: null, cate1_seq: null,
   //cate2_seq: null, cate1_name: null, cate2_name: null, width: null,
   //length: null, dong: 외벽마감재 치장벽돌 좌측, floor: null, floor_name: null,
   //reg_time: null, update_time: null, state: 0}
4. 그다음에 대,중,소 분류가 들어가서 \_updatePictureInForm 실행됨.
   bool isUpdated = await \_updatePictureInForm(
   form: form, // 현재 프로젝트의 site_check_form
   category: cate, // 대분류
   childKind: child, // 중분류
   pictureTitle: pic, // 소분류
   newPicture: newImage, // 찍힌 사진의 정보
   );

5. appService.curProject?.value.site_check_form에 업데이트가 됨.
   // {inspectorName: ㅇㅓㅑㅓㅑㅑㅓㅕㅕㅕ, inspectionDate: 2025-04-05, memo: null,
   //opinion: null, data: [{caption: 외벽마감재, remark: null,
   //children: [{kind: 치장벽돌, pictures: [{title: 정면, pid: 20250430144941154342,
   //remark: ㅎㅎ}, {title: 정면3, pid: 20250430145608953788, remark: },
   //{title: 정면4, pid: 20250430145613509684, remark: },
   //{title: 정면4, pid: 20250430155023314761, remark: },
   // remark: ...}]}

6. curProject.refresh(); 로 화면을 고침.

# 업로드 버튼에 빨강불이 나오는 조건

# 현장점검표에서 사진을 pid로 가져오는 방식이 빵꾸나는 이유

1-1. 안전관리 앱에 사람1이 접속한다.

1-2. 안전관리 앱에 사람2가 접속한다.

2. 2가 새로 찍은 사진을 업로드 한다.

3. 업로드 버튼을 누르면 서버에서 fetch된다.

4. 사진이 hive와 서버에 동시에 업로드 된다.

5. 2의 탭에 사진을 hive에서 가져와서 보여준다.

6. 1이 같은 프로젝트를 연다.

7. 사진을 가져오는 과정은 업로드 또는 처음접속했을 때만 서버에서 fetch되므로 사진이 뜨지 않는다.

방법1: 사진을 저장할 때 thumbnail을 같이 저장한다.
방법2: 프로젝트를 열때마다 fetch를 실행시킨다.

# apk 파일을 줘서 배포하기

1. flutter clean
   flutter pub get
   flutter build apk --release

2. apk파일 경로:
   build/app/outputs/flutter-apk/app-release.apk

3. 확장자를 .apk.txt로 바꿈

# 빌드폴더 지우고 깨끗한 마음으로 다시 빌드해서 release 파일 전달하고 싶은데 뭐부터 해야돼? - window

기존 빌드 파일 정리
flutter clean
Remove-Item -Recurse -Force build
Remove-Item -Recurse -Force .dart_tool
Remove-Item -Recurse -Force .flutter-plugins
Remove-Item -Recurse -Force .flutter-plugins-dependencies

의존성 패키지 다시 받기
flutter pub get

릴리즈 APK 생성
flutter build apk --release

빌드가 완료되면 다음 경로에서 APK 파일을 찾을 수 있습니다:
build/app/outputs/flutter-apk/app-release.apk

# 패키지 충돌 알람뜨지 않게 키스토어 쓰는 방법

1. 키스토어 만들기
   keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias

2. 앱 밑으로 옮기기
   your_flutter_project/
   └── android/
   └── app/
   └── my-release-key.jks ← 여기에 두기

3. android/key.properties 파일 만들기
   아래 내용 추가
   storePassword=여기에*스토어*비밀번호
   keyPassword=여기에*키*비밀번호
   keyAlias=my-key-alias
   storeFile=app/my-release-key.jks

4. 아래 블록 추가해야됨
   첫번째
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file("key.properties")
   if (keystorePropertiesFile.exists()) {
   keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }

두번째
signingConfigs {
release {
keyAlias keystoreProperties['keyAlias']
keyPassword keystoreProperties['keyPassword']
storeFile file(keystoreProperties['storeFile'])
storePassword keystoreProperties['storePassword']
}
}

세번째
signingConfig = signingConfigs.release

전체파일 :
app/build.gradle

plugins {
id "com.android.application"
id "kotlin-android"
// The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
id "dev.flutter.flutter-gradle-plugin"
}

def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
namespace = "com.elim.safety_check"
compileSdk = flutter.compileSdkVersion
ndkVersion = "27.0.12077973" // flutter.ndkVersion 대신 직접 버전 지정

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.elim.safety_check"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            // signingConfig = signingConfigs.debug
            signingConfig = signingConfigs.release
        }
    }

}

flutter {
source = "../.."
}

5. APK 릴리즈 빌드

flutter clean
flutter pub get
flutter build apk --release

빌드가 끝나면 이 파일이 생성돼요:
build/app/outputs/flutter-apk/app-release.apk

→ 이 파일이 정식 서명된 APK야.
→ 이제 테블릿에 기존 앱을 삭제하지 않고도 업데이트 설치 가능해요!
.gitignore에 이 두 줄 추가해서 절대 Git에 올라가지 않게 해줘:
android/key.properties
android/app/my-release-key.jks

================================ 배포시 ================================

1. pubspect.yaml 버전 바꾸기.
2. .env에서 ENVIRONMENT 옵션 바꾸기.

flutter clean
flutter pub get
flutter build apk --release

3. 각각 flutter build apk --release 하기.

빌드가 끝나면 이 파일이 생성돼요:
build/app/outputs/flutter-apk/app-release.apk
