# Activity 13: Firebase Authentication Lab

A Flutter application demonstrating secure email and password authentication using Firebase. This project routes users based on their authentication state, protecting private screens and managing identity through a centralized authentication service.

## Implemented Features

* **Firebase Email/Password Authentication:** End-to-end registration, sign-in, and sign-out flows.
* **Auth-State Routing (`AuthGate`):** Automatically directs authenticated users to their protected profile and unauthenticated users to the sign-in screen.
* **Protected Profile Screen:** Displays the currently signed-in user's email address and restricts access from signed-out users.
* **Password Management:** In-app password update functionality, including masked inputs and success confirmation.
* **Client-Side Validation:** Immediate UI feedback for invalid email formats and short passwords (under 6 characters) before making network requests.
* **Safe Error Handling:** Catching Firebase exceptions and translating them into user-friendly UI feedback and loading states.

## Prerequisites

* Flutter SDK (Current Stable Channel)
* Dart SDK
* Firebase CLI installed and logged in (`firebase login`)
* FlutterFire CLI installed (`dart pub global activate flutterfire_cli`)
* Google Chrome for running the web app, and/or an Android emulator or physical Android device.

## Required Firebase Configuration & Setup

To run this project locally, you must connect it to your own Firebase project, as private configuration files and credentials are intentionally excluded from version control.

1. **Create a Firebase Project:**
* Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
* Navigate to **Authentication** > **Sign-in method** and enable the **Email/Password** provider.


2. **Configure FlutterFire:**
* Open your terminal in the root directory of this Flutter project.
* Run the following command to link the app to your Firebase project:
```bash
flutterfire configure --platforms=android,web

```


* Select your Firebase project and the **Android** and **Web** platforms.
* This will generate `lib/firebase_options.dart` and the Android configuration file (`android/app/google-services.json`).


3. **Install Dependencies:**
* Fetch the required Flutter packages:
```bash
flutter pub get

```





*Note: The generated Firebase configuration files and any service-account credentials are excluded from version control. Never commit service-account credentials to a public repository.*

## Run the App

After configuring Firebase and installing dependencies, run the web app in Chrome:

```bash
flutter run -d chrome
```

To run on a connected Android device or emulator:

```bash
flutter run
```

To build a release APK:

```bash
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

## Test the App

**Recommended test flow:**
* **Validation:** Attempt to sign in with an invalid email format and a password under 6 characters to verify client-side validation errors.
* **Registration:** Create a new account with a valid email and password. Verify the app routes you to the Protected Profile.
* **Profile Access:** Confirm the profile screen correctly displays the registered email address.
* **Sign Out & Routing:** Click sign out and verify the app immediately routes back to the authentication screen.
* **Sign In:** Log back in with the newly created credentials.
* **Password Update:** Update the password from the profile screen. Sign out, verify the old password fails, and confirm the new password grants access.