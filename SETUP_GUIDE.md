# Quick Setup Guide - Cal AI Transformation

## 🚀 Quick Start (5 Minutes)

### Step 1: Get OpenRouter API Key
1. Go to [OpenRouter.ai](https://openrouter.ai/)
2. Sign up for an account
3. Navigate to API Keys section
4. Create a new API key
5. Copy your API key

### Step 2: Configure Environment
Edit `.env` file in the project root:
```bash
# Add your OpenRouter API key
OPENROUTER_API_KEY="sk-or-v1-your-key-here"

# Keep existing values
FDC_API_KEY="YOUR_KEY"
SENTRY_DNS="DNS_URL"
SUPABASE_PROJECT_URL="PROJECT_URL"
SUPABASE_PROJECT_ANON_KEY="ANON_KEY"
```

### Step 3: Install Dependencies
```bash
flutter pub get
```

### Step 4: Generate Code
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `env.g.dart` - Environment variables
- `*.g.dart` files for JSON serialization
- `water_intake_dbo.g.dart` - Hive adapter

### Step 5: Update Hive Registration

Edit `lib/core/utils/hive_db_provider.dart`:

Find the `registerAdapters()` method and add:
```dart
// Add this import at the top
import 'package:opennutritracker/features/water_tracking/data/dbo/water_intake_dbo.dart';

// Add this line in registerAdapters()
Hive.registerAdapter(WaterIntakeDBOAdapter());
```

### Step 6: Update Dependency Injection

Edit `lib/core/utils/locator.dart`:

Add these imports:
```dart
import 'package:opennutritracker/features/ai_photo_analysis/data/data_sources/openrouter_data_source.dart';
import 'package:opennutritracker/features/ai_photo_analysis/data/repository/ai_photo_repository.dart';
import 'package:opennutritracker/features/ai_photo_analysis/domain/usecase/analyze_food_photo_usecase.dart';
import 'package:opennutritracker/features/ai_photo_analysis/presentation/bloc/ai_photo_bloc.dart';
import 'package:opennutritracker/features/water_tracking/data/data_source/water_intake_data_source.dart';
import 'package:opennutritracker/features/water_tracking/presentation/bloc/water_tracking_bloc.dart';
```

Add these registrations in `setupLocator()`:
```dart
// AI Photo Analysis
locator.registerLazySingleton(() => OpenRouterDataSource());
locator.registerLazySingleton(() => AIPhotoRepository(
  dataSource: locator(),
));
locator.registerFactory(() => AIPhotoBloc(
  analyzeFoodPhotoUseCase: AnalyzeFoodPhotoUseCase(
    repository: locator(),
  ),
));

// Water Tracking
locator.registerLazySingleton(() => WaterIntakeDataSource());
locator.registerFactory(() => WaterTrackingBloc(
  dataSource: locator(),
));
```

### Step 7: Initialize Water Box

Edit `lib/core/utils/hive_db_provider.dart`:

Add to the `openBoxes()` method:
```dart
await Hive.openBox<WaterIntakeDBO>('waterIntakeBox');
```

### Step 8: Add Camera Permissions

#### Android
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-feature android:name="android.hardware.camera" android:required="false"/>
```

#### iOS
Edit `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan your food</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to analyze your food photos</string>
```

### Step 9: Run the App
```bash
flutter run
```

---

## 🧪 Testing the AI Photo Feature

### Method 1: From Code
Add a test button to your home screen:

```dart
FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => locator<AIPhotoBloc>(),
          child: const CameraCaptureScreen(),
        ),
      ),
    );
  },
  child: const Icon(Icons.camera_alt),
);
```

### Method 2: Temporary Test Screen
Create `lib/test_ai_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/ai_photo_analysis/presentation/bloc/ai_photo_bloc.dart';
import 'package:opennutritracker/features/ai_photo_analysis/presentation/screens/camera_capture_screen.dart';

class TestAIScreen extends StatelessWidget {
  const TestAIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test AI Features')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => locator<AIPhotoBloc>(),
                      child: const CameraCaptureScreen(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Test AI Photo Analysis'),
            ),
          ],
        ),
      ),
    );
  }
}
```

Then navigate to it from your main screen.

---

## 🧪 Testing Water Tracking

Add to your home screen:
```dart
BlocProvider(
  create: (context) => locator<WaterTrackingBloc>()
    ..add(LoadWaterData(date: DateTime.now())),
  child: const WaterTrackingWidget(),
)
```

---

## 🐛 Troubleshooting

### "Cannot find OpenRouterDataSource"
Run: `flutter pub get` and restart your IDE

### "env.g.dart not found"
Run: `flutter pub run build_runner build --delete-conflicting-outputs`

### "WaterIntakeDBOAdapter not found"
Make sure you ran build_runner and registered the adapter in hive_db_provider.dart

### "OpenRouter API Error"
- Check your API key is correct in `.env`
- Verify you have credits on OpenRouter
- Check network connection
- View logs for detailed error

### Camera not working
- Check permissions are added to AndroidManifest.xml and Info.plist
- Rebuild the app after adding permissions
- Test on a real device (simulators may have issues)

---

## 💰 OpenRouter Costs

**Estimated Costs:**
- GPT-4 Vision: ~$0.03 per image
- Claude 3.5 Sonnet: ~$0.01 per image
- 1000 images ≈ $10-30 depending on model

**Free Tier:**
- OpenRouter offers credits for testing
- You can set spending limits

**Tip:** Use Claude 3.5 Sonnet for better cost efficiency!

---

## 📱 Next Steps

1. **Test the AI photo feature:**
   - Take photos of different foods
   - Verify accuracy
   - Check confidence scores

2. **Test water tracking:**
   - Add different amounts
   - Check progress bar
   - Verify storage

3. **Integrate into main app:**
   - Add buttons to home screen
   - Update navigation
   - Customize UI to match your brand

4. **Continue with Phase 3-5:**
   - See `CAL_AI_TRANSFORMATION.md` for roadmap

---

## 🆘 Need Help?

**Common Issues:**
- Check the `Troubleshooting` section above
- Review Flutter doctor: `flutter doctor -v`
- Check logs: `flutter logs`

**Resources:**
- [Flutter Documentation](https://docs.flutter.dev/)
- [OpenRouter Docs](https://openrouter.ai/docs)
- [Hive Documentation](https://docs.hivedb.dev/)

---

**Ready to build? Let's go! 🚀**
