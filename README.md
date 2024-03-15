# profi

A new Flutter project.

## Getting Started

Android Studio:
========================
Run / Debug Configuration:
========================
-> Add New Configuration
-> Flutter
Name: main_dev.dart
Dart entrypoint: {PROJECT_PATH}/lib/main_dev.dart
Additional run args: --flavor dev

-> Add New Configuration
-> Flutter
Name: main_prod.dart
Dart entrypoint: {PROJECT_PATH}/lib/main_prod.dart
Additional run args: --flavor prod

Android / iOS:
===
Run app
===
flutter run --flavor dev lib/main_dev.dart
flutter run --flavor prod lib/main_prod.dart

Android:
===
Build apk
===
flutter build apk --flavor dev -t lib/main_dev.dart
flutter build appbundle --flavor dev -t lib/main_dev.dart

flutter build apk --flavor prod -t lib/main_prod.dart
flutter build appbundle --flavor prod -t lib/main_prod.dart

IOS:
===
Build ipa
===
flutter build ipa --flavor dev --release lib/main_dev.dart 
flutter build ipa --flavor dev --export-method development lib/main_dev.dart

flutter build ipa --flavor prod --release lib/main_prod.dart
flutter build ipa --flavor prod --export-method development lib/main_prod.dart


=======================================================
Obfuscate code:
=======================================================
flutter build apk --flavor prod -t lib/main_prod.dart --split-debug-info --obfuscate
flutter build appbundle --flavor prod -t lib/main_prod.dart --split-debug-info --obfuscate

====================================================================================================
BELOW is required to upload in play console - as we are obfuscating code and to resolve warning:-

-> This App Bundle contains native code, and you've not uploaded debug symbols.
-> We recommend you upload a symbol file to make your crashes and ANRs easier to analyze and debug.

Solution:
Make these zip file by go to build\app\intermediates\merged_native_libs\release\out\lib inside your Flutter project
and compress the folders into symbols.zip, now upload it into the google play console

To upload a deobfuscation or symbolication file:
Open Play Console.
Select an app.
On the left menu, select Release > App bundle explorer.
Using the picker in the top-right-hand corner, choose the relevant artifact.
Select the Downloads tab, and scroll down to the “Assets” section.
Click the upload arrow for the mapping file or the debug symbols as applicable to upload the deobfuscation or symbolication file for the version of your app.
====================================================================================================