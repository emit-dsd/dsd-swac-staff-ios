# DSD SWIMS Staff iOS

DSD SWIMS Staff is an iOS application for supporting DSD/SWAC site and staff
operations, including attendance management, safety inspections, site diaries
and incident reporting.

Repository: <https://github.com/emit-dsd/dsd-swac-staff-ios>

## Features

- User login and session management
- Home dashboard and SWAC management
- Staff attendance sign-in and sign-out
- Site diary creation and management
- Safety inspection checklists
- Incident report submission and management
- Push notifications
- QR code and document scanning
- Photo and file attachments
- Language selection

## Technology Stack

- Swift
- SwiftUI
- Swift Concurrency (`async/await`)
- URLSession-based API layer
- Firebase Cloud Messaging
- Swift Package Manager
- CodeScanner
- Localize-Swift
- SwiftfulRouting

## Requirements

- macOS
- Xcode `26.0.1`
- iOS 17.0 or later
- Apple Developer account and the required signing credentials
- Access to the required backend API and Firebase configuration

## Getting Started

1. Clone the repository:

   ```bash
   git clone https://github.com/emit-dsd/dsd-swac-staff-ios.git
   cd dsd-swac-staff-ios
   ```

2. Open `dsd-swacs-staff.xcodeproj` in Xcode.

3. Select the required scheme and build target:

   - `DEV` for development
   - `UAT` for user acceptance testing
   - `PROD` for production

4. Select an iOS Simulator or a connected iPhone.

5. Build and run the application in Xcode.

## Environments

The app supports the following environments:

| Environment | Purpose |
|-------------|---------|
| DEV | Development and local testing |
| UAT | User acceptance testing |
| PROD | Production release |

Each environment has its own bundle identifier, API configuration, Firebase
configuration and signing settings. Confirm that the correct target,
`GoogleService-Info.plist` and provisioning profile are selected before
building.

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
│   ├── Notification/
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

## Push Notifications

Push notifications are implemented using Firebase Cloud Messaging and Apple
Push Notification service. The selected environment requires the matching
Firebase configuration and APNs-enabled signing setup.

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

## Security Notes

Do not commit API tokens, user passwords, private keys, certificates or other
production secrets to the repository. Avoid logging bearer tokens or personal
information. Environment-specific credentials should be managed through the
approved secure development or release process.
