# Backend Integration Implementation Plan

This document outlines where each of the provided backend API endpoints will be integrated into the existing Flutter mobile application structure.

## User Review Required

> [!IMPORTANT]  
> The application currently lacks a dedicated Authentication flow (there's only an Onboarding screen that skips straight to `/home`). We need to introduce an Auth feature (Login/Register screens) before the Knowledge Base and Chat screens can function, as they require a protected JWT context.
>
> **Do you approve of adding a new Auth feature folder with Login and Register screens, or do you already have UI assets to use for testing?**

## Proposed Changes

### 1. Authentication (`/api/auth`)
We need to create a new feature layer for authentication to handle these routes.
- **`POST /api/auth/register`**: Registers a new user.
- **`POST /api/auth/login`**: Issues the critical JWT Bearer token.

#### [NEW] `lib/features/auth/presentation/screens/login_screen.dart`
#### [NEW] `lib/features/auth/presentation/screens/register_screen.dart`
#### [NEW] `lib/features/auth/services/auth_service.dart` (using Dio for networking)
#### [MODIFY] `lib/features/onboarding/screens/onboarding_screen.dart`
- Update the `_goToApp()` function to navigate to `/login` instead of `/home`.

---

### 2. Document Ingestion (`/api/upload`)
Integration falls under the existing `knowledge_base` feature.
- **`POST /api/upload/ingestion`**: Uploads PDFs and returns immediate success.
- **`GET /api/upload/`**: Fetches the directory of injected docs.

#### [NEW] `lib/features/knowledge_base/services/document_service.dart` 
- Handles multipart/form-data PDF uploading using Dio.
#### [MODIFY] `lib/features/knowledge_base/presentation/widgets/upload_dropzone.dart`
- Connect file picker logic to the ingestion API.
#### [MODIFY] `lib/features/knowledge_base/presentation/screens/knowledge_hub_screen.dart`
- Fetch and display user documents using the `GET` route on load.

---

### 3. Intelligent Chat (`/api/chat`)
Integration falls under the existing `chat` feature.
- **`POST /api/chat/`**: Sends queries to retrieve context and LLaMA response.
- **`GET /api/chat/`**: Fetches the chat history chronologically.

#### [NEW] `lib/features/chat/services/chat_service.dart`
#### [MODIFY] `lib/features/chat/presentation/screens/chat_screen.dart`
- Connect to `GET /api/chat/` on initialization to seed the historical chat.
#### [MODIFY] `lib/features/chat/presentation/widgets/message_bubble.dart` (or input footer)
- Hook up the text submit action to `POST /api/chat/` to stream/fetch bot responses.

---

### 4. Summary (`api/upload/summary`)
Integration falls under the existing `summary` feature.
- **`GET api/upload/summary`**: Fetches generated summary and TL;DR. *(Assuming this expects a document ID query param)*

#### [NEW] `lib/features/summary/services/summary_service.dart`
#### [MODIFY] `lib/features/summary/presentation/screens/summary_screen.dart`
#### [MODIFY] `lib/features/summary/presentation/widgets/tldr_card.dart`
- Hydrate UI components dynamically from the backend response instead of hardcoded data.

---

### 5. Network Core Layer
To handle shared authentication headers and base paths easily.
#### [NEW] `lib/core/network/dio_client.dart`
- Configure `Dio` with a `BaseOptions` and an intercepter that retrieves the JWT from `SharedPreferences` and injects the `Authorization: Bearer <token>` header dynamically.

## Open Questions

> [!WARNING]  
> 1. What is the base URL pattern for the API endpoints? (e.g. `http://10.0.2.2:3000` via Android emulator or a production domain?).
> 2. Does the `GET api/upload/summary` endpoint expect a `docId` as a query parameter or path variable?
> 3. For state management, I noticed `flutter_riverpod` in the dependencies. Should we implement the features strictly using Riverpod providers?

## Verification Plan
### Automated Tests
* None planned at this stage. Custom validation testing using emulator and console prints.

### Manual Verification
1. I will boot up the Flutter app, test the registration and login sequence to verify the token is mapped locally.
2. I will test a PDF upload and visualize it in the Knowledge Hub.
3. I will navigate to Chat, ask a question, and ensure the UI parses the AI response correctly.
