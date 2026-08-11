# DSD SWIMS Staff iOS

DSD SWIMS Staff is an iOS application for supporting DSD staff operations,
including attendance management, safety inspections, site diaries
and incident reporting.

> This document is for developers and testers. Do not commit login credentials, access tokens, provisioning profiles or other secrets to this repository.

## Features

- User login and session management
- Home dashboard and quick action 
- SWAC management
- Working team member and safety vetting workflows
- CSWR approval, endorsement and rejection workflows
- Staff attendance sign-in and sign-out
- Attendance records and member attendance history
- Site diary creation and management
- Safety inspection checklists creation
- Incident report submission and management
- Push notifications
- QR code scanning for attendance
- Access-code inspection
- Photo and file attachments
- Language selection

## Technology Stack

- Swift 5.0
- SwiftUI
- Swift Concurrency (`async/await`)
- URLSession-based API layer
- Firebase Messaging for push notifications
- Swift Package Manager
- CodeScanner for QR code scanning
- Localize-Swift for localization
- SwiftfulRouting for navigation

## Requirements

- macOS with Xcode installed
- Xcode `26.0.1`
- iOS 17.0 or later (DEV); UAT and PROD require iOS 17.6 or later
- Apple Developer account and the required signing credentials
- A physical iPhone for reliable testing of push notifications, camera scanning and GPS attendance

## Getting Started

1. Clone the repository:

   ```bash
   git clone https://github.com/emit-dsd/dsd-swac-staff-ios.git
   cd dsd-swac-staff-ios
   ```

2. Open `dsd-swacs-staff.xcodeproj` in Xcode.

3. Select the required scheme and build target:

   - `dsd-swacs-staff DEV` for development
   - `dsd-swacs-staff UAT` for user acceptance testing
   - `dsd-swacs-staff Prod` for production

4. Select an iOS Simulator or a connected iPhone.

5. Build and run the application in Xcode.

## Project Structure

```text
dsd-swacs-staff/
├── API/                    # API paths, requests and response models
├── Config/                 # Environment configuration
├── Features/               # Feature modules
│   ├── Attendance/
│   ├── Home/
│   ├── IncidentReport/
│   ├── Login/
│   ├── Notifaction/            # Notification feature
│   ├── SafetyInspection/
│   ├── Scan/
│   ├── Setting/
│   ├── SiteDiary/
│   └── SWAC/
├── Network/                # Networking and authentication
├── Resources/              # Assets and fonts
├── Shared/                 # Reusable components and utilities
└── SupportingFiles/        # Info.plist and entitlements
```

## Environments

Select the matching shared scheme in Xcode. The scheme controls the bundle identifier, Firebase configuration and compilation condition.

| Environment | Scheme | Bundle ID | API base URL | Minimum iOS |
| --- | --- | --- | --- | --- |
| DEV | `dsd-swacs-staff DEV` | `com.dsd.swacs.staff.dev` | `https://swac.dsd.gov.hk/mobile-t` | 17.6 |
| UAT | `dsd-swacs-staff UAT` | `hksarg.dsd.swacs.staff.uat` | `https://swac.dsd.gov.hk/mobile-t` | 17.6 |
| PROD | `dsd-swacs-staff Prod` | `hksarg.dsd.swacs.staff` | `https://swac.dsd.gov.hk/mobile` | 17.6 |



## Push Notifications

Push notifications are implemented using Firebase Cloud Messaging and Apple
Push Notification service. The selected environment requires the matching
Firebase configuration and APNs-enabled signing setup.

Firebase files are stored in the following environment-specific folders:

```text
dsd-swacs-staff/Config/DEV/GoogleService-Info.plist
dsd-swacs-staff/Config/UAT/GoogleService-Info.plist
dsd-swacs-staff/Config/PROD/GoogleService-Info.plist
```

DEV and UAT intentionally share the test API host. Verify the selected scheme before testing or distributing the app.


## Run the App

1. Open `dsd-swacs-staff.xcodeproj` in Xcode.
2. Select one of the shared schemes listed above.
3. Select an iPhone Simulator or a connected physical iPhone.
4. Check the signing team and provisioning profile for a physical device.
5. Build and run with **Product > Run**.

For command-line inspection of available schemes:

```bash
xcodebuild -project dsd-swacs-staff.xcodeproj -list
```

Use the DEV or UAT scheme for normal development and testing. Use the Prod scheme only when production access and release signing have been confirmed.


## Permissions

The app requires the following permissions depending on the flow being tested:

- **Camera:** scan worker QR codes
- **Photo Library:** select an image for QR code scanning
- **Location While In Use:** show the current position and perform attendance sign-in/sign-out
- **Push Notifications:** receive notification alerts and update badges

If a permission was previously denied, enable it in **Settings > Privacy & Security** on the test device before retrying.

## Authentication and Session

Staff login uses `/api/Home/StaffLogin`. After a successful login, the app stores the authenticated session and registers the Firebase Cloud Messaging token. The selected language is synchronized with the backend.

Access-code inspection and staff attendance sign-in/sign-out use `/api/Home/InspectAccessCode`, `/api/Attendance/staff/SignIn`, and `/api/Attendance/staff/SignOut`.

Logging out clears the local session and deregisters the mobile notification token where supported.

## API Areas

The main API groups used by this app are:

| Area | Example endpoints |
| --- | --- |
| Authentication | `/api/Home/StaffLogin`, `/api/Home/SetLanguage` |
| Access code / Release notes | `/api/Home/InspectAccessCode`, `/api/Home/GetReleaseNotes` |
| SWAC | `/api/SWAC/List`, `/api/SWAC/Search`, `/api/SWAC/Profile` |
| SWAC staff / approval / safety vetting | `/api/SWAC/WorkingTeamMember`, `/api/SWAC/GetApproverByRCC`, `/api/SWAC/SafetyVetting`, `/api/SWAC/PassSafetyVetting`, `/api/SWAC/FailSafetyVetting` |
| Site Diary | `/api/Report/SiteDiary`, `/api/Report/SiteDiary/List`, `/api/Report/DocumentContent` |
| Safety Inspection | `/api/Report/SafetyInspection/List`, `/api/Report/SafetyInspection/Format`, `/api/Report/OpenSafetyInspection`, `/api/Report/CloseSafetyInspection` |
| Incident Report | `/api/Report/Incident`, `/api/Report/Incident/List` |
| Staff Attendance | `/api/Attendance/staff/SignIn`, `/api/Attendance/staff/SignOut`, `/api/Attendance/List`, `/api/Attendance/Member` |
| Notifications | `/api/Notification/List`, `/api/Notification/UnreadCount`, `/api/Notification/MarkRead` |
| CSWR | `/api/CSWR/GetApprovalList`, `/api/CSWR/GetEndorsementList`, `/api/CSWR/GetRejectList`, `/api/CSWR/ApproveEntry`, `/api/CSWR/EndorseRegistration`, `/api/CSWR/RejectEntry` |
| Push token | `/api/Home/RegisterMobileToken`, `/api/Home/DeregisterMobileToken` |

The complete endpoint list is maintained in `dsd-swacs-staff/API/APIPath.swift`.


## Localization

The supported languages are:

- English
- Traditional Chinese

## Build and Archive

Each shared scheme uses `Debug` for Run and `Release` for Archive. Before archiving:

1. Confirm that the selected scheme is the intended environment.
2. Confirm the matching Firebase `GoogleService-Info.plist` is included.
3. Confirm the bundle identifier, version and build number.
4. Confirm signing certificates and provisioning profiles.
5. Run the relevant staff smoke tests on a physical device.
6. Archive using **Product > Archive**, then validate and distribute through the team's approved process.

Never distribute a build until the PROD scheme, production API URL and production Firebase configuration have been independently verified.


## Release Process

After the production or staging IPA has been generated, provide the IPA to
EMIT. EMIT will upload it to the corresponding location:

- [Staging](https://swac.dsd.gov.hk/mobileapps/staging)
- [Production](https://swac.dsd.gov.hk/mobileapps/production)

Before generating an IPA, verify the following:

1. The correct build target and scheme are selected.
2. The API and Firebase configurations match the selected environment.
3. Signing and provisioning settings are valid.
4. The app has been tested against the intended environment.
