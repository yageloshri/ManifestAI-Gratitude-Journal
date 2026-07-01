# 🌟 Onboarding Screens - Structure & Design

## 📁 File Organization

האונבורדינג מחולק לקבצים נפרדים לכל מסך, כך שקל לתחזק ולעדכן:

```
Features/Onboarding/
├── Steps/
│   ├── TheHookScreen.swift           // מסך 1: "Ancient Wisdom Meets Modern Science"
│   ├── NameInputScreen.swift         // מסך 2: "Let's connect"
│   ├── BirthDateScreen.swift         // מסך 3: "Align your energy"
│   ├── GoalsSelectionScreen.swift    // מסך 4: "What do you want to manifest?"
│   └── SocialProofScreen.swift       // מסך 5: "It really works"
├── OnboardingFlowView.swift          // קובץ ניהול ראשי
├── OnboardingIntegration.swift       // OnboardingManager + data persistence
├── OnboardingComponents.swift        // MysticalBackground + StarDust
└── PremiumComponents.swift           // Shared UI components
```

---

## 🎨 Design System

### Colors (Hex Codes)
```swift
Gold Primary:   #D4AF37
Gold Light:     #FFD700
Background:     #0F1729 → #2D1B4E (gradient)
Text Primary:   #FFFFFF
Text Secondary: #FFFFFF @ 75% opacity
```

### Typography
```swift
Titles:    PlayfairDisplay-Bold, 38-44pt
Body:      System Regular, 16-18pt
Buttons:   System Semibold, 20pt
Italic:    Georgia Italic, 22pt (testimonials)
```

### Spacing
```swift
Top Safe Area:       80-120pt
Between Elements:    20-60pt
Button Height:       62pt
Card Corner Radius:  24-28pt
Button Radius:       31pt
Horizontal Padding:  40pt
```

---

## 📱 Screen Details

### 1️⃣ TheHookScreen.swift
**Design Elements:**
- Decorative gold frame at top
- Golden owl with sacred geometry
- Large serif title (Playfair Display)
- Transparent button with gold border

**Key Features:**
- Floating animation on owl
- Sacred geometry background
- Custom decorative frame component

---

### 2️⃣ NameInputScreen.swift
**Design Elements:**
- Owl positioned to the right
- Clean serif title
- Glass-morphism text field with gold border
- Button disabled until name entered

**Key Features:**
- Real-time validation
- Floating owl animation
- Premium glass text field

---

### 3️⃣ BirthDateScreen.swift
**Design Elements:**
- Constellation + moon on left
- Owl on right
- Title with gradient "energy" word
- iOS wheel date picker in glass card

**Key Features:**
- Astrology constellation component
- Custom moon icon
- Premium glass card for picker

---

### 4️⃣ GoalsSelectionScreen.swift
**Design Elements:**
- Flying owl at top
- 2x2 grid of goal cards
- Each card: Icon + Label
- Selected cards: Gold glow + border

**Icons:**
- 💰 Financial: dollarsign.circle.fill
- ❤️ Love: heart.fill  
- 🍃 Peace: leaf.fill
- 📈 Career: chart.line.uptrend.xyaxis

**Key Features:**
- Multi-select functionality
- Scale animation on tap
- Gold glow when selected

---

### 5️⃣ SocialProofScreen.swift
**Design Elements:**
- Owl with wing spread
- Large serif title
- Testimonial card with:
  - 5 gold stars
  - Italic quote (Georgia font)
  - Cosmic swirl avatar at bottom
- Final CTA button

**Key Features:**
- Gradient testimonial card
- Cosmic avatar with glow
- Completion handler integration

---

## 🔧 Shared Components

### PremiumComponents.swift
```swift
PremiumButton        // Transparent with gold border
PremiumTextField     // Glass input field
PremiumGlassCard     // Container with glass effect
```

### OnboardingComponents.swift
```swift
MysticalBackground   // Deep blue-purple gradient
StarDustView         // Animated star particles
```

---

## 🔄 Flow Management

### OnboardingFlowView.swift
- Manages TabView navigation
- Tracks user data (name, birthDate, goals)
- Two versions:
  1. `OnboardingFlowView` - standalone
  2. `OnboardingFlowViewWithManager` - with persistence

### OnboardingIntegration.swift
**OnboardingManager** handles:
- ✅ User data persistence (UserDefaults)
- ✅ Numerology calculation
- ✅ Onboarding completion
- ✅ Analytics tracking

---

## 🎯 Usage

### In ManifestAIApp.swift:
```swift
@StateObject private var onboardingManager = OnboardingManager()

var body: some Scene {
    WindowGroup {
        if onboardingManager.hasCompletedOnboarding {
            DashboardView()
        } else {
            OnboardingFlowViewWithManager()
                .environmentObject(onboardingManager)
        }
    }
}
```

---

## 🖼️ Asset Requirements

Make sure these images exist in Assets:
- `The Hook - 1` (golden owl with wings spread)
- `Name - 2 Input` (owl looking curious)
- `Birth - 3 Date` (owl with mystical symbols)
- `Goals - 4 Selection` (owl flying)
- `Social - 6 Proof` (owl with one wing up)

---

## ✨ Animations

All screens include:
- ✅ Floating owl animation (2.4-3.0 sec cycle)
- ✅ Spring transitions between pages
- ✅ Scale effect on buttons
- ✅ Opacity changes for validation states
- ✅ Haptic feedback on completion

---

## 🐛 Debugging

To reset onboarding:
```swift
UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
```

Or use the OnboardingManager:
```swift
onboardingManager.resetOnboarding()
```

---

## 📝 Notes

1. **Fonts**: Make sure PlayfairDisplay font is added to project
2. **Colors**: All hex colors use existing Color+Extensions
3. **Safe Areas**: All screens respect safe areas
4. **Dark Mode**: Forced dark mode for consistency
5. **Accessibility**: All components support Dynamic Type

---

Built with ❤️ for ManifestAI - Gratitude Journal

