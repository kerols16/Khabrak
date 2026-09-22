# Khabark

A simple news reader app built with Flutter. It shows top headlines from
[NewsAPI](https://newsapi.org), lets you search and filter by category, and
uses Firebase Authentication (Email/Password and Google Sign-In).

> Built for the Eyego Flutter Internship technical task.

## Demo

- Demo video: `<ADD VIDEO LINK>`

|                                                         Onboarding                                                         |                                                         Sign in                                                         |                                                         Home                                                         |                                                         Article                                                         |
| :------------------------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------: |
| <img src="https://github.com/user-attachments/assets/17c1af7d-b18d-4c0e-95eb-1436b0b03165" width="200" alt="Onboarding" /> | <img src="https://github.com/user-attachments/assets/63964c46-9fc2-4afb-b1c7-1423487d204e" width="200" alt="Sign in" /> | <img src="https://github.com/user-attachments/assets/287c28b6-ef2e-4899-a6dd-4ae24753b560" width="200" alt="Home" /> | <img src="https://github.com/user-attachments/assets/d7144d2e-48ef-4127-888a-68c8af6b5e45" width="200" alt="Article" /> |

## What the app does

- **Onboarding** screen shown only on the first launch.
- **Sign up / Sign in** with Email and Password, or **Google Sign-In**.
- **Forgot password** email.
- **Top headlines** from NewsAPI (US), loaded 20 at a time with infinite scroll.
- **Category filter:** general, business, technology, sports, science, health, entertainment.
- **Search** with a 500 ms debounce (minimum 2 characters).
- **Pull to refresh.**
- **Article details** page with a button to open the full story in the browser, and a share button.
- **Profile** page with the user info, sign-in method and log out.
- **Loading, error and empty states** (shimmer placeholders, retry button, "no results" view).
- **Responsive layout:** 1 column on phones, 2 on tablets, 3 on large screens.

## Tech stack

| Purpose | Package |
|---|---|
| State management | `flutter_bloc` (Cubit) + `equatable` |
| Networking | `dio` + `retrofit` (code generated) |
| Authentication | `firebase_core`, `firebase_auth`, `google_sign_in` |
| Local storage | `shared_preferences` (onboarding flag only) |
| UI helpers | `google_fonts`, `cached_network_image`, `shimmer`, `flutter_svg` |
| Other | `intl`, `share_plus`, `url_launcher` |

Exact versions are in `pubspec.yaml`.

## How to run

### 1. Requirements

- Flutter (stable, Dart SDK `^3.12.2`) - tested with Flutter `<ADD VERSION>`
- Android Studio or VS Code
- An Android device or emulator (with Google Play if you want to test Google Sign-In)

### 2. Get the code

```bash
git clone <ADD REPO URL>
cd khabark
flutter pub get
```

### 3. Add your NewsAPI key

1. Create a free key at [newsapi.org](https://newsapi.org).
2. Copy the example file and put your key in it:

```bash
cp env.example.json env.json
```

```json
{
  "NEWS_API_KEY": "your-newsapi-key",
  "GOOGLE_SERVER_CLIENT_ID": "your-web-client-id"
}
```

`env.json` is git-ignored, so your keys are never committed.
`GOOGLE_SERVER_CLIENT_ID` is only needed for Google Sign-In (see below).

### 4. Run

```bash
flutter run --dart-define-from-file=env.json
```

If you change `env.json`, stop the app and run it again. Hot reload does not
read new values.

> The generated file `news_api_service.g.dart` is already in the repo. Only if
> you edit the API interface, regenerate it with
> `dart run build_runner build --delete-conflicting-outputs`.

## Firebase setup

The project uses Firebase project `<ADD PROJECT NAME>` and the Android
application id `<ADD APPLICATION ID, e.g. com.kerols.khabark>`.

**Option A - quick test:** Email/Password sign-in works with the included
Firebase config. Google Sign-In only works with the signing key registered in
this Firebase project, so a reviewer's machine will not work with it.

**Option B - use your own Firebase project (needed for Google Sign-In):**

1. Create a Firebase project and add an Android app with the same application id
   (or change `applicationId` in `android/app/build.gradle.kts` to yours).
2. In **Authentication > Sign-in method**, enable **Email/Password** and **Google**
   (set a support email).
3. Get your debug SHA-1 and SHA-256:
```bash
   cd android
   ./gradlew signingReport
```
   Add both in **Project settings > Your apps > SHA certificate fingerprints**.
4. Download the new `google-services.json` into `android/app/`.
5. Run `flutterfire configure` to regenerate `lib/firebase_options.dart`.
6. Copy the **Web client ID** (Authentication > Sign-in method > Google >
   Web SDK configuration) into `GOOGLE_SERVER_CLIENT_ID` in `env.json`.

Google Sign-In is tested on **Android** only. It is not supported on web in
this project.

## Project structure

lib/
main.dart Starts Firebase, reads the onboarding flag, runs the app
firebase_options.dart Generated by flutterfire configure
core/ Shared code
api_data_source/ Dio client, Retrofit API, JSON models
constants/ API constants, spacing
theme/ Colors, text styles, ThemeData (light theme only)
utils/ Responsive helper, "time ago" formatter
widgets/ Reusable widgets (button, text field, chips, views)
features/
auth/ AuthCubit + Auth and Profile screens/pages
news/ NewsCubit, repository, feed and article screens/pages
entry_point/ AppGate (which screen to show) and MainShell (bottom nav)


Each feature is split like this:

- `cubit/` - state and logic
- `data/` - repository and data classes (news only)
- `presentation/screens/` - pure UI. Screens get data and callbacks through
  their constructor and know nothing about the Cubit.
- `presentation/pages/` - thin widgets that connect a Cubit to a Screen and
  handle navigation, sharing and opening links.
- `presentation/widgets/` - smaller UI pieces used by the screens.

## Architecture

News data flow:

NewsAPI
-> NewsApiService (Retrofit + Dio)
-> NewsRepository (cleans the data, maps errors)
-> NewsCubit (state, search, pagination)
-> HomePage (connects Cubit to UI)
-> HomeScreen -> FeaturedCard / ArticleCard


Auth data flow:

Firebase / Google
-> AuthCubit (listens to authStateChanges)
-> AuthPage / ProfilePage
-> AuthScreen / ProfileScreen


Which screen opens first is decided in one place, `AppGate`:

- Firebase has not answered yet -> loading spinner
- Signed in -> `MainShell` (Home + Profile tabs)
- Signed out, onboarding not seen -> Onboarding
- Signed out, onboarding seen -> Sign in

`NewsCubit` is created only for signed-in users, so after log out and log in
again the feed starts fresh.

## Implementation approach

**Why Cubit?** The state changes through simple method calls
(`categoryChanged`, `searchChanged`, `nextPageRequested`), so I did not need
separate Events. It is still part of `flutter_bloc`.

**Why a Repository for news?** The API returns messy data, so the
repository cleans it before it reaches the Cubit. It removes articles that are
`[Removed]`, have no URL or no date, point to cookie-consent pages, have neither
description nor image, or appear twice. It also removes the publisher name that
NewsAPI adds at the end of titles (for example "Headline - BBC News"), and it
turns network errors into short user-friendly messages.
Auth has no repository because `AuthCubit` only makes direct Firebase calls.

**Pagination.** The Cubit loads 20 articles per page. The free NewsAPI plan
only returns the first 100 results, so `hasReachedMax` is calculated from the
raw API response (not from the cleaned list) to stop asking for more pages at
the right time.

**Search.** The Cubit waits 500 ms after the last keystroke before calling the
API, which saves requests on the limited free plan.

**Stale responses.** Every new first-page request increases a counter. When a
response arrives, the Cubit checks that it still matches the current counter,
category and query. If not, it ignores it. This stops an old response from
overwriting the list after the user changes category or search.

**Auth.** `authStateChanges()` is the single source of truth. After a
successful sign in, the Cubit does not emit "signed in" itself; it waits for
Firebase to report the user. If the user closes the Google account picker,
that is not treated as an error.

**Secrets.** The NewsAPI key is read with `String.fromEnvironment`, passed with
`--dart-define-from-file`, and sent in the `X-Api-Key` header. It is not
stored in the code.

## Problems I ran into

1. **401 from NewsAPI.** The key was empty because I forgot
   `--dart-define-from-file=env.json`. I added an `assert` in `main.dart`
   that tells me to use the flag.
2. **News cards did not appear (`RenderFlex ... unbounded height`).** The card
   used `Expanded` inside a `Column`, and items in a `SliverList` have unbounded
   height. I replaced it with `AspectRatio(16 / 9)` and `mainAxisSize: min`.
3. **Google Sign-In showed only "Something went wrong".** The generic message
   was hiding the real error. I added step-by-step logs and found two causes:
   Google Sign-In on Android needs a `serverClientId`, and the SHA-1 was
   registered under a different package name than the app was using. I fixed
   both, then removed the debug logs.

## Known limits

- NewsAPI free plan: only the first 100 results per query, and a daily request limit.
- Headlines are always from the US (`country = us`).
- Google Sign-In is Android only and needs the reviewer's SHA-1 in their own Firebase project.
- Light theme only.
- No automated tests yet.