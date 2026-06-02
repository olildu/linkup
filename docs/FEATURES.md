# Feature Breakdown

This document describes every major feature in Linkup — what it does, which screens and BLoCs are involved, and how data flows from a user action to the screen updating. Each section ends with one notable implementation detail worth knowing.

---

## 1. Authentication

**What it does:** Users log in with their university email and password. A separate OTP-gated flow handles password resets. JWTs (access + refresh) are stored in platform-native secure storage (`FlutterSecureStorage`) and refreshed silently on every expired request.

**Screens:** `LandingPage` → `LoginSignupModalPage` → `LoginPage` / `SignupPage`

**BLoCs:** `AuthBloc`, `LoginBloc`, `OtpBloc`

**Data flow (login):**
```
Tap "Login"
  → AuthBloc receives AuthLoginRequested(email, password)
  → LoginUseCase calls AuthRepository.login()
  → AuthRepositoryImpl calls AuthRemoteDatasource → POST /token
  → Tokens stored via TokenService.saveTokens()
  → AuthBloc emits AuthAuthenticated
  → Navigator pushes LoadingScreenPostLogin
```

**Data flow (password reset):**
```
Enter email → SendOTPUseCase → POST /verify-email
Enter OTP  → VerifyOTPUseCase → POST /verify-otp → emailHash returned
New password → ResetPasswordUseCase → POST /reset-password
```

**Notable:** The `CustomHttpClient` intercepts 401/403 responses anywhere in the app and transparently refreshes the access token using the stored refresh token before retrying the original request — callers never handle token expiry.

---

## 2. Onboarding / Signup Flow

**What it does:** New users complete a multi-step onboarding after initial registration: profile photos, bio, age, location, and lifestyle information. The flow is persisted server-side, so closing the app mid-flow and reopening it returns to the correct step.

**Screens:** `SignupPage` (credentials) → `SignupFlowPage` (multi-step)

**BLoCs:** `AuthBloc` (register), `SignupBloc` (multi-step state), `ProfileBloc` (media upload)

**Data flow (photo upload):**
```
User selects photos from MediaPickerPage
  → ProfileBloc receives ProfileImagesUpdatedEvent
  → For each XFile: UploadUserMediaUseCase → MediaRepository → MediaRemoteDatasource → POST /media/upload
  → First photo: UploadPfpFromUrlUseCase → CDN URL → profile picture pipeline
  → UpdateProfileUseCase → PATCH /user/update with all metadata
  → ProfileBloc emits ProfileLoaded
```

**Notable:** Photo uploads are tracked per-item — `ProfileBloc` emits `ProfileUpdating(current: n, total: total, message: '...')` for each file so the UI can show granular progress. The profile picture is processed separately via `UploadPfpFromUrlUseCase`, which converts the CDN URL into a blurhash-encoded thumbnail stored on the server.

---

## 3. Profile Discovery (Swipe)

**What it does:** Users browse a deck of profiles from their university and swipe right (like) or left (pass). When both users like each other, the server triggers a match event.

**Screens:** `AroundYouPage` (card stack), `MatchedPage` (on mutual match)

**BLoC:** `MatchesBloc`

**Data flow:**
```
AroundYouPage mounts
  → MatchesBloc receives LoadMatchesEvent
  → LoadMatchesUseCase → MatchRepository → MatchRemoteDatasource → GET /match/candidates
  → MatchesBloc emits MatchesLoaded(candidates: [...])

User swipes right on card
  → MatchesBloc receives SwipeEvent(userId, SwipeDirection.right)
  → SwipeUseCase → SwipeRemoteDatasource → POST /match/swipe
  → If server returns match=true: MatchesBloc emits MatchFound(matchUser)
  → Navigator pushes MatchedPage with animation
```

**Notable:** The deck is managed entirely in `MatchesBloc` state — swiped cards are removed from the local list optimistically, so the UI stays responsive without waiting for the server response. When the deck empties, a reload event fires automatically.

---

## 4. Match Celebration

**What it does:** When a mutual match is detected — either via swipe response or WebSocket push — users are taken to a full-screen celebration with confetti, haptic feedback, and a one-tap path into the new chat room.

**Screens:** `MatchedPage`

**BLoCs:** `MatchesBloc` (provides match data), `ChatsBloc` (created on "Start Messaging" tap)

**Data flow:**
```
MatchFound event received
  → MatchedPage pushed with MatchesConnectionEntity
  → ConfettiController fires from both sides
  → Haptics.vibrate(HapticsType.success)

Tap "Start Messaging"
  → StartChatUseCase → ChatRepository → ChatRemoteDatasource → POST /chat/start
  → Server returns chat_room_id
  → ChatsBloc created with chat_room_id, pushReplacement to ChatPage
```

**Notable:** `MatchedPage` is reused for two distinct entry points: the normal swipe-based match (shows "you like each other") and the Meet at 8 timed match (shows "you have been matched", `meet8State: true`). In the Meet at 8 variant, the "Start Messaging" button is hidden — the lobby flow handles that separately.

---

## 5. Real-Time Messaging

**What it does:** Full-duplex chat over WebSocket with typing indicators, seen receipts, image sharing, reply threading, and an offline-first unsent message queue. Messages are cached in Isar so past conversations load instantly without a network round-trip.

**Screens:** `ChatPage`, `FullScreenImagePage` (image viewer)

**BLoCs:** `ChatsBloc` (per chat room), `ChatSocketsBloc` (singleton WebSocket handler)

**Data flow (sending a message):**
```
User types and taps send
  → ChatsBloc receives SendMessageEvent(message)
  → Message added to state optimistically
  → ChatSocketsBloc sends message JSON over WebSocket
  → If socket disconnected: SaveUnsentMessageUseCase → MessageLocalDatasource → Isar
  → On reconnect: ChatSocketsBloc drains unsent queue, sends each, deletes from Isar
```

**Data flow (receiving a message):**
```
WebSocket frame arrives
  → ChatSocketDatasource emits on stream
  → ChatSocketsBloc receives raw JSON, routes to target ChatsBloc
  → ChatsBloc receives NewMessageEvent
  → CacheMessageUseCase → MessageLocalDatasource (Isar, max 200 messages per room)
  → ChatsBloc emits ChatsLoaded with updated message list
  → ChatPage ListView rebuilds
```

**Data flow (loading chat history):**
```
ChatPage mounts
  → ChatsBloc receives StartChatsEvent
  → GetCachedMessagesUseCase → MessageLocalDatasource → Isar (instant)
  → FetchMessagesUseCase → ChatRemoteDatasource → GET /chat/messages
  → ChatsBloc emits ChatsLoaded, merges remote with local
```

**Notable:** The unsent message queue is durable across app restarts. If a message fails to send because the socket was down, it is written to Isar. The next time `ChatSocketsBloc` reconnects, it calls `GetUnsentMessagesUseCase`, replays each message in order, and removes each one via `DeleteUnsentByMessageIdUseCase` as they are acknowledged.

---

## 6. Connections & Chat List

**What it does:** A combined list of all matched users and active conversations, sorted by last activity. Loads from an offline Isar cache first, then syncs from the server in the background so the list is visible immediately even without a network connection.

**Screens:** `ConnectionsPage`

**BLoCs:** `ConnectionsBloc`, `ConnectionsSocketBloc`

**Data flow:**
```
ConnectionsPage mounts
  → ConnectionsBloc receives LoadConnectionsEvent
  → GetCachedConnectionsUseCase → ChatLocalDatasource → Isar (renders immediately)
  → GetConnectionsUseCase → MatchRemoteDatasource → GET /connections (background)
  → CacheConnectionsUseCase → ChatLocalDatasource → Isar (updates cache)
  → ConnectionsBloc emits ConnectionsLoaded with fresh data

New message arrives on WebSocket
  → ConnectionsSocketBloc receives frame
  → ConnectionsBloc receives UpdateConnectionEvent
  → List reorders; unread badge increments
```

**Notable:** Block and report actions are handled entirely within `ConnectionsBloc` — `BlockUserUseCase` and `ReportUserUseCase` call the server and then immediately remove the user from local state without re-fetching the whole list.

---

## 7. Meet at 8 (Lobby)

**What it does:** A time-gated group matching feature. At a specific time window, users can join a lobby and are automatically matched with another user when the lobby fills. The waiting screen is animated to reduce perceived wait time.

**Screens:** `MeetAt8Page`

**BLoC:** `LobbyBloc`

**Data flow:**
```
User enters MeetAt8Page
  → LobbyBloc subscribes to LobbySocketDatasource stream
  → WebSocket connects to /ws/lobby

Match found by server
  → WebSocket frame: {event: "match_found", candidate: {...}}
  → LobbyBloc receives LobbyMatchFoundEvent(candidate: MatchesConnectionEntity)
  → LobbyBloc emits LobbyMatched
  → MeetAt8Page pushes MatchedPage(meet8State: true)
  → MatchedPage shows match celebration without "Start Messaging" button
  → Lobby-specific next steps handled via the lobby's own chat initiation
```

**Notable:** `LobbyBloc` parses the incoming WebSocket JSON into `MatchesConnectionModel` and immediately converts it to a `MatchesConnectionEntity` before emitting state — the presentation layer never touches a raw model.

---

## 8. Profile & Preferences Management

**What it does:** Users can edit their profile (bio, photos, age, location) and configure match filters (interested gender, smoking/drinking preference, religion, relationship intent, living situation). Photos are reorderable and the first photo is automatically set as the profile picture.

**Screens:** `ProfileSettingsPage`, `SetPreferencesPage`, `MediaPickerPage`

**BLoCs:** `ProfileBloc`, `PreferencesBloc`

**Data flow (profile photo update):**
```
User reorders/adds photos in MediaPickerPage
  → ProfileBloc receives ProfileImagesUpdatedEvent(images, changePfp)
  → For each new XFile: UploadUserMediaUseCase → CDN → metadata returned
  → If changePfp: UploadPfpFromUrlUseCase → profile picture pipeline
  → UpdateProfileUseCase → PATCH /user/update with new photo metadata array
  → ProfileBloc emits ProfileLoaded (re-fetches fresh profile)
```

**Data flow (preference update):**
```
User taps an option in SetPreferencesPage
  → PreferencesBloc receives PreferencesUpdateEvent(preference)
  → UpdatePreferenceUseCase → UserRemoteDatasource → POST /user/update/preferences
  → PreferencesBloc triggers PreferencesLoadEvent (re-fetches to confirm)
  → PreferencesBloc emits PreferencesLoaded with updated values
```

**Notable:** Profile pictures go through a two-step pipeline: the full-resolution image is uploaded to the media CDN via `UploadUserMediaUseCase`, then the returned CDN URL is passed to `UploadPfpFromUrlUseCase` which sends it to a separate server endpoint that generates a compact blurhash thumbnail. The blurhash is stored alongside the URL so every place in the app that displays the profile picture can show a smooth blurred placeholder while the full image loads.

---

## 9. Settings & Security

**What it does:** Account management (logout, delete account), biometric app lock using the device's fingerprint/Face ID, and deep links to privacy policy and terms pages.

**Screens:** `SettingsPage`

**BLoCs / Cubits:** `AuthBloc` (logout, delete), `AppLockCubit` (biometric toggle)

**Data flow (logout):**
```
Tap "Logout" → confirmation dialog
  → AuthBloc.logout()
  → LogoutUseCase → AuthRepository.logout()
  → TokenService.clearTokens() (deletes from FlutterSecureStorage)
  → AppLock preference cleared from SharedPreferences
  → Navigator.pushAndRemoveUntil → LoadingScreenPostLogin
```

**Data flow (app lock toggle):**
```
User toggles "App Lock"
  → AppLockCubit.setEnabled(true)
  → BiometricLockService.canUseAppLock() checks device capability
  → If capable: SharedPreferences stores 'app_lock_enabled = true'
  → AppLockCubit emits true
  → On next cold launch: LoadingScreenPostLogin reads pref
    → if enabled: local_auth prompts fingerprint/Face ID before proceeding
```

**Notable:** Account deletion is fully reversible up until the confirmation dialog is accepted — after that, `DeleteAccountUseCase` calls the server, tokens are wiped, the biometric lock preference is removed, and the user is sent back to `LandingPage` with the entire navigation stack cleared. There is no soft-delete recovery from the client side.
