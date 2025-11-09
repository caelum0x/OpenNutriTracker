# Cal AI Transformation - Project Documentation

## 🎯 Project Overview

This document tracks the transformation of OpenNutriTracker into a Cal AI competitor - an AI-powered nutrition tracking app with photo-based food analysis.

**Target Features:**
- 📸 AI Photo Analysis for food identification
- 💧 Water intake tracking
- 🤖 AI Coaching suggestions
- 📊 Advanced analytics dashboard
- 💎 Freemium model with premium features
- 🔄 Cloud sync across devices
- 🏃 Fitness app integrations (Google Fit, Apple HealthKit)

---

## ✅ Phase 1: AI Photo Analysis (COMPLETED)

### What Was Built

#### 1. OpenRouter Integration
- **File:** `lib/features/ai_photo_analysis/data/data_sources/openrouter_data_source.dart`
- Supports multiple AI models (GPT-4 Vision, Claude 3.5 Sonnet)
- Handles food image analysis and AI coaching
- Error handling and logging

#### 2. Data Layer
- **DTOs:**
  - `openrouter_request_dto.dart` - API requests
  - `openrouter_response_dto.dart` - API responses
  - `food_analysis_dto.dart` - Food analysis results

#### 3. Domain Layer
- **Entities:**
  - `food_analysis_entity.dart` - Business logic for analysis results
  - `ai_usage_entity.dart` - Freemium usage tracking
- **Use Cases:**
  - `analyze_food_photo_usecase.dart` - Orchestrates photo analysis

#### 4. Presentation Layer
- **BLoC Pattern:**
  - `ai_photo_bloc.dart` - State management
  - `ai_photo_event.dart` - User actions
  - `ai_photo_state.dart` - UI states

- **Screens:**
  - `camera_capture_screen.dart` - Camera UI with guides
  - `analysis_result_screen.dart` - AI results with editing

- **Widgets:**
  - `food_item_card.dart` - Individual food items
  - `nutrition_summary_card.dart` - Total nutrition display

### Key Features
✅ Camera capture with guide overlay
✅ Gallery photo selection
✅ AI food identification with confidence scores
✅ Manual adjustment of nutrition values
✅ Multi-food item detection
✅ Beautiful, intuitive UI

---

## ✅ Phase 2: Water Tracking (COMPLETED)

### What Was Built

#### 1. Data Layer
- **DBO:** `water_intake_dbo.dart` - Hive storage model
- **Data Source:** `water_intake_data_source.dart` - CRUD operations

#### 2. Domain Layer
- **Entities:**
  - `water_intake_entity.dart` - Single water log
  - `daily_water_summary_entity.dart` - Daily aggregation with goals

#### 3. Presentation Layer
- **BLoC Pattern:**
  - `water_tracking_bloc.dart` - State management
  - `water_tracking_event.dart` - User actions
  - `water_tracking_state.dart` - UI states

- **Widget:**
  - `water_tracking_widget.dart` - Beautiful water tracking card with quick-add buttons

### Key Features
✅ Track water intake (250ml, 500ml, 1L, custom)
✅ Daily goal tracking with progress bar
✅ Visual glass count
✅ Beautiful gradient UI
✅ Local storage with Hive

---

## 🚧 Phase 2: Remaining Tasks

### 1. AI Coaching Engine
**Status:** Pending
**Description:** Implement AI-powered nutrition coaching

**Tasks:**
- [ ] Create coaching BLoC
- [ ] Build coaching widget for home screen
- [ ] Integrate with OpenRouter for suggestions
- [ ] Context-aware recommendations (time of day, goals, etc.)
- [ ] Daily/weekly insights

**Files to Create:**
```
lib/features/ai_coaching/
  ├── domain/entity/coaching_suggestion_entity.dart
  ├── presentation/bloc/
  │   ├── coaching_bloc.dart
  │   ├── coaching_event.dart
  │   └── coaching_state.dart
  └── presentation/widgets/coaching_card.dart
```

### 2. Progress Analytics Dashboard
**Status:** Pending
**Description:** Advanced charts and insights

**Tasks:**
- [ ] Weight tracking over time
- [ ] Nutrition trends (weekly/monthly)
- [ ] Calorie deficit/surplus tracking
- [ ] Macro ratio pie charts
- [ ] Streak tracking
- [ ] Achievement badges

**Dependencies:**
- `fl_chart` (already added) for charts

**Files to Create:**
```
lib/features/analytics/
  ├── presentation/screens/analytics_screen.dart
  ├── presentation/widgets/
  │   ├── weight_chart.dart
  │   ├── macro_chart.dart
  │   └── streak_widget.dart
  └── domain/entity/analytics_entity.dart
```

### 3. UI/UX Redesign
**Status:** Pending
**Description:** Modern Cal AI aesthetic

**Tasks:**
- [ ] Update color scheme to match Cal AI
- [ ] Smooth animations and transitions
- [ ] Gradient backgrounds and cards
- [ ] Modern iconography
- [ ] Splash screen animation
- [ ] Onboarding flow redesign

---

## 🔐 Phase 3: Premium Features & Integrations

### 1. Subscription Management
**Status:** Pending
**Package:** `in_app_purchase` (already added)

**Tasks:**
- [ ] Set up App Store Connect / Play Console subscriptions
- [ ] Implement `SubscriptionBloc`
- [ ] Create subscription tiers (Free, Premium)
- [ ] Paywall screens
- [ ] Restore purchases functionality

**Free Tier:**
- 10 AI photo scans/day
- Basic tracking
- Limited history (7 days)

**Premium Tier ($9.99/month):**
- Unlimited AI scans
- AI coaching
- Full history
- Advanced analytics
- Fitness integrations
- Export data

### 2. Paywall Implementation
**Tasks:**
- [ ] Create paywall screen
- [ ] Upgrade prompts throughout app
- [ ] Trial period handling
- [ ] Subscription status indicator

### 3. Fitness App Integrations

#### Google Fit
**Tasks:**
- [ ] Add `health` package
- [ ] Request permissions
- [ ] Sync calories burned
- [ ] Sync weight data
- [ ] Two-way sync

#### Apple HealthKit
**Tasks:**
- [ ] Configure HealthKit capabilities
- [ ] Request permissions
- [ ] Sync nutrition data
- [ ] Sync water intake
- [ ] Sync weight

---

## ☁️ Phase 4: Backend & Cloud Sync

### 1. Supabase Backend
**Status:** Already configured
**Tasks:**
- [ ] Design database schema
  - Users table
  - Food intakes table
  - Water intakes table
  - AI usage table
  - Subscriptions table
- [ ] Set up Row Level Security (RLS)
- [ ] Create API endpoints
- [ ] Real-time subscriptions for sync

### 2. User Authentication
**Tasks:**
- [ ] Email/password auth
- [ ] Google Sign-In
- [ ] Apple Sign-In
- [ ] Password reset flow
- [ ] Profile management

### 3. Cloud Sync
**Tasks:**
- [ ] Conflict resolution strategy
- [ ] Offline-first architecture
- [ ] Background sync
- [ ] Sync status indicator
- [ ] Manual sync trigger

---

## 🎨 Phase 5: Branding & Launch

### 1. Rebrand App
**Tasks:**
- [ ] Choose new app name (Cal AI Alternative or unique name)
- [ ] Design new logo
- [ ] Create app icon
- [ ] Update splash screen
- [ ] Update color scheme
- [ ] Create marketing assets

### 2. Performance Optimization
**Tasks:**
- [ ] Image compression for AI uploads
- [ ] Lazy loading
- [ ] Database query optimization
- [ ] Memory leak detection
- [ ] Reduce app size

### 3. App Store Preparation
**Tasks:**
- [ ] App Store screenshots (all device sizes)
- [ ] App description and keywords
- [ ] Privacy policy
- [ ] Terms of service
- [ ] App Store preview video
- [ ] TestFlight beta testing
- [ ] Play Store listing

---

## 🛠️ Technical Setup Required

### 1. Environment Variables
Add to `.env`:
```bash
OPENROUTER_API_KEY="your_openrouter_key_here"
SUPABASE_PROJECT_URL="your_supabase_url"
SUPABASE_PROJECT_ANON_KEY="your_supabase_key"
```

### 2. Build & Run
```bash
# Install dependencies
flutter pub get

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Run app
flutter run
```

### 3. Register Hive Adapters
In `lib/core/utils/hive_db_provider.dart`, add:
```dart
Hive.registerAdapter(WaterIntakeDBOAdapter());
```

### 4. Dependency Injection
In `lib/core/utils/locator.dart`, add:
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

---

## 📱 Integration Points

### Adding AI Photo Button to Home Screen
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

### Adding Water Widget to Home Screen
```dart
BlocProvider(
  create: (context) => locator<WaterTrackingBloc>()
    ..add(LoadWaterData(date: DateTime.now())),
  child: const WaterTrackingWidget(),
);
```

---

## 🎯 Success Metrics

### Technical KPIs
- [ ] AI analysis accuracy > 80%
- [ ] Photo analysis time < 5 seconds
- [ ] App launch time < 2 seconds
- [ ] Crash-free rate > 99%

### Business KPIs
- [ ] 10,000 downloads in first month
- [ ] 20% conversion to premium
- [ ] 4.5+ star rating
- [ ] 30% retention at 30 days

---

## 🐛 Known Issues & TODOs

### Immediate
- [ ] Generate missing `.g.dart` files with build_runner
- [ ] Test AI photo analysis with real OpenRouter API key
- [ ] Integrate AI photo and water tracking into existing home screen
- [ ] Add permissions for camera in Android/iOS manifests

### Future Enhancements
- [ ] AR depth sensor for portion size estimation
- [ ] Meal recommendations based on goals
- [ ] Social features (share progress)
- [ ] Recipe builder
- [ ] Barcode enhancement with AI
- [ ] Voice commands for logging
- [ ] Apple Watch / Wear OS apps

---

## 📚 Resources

### APIs & Services
- [OpenRouter](https://openrouter.ai/) - AI model routing
- [Supabase](https://supabase.com/) - Backend & Auth
- [Open Food Facts](https://world.openfoodfacts.org/) - Food database
- [USDA FoodData Central](https://fdc.nal.usda.gov/) - Nutrition data

### Flutter Packages
- `camera` - Camera access
- `image_picker` - Gallery access
- `fl_chart` - Charts
- `in_app_purchase` - Subscriptions
- `share_plus` - Social sharing
- `health` - Fitness data sync

### Design Inspiration
- [Cal AI](https://calai.app/) - Reference app
- [Dribbble](https://dribbble.com/tags/nutrition-app) - UI designs
- [Material Design 3](https://m3.material.io/) - Design system

---

## 👥 Contributors

- Project initiated: [Your Name]
- Based on: OpenNutriTracker (Open Source)

---

## 📄 License

[To be determined - check original OpenNutriTracker license]

---

**Last Updated:** 2025-11-09
**Version:** 0.1.0 (Alpha)
**Status:** Phase 1 & 2 Complete, Phase 3-5 Pending
