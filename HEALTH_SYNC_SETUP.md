# Health Sync Setup Guide

## Overview

This guide explains how to configure Google Fit (Android) and Apple HealthKit (iOS) integrations for your app.

---

## iOS - Apple HealthKit Setup

### 1. Enable HealthKit Capability

1. Open your project in Xcode
2. Select your target → **Signing & Capabilities**
3. Click **+ Capability**
4. Add **HealthKit**

### 2. Update Info.plist

Add these keys to `ios/Runner/Info.plist`:

```xml
<key>NSHealthShareUsageDescription</key>
<string>We need access to read your health data to sync calories burned, weight, and activity</string>

<key>NSHealthUpdateUsageDescription</key>
<string>We need access to write nutrition and water intake data to Health app</string>

<key>UIBackgroundModes</key>
<array>
    <string>processing</string>
</array>
```

### 3. Configure Entitlements

The health package will automatically create the required entitlements file.

### 4. Health Data Types

The app requests access to:

**Read:**
- Active Energy Burned
- Weight
- Steps
- Water
- Dietary Nutrition (Carbs, Protein, Fat, Calories)

**Write:**
- Water
- Weight
- Dietary Nutrition (Carbs, Protein, Fat, Calories)

---

## Android - Google Fit Setup

### 1. Update AndroidManifest.xml

Add these permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Health Connect / Google Fit Permissions -->
<uses-permission android:name="android.permission.health.READ_ACTIVE_CALORIES_BURNED"/>
<uses-permission android:name="android.permission.health.READ_WEIGHT"/>
<uses-permission android:name="android.permission.health.READ_STEPS"/>
<uses-permission android:name="android.permission.health.READ_HYDRATION"/>
<uses-permission android:name="android.permission.health.READ_NUTRITION"/>

<uses-permission android:name="android.permission.health.WRITE_WEIGHT"/>
<uses-permission android:name="android.permission.health.WRITE_HYDRATION"/>
<uses-permission android:name="android.permission.health.WRITE_NUTRITION"/>

<!-- Activity Recognition for step counting -->
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION"/>

<!-- For older Android versions -->
<uses-permission android:name="com.google.android.gms.permission.ACTIVITY_RECOGNITION"/>
```

### 2. Update build.gradle

Add Health Connect dependency in `android/app/build.gradle`:

```gradle
dependencies {
    // ... other dependencies
    implementation 'androidx.health.connect:connect-client:1.1.0-alpha07'
}
```

### 3. Google Fit API Setup (Optional for older devices)

For devices without Health Connect, you'll need to set up Google Fit API:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable **Fitness API**
4. Create **OAuth 2.0 Client ID**
   - Application type: Android
   - Package name: `com.yourcompany.yourapp`
   - SHA-1 certificate fingerprint: Get from `keytool -list -v -keystore ~/.android/debug.keystore`
5. Add the OAuth client ID to your app

### 4. Health Connect App

Users need to have **Health Connect** app installed on Android 14+ or **Google Fit** on older versions.

---

## Testing

### iOS Testing

1. Run app on real iOS device (Simulator doesn't support HealthKit)
2. Navigate to Health Sync settings
3. Tap "Connect Now"
4. Grant permissions in Health app
5. Test syncing

**Note:** HealthKit is not available on iOS Simulator!

### Android Testing

1. Ensure Health Connect or Google Fit is installed
2. Run app on real device or emulator
3. Navigate to Health Sync settings
4. Tap "Connect Now"
5. Grant permissions
6. Test syncing

---

## Features

### What Gets Synced

#### From Health App → Your App
- ✅ Calories burned from workouts
- ✅ Weight measurements
- ✅ Steps count
- ✅ Water intake (optional)

#### From Your App → Health App
- ✅ Food nutrition data (calories, macros)
- ✅ Water intake
- ✅ Weight measurements
- ✅ Custom meals with nutritional breakdown

### Auto-Sync

When enabled, the app automatically:
- Syncs new meals to health app
- Syncs water intake logs
- Pulls activity data daily
- Updates weight measurements

---

## Common Issues

### iOS Issues

**"HealthKit not available"**
- Make sure you're testing on a real device
- HealthKit doesn't work on Simulator
- Check that HealthKit capability is enabled

**"Permission denied"**
- User must grant permissions in Health app
- Go to Health app → Sources → Your App
- Enable read/write permissions

### Android Issues

**"Health Connect not found"**
- Install Health Connect from Play Store (Android 14+)
- Or install Google Fit for older versions

**"Permissions denied"**
- Check AndroidManifest.xml has correct permissions
- User must grant runtime permissions
- Check Health Connect app settings

---

## Privacy & Data Handling

### Data Storage
- Health data is **never** stored on our servers
- All syncing happens directly between your app and Health app
- Data remains on user's device

### User Control
- Users can enable/disable sync anytime
- Individual data types can be toggled
- Users can disconnect completely

### Compliance
- HIPAA compliant (health data stays local)
- GDPR compliant (user controls data)
- Follows Apple/Google health data guidelines

---

## Code Integration

### Initialize Health Sync

```dart
// In your dependency injection (locator.dart)
locator.registerLazySingleton(() => HealthDataSource());
locator.registerFactory(() => HealthSyncBloc(
  healthDataSource: locator(),
));
```

### Navigate to Settings

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BlocProvider(
      create: (context) => locator<HealthSyncBloc>()
        ..add(const InitializeHealthSync()),
      child: const HealthSyncSettingsScreen(),
    ),
  ),
);
```

### Auto-Sync Water Intake

```dart
// When user logs water
context.read<HealthSyncBloc>().add(
  WriteWaterToHealth(
    milliliters: 250,
    date: DateTime.now(),
  ),
);
```

### Auto-Sync Nutrition

```dart
// When user logs a meal
context.read<HealthSyncBloc>().add(
  WriteNutritionToHealth(
    calories: 500,
    protein: 30,
    carbs: 60,
    fat: 15,
    date: DateTime.now(),
  ),
);
```

---

## Debugging

### Enable Logging

```dart
// The HealthDataSource already has logging enabled
// Check console for messages prefixed with [HealthDataSource]
```

### Test Data

```dart
// Manually trigger sync
context.read<HealthSyncBloc>().add(const ManualSync());

// Load health summary
context.read<HealthSyncBloc>().add(
  LoadHealthSummary(date: DateTime.now()),
);
```

---

## App Store Review

### iOS Review Notes

Apple requires explanation for HealthKit usage:

**Review Notes Template:**
```
Our app integrates with Apple Health to:
1. Import calories burned and activity data to adjust nutrition goals
2. Export nutrition and water intake for comprehensive health tracking
3. Sync weight measurements for progress tracking

All health data remains on the user's device and is not transmitted to our servers.
Users can disable this feature at any time.
```

### Android Review Notes

Google Play has fewer restrictions, but mention:
- Health Connect/Google Fit integration purpose
- Data is not collected or transmitted
- User controls all permissions

---

## Best Practices

1. **Request permissions only when needed**
   - Don't request on app launch
   - Show benefits before asking
   - Explain what each permission does

2. **Handle errors gracefully**
   - Health app might not be available
   - User might deny permissions
   - Sync might fail - don't crash

3. **Respect user privacy**
   - Never access health data without permission
   - Let users disable sync anytime
   - Be transparent about data usage

4. **Test thoroughly**
   - Test on real devices
   - Test with/without Health app
   - Test permission denial flows

---

## Resources

- [Apple HealthKit Documentation](https://developer.apple.com/documentation/healthkit)
- [Google Health Connect](https://developer.android.com/health-and-fitness/guides/health-connect)
- [Flutter Health Package](https://pub.dev/packages/health)

---

**Ready to sync with the fitness ecosystem! 🏃‍♂️💪**
