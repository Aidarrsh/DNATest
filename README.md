# DNATest — Auth Flow

This project implements login via **Google** or **Apple**, authenticates with **Firebase**, exchanges the idToken with **CourtAI** backend via JSON‑RPC, stores the access token securely, and opens the main UI.

---

## 🔧 How to Run

1. Install dependencies via Swift Package Manager or CocoaPods (e.g. `FirebaseAuth`, `GoogleSignIn`).
2. Add your `GoogleService-Info.plist` to the project and target.
3. Configure Firebase with `FirebaseApp.configure()` in `AppDelegate`.
4. Run the app on a real device or simulator with iCloud signed in (for Apple login).

---

## 🔥 Firebase Setup

- Create a Firebase project.
- Register your iOS app (use exact Bundle ID).
- Enable **Authentication** → activate **Google** and **Apple** providers.
- Download `GoogleService-Info.plist` and include it in your Xcode project.

---

## 🧱 Architecture Notes

- MVVM pattern: `LoginViewController` delegates logic to `AuthViewModel`.
- CourtAI backend uses JSON-RPC — wrapped in a thin API client using `URLSession`.
- Tokens are saved securely in Keychain via `TokenStore` protocol.
- Authentication state is observable and logs are emitted via `os.Logger`.
