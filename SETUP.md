# NetMap Yemen – setup

1. `flutter create . --org com.yourcompany --project-name netmap_yemen` (generates android/ios folders), then keep the files in lib/, assets/, pubspec.yaml.
2. `dart pub global activate flutterfire_cli && flutterfire configure` (or drop google-services.json into android/app/ and GoogleService-Info.plist into ios/Runner/).
3. Deploy `firebase/firestore.rules` (Firebase console > Firestore > Rules). Enable Email/Password in Authentication.
4. Android
   - android/app/build.gradle: `minSdkVersion 23`
   - AndroidManifest.xml (inside <application>):
     `<meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_MAPS_KEY"/>`
   - AndroidManifest.xml (before <application>):
     `<uses-permission android:name="android.permission.INTERNET"/>`
     `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>`
     `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>`
   - Add `<queries><intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent></queries>` for url_launcher.
5. iOS: Info.plist `NSLocationWhenInUseUsageDescription`; AppDelegate: `GMSServices.provideAPIKey("YOUR_MAPS_KEY")`.
6. Icons: `flutter pub get && dart run flutter_launcher_icons`
7. `flutter build apk --release`
