# Onboarding Redesign — Pixel-Perfect Figma Implementation

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rewrite all 10 onboarding screens to match the Figma designs in section `241:1066` pixel-perfect — same fonts, colors, spacing, images, and layout.

**Architecture:** Each screen is a standalone SwiftUI view inside `Features/Onboarding/Steps/`. They share a common design language (glass panels, stepper, bottom bar) extracted into `OnboardingComponents.swift` and `PremiumComponents.swift`. The `OnboardingContainerView.swift` orchestrates the flow — its logic stays untouched. Only UI code changes.

**Tech Stack:** SwiftUI, SwiftData (untouched), SuperwallKit (untouched), Lottie (untouched)

**Figma file:** `qZfqlrTu23SNGAnT8bfMWX` — Section "Registration Screens" node `241:1066`

**Rules:**
- Do NOT change any public interface (struct names, init params, callbacks)
- Do NOT change business logic (UserDefaults saves, navigation, Superwall)
- Do NOT change OnboardingContainerView.swift flow
- Use Theme.swift tokens for ALL colors, spacing, radii, sizes
- Use system serif (`.design(.serif)`) for Bitter and system default for Poppins until custom fonts are bundled
- Every screen uses `s = geo.size.width / 393.0` scale factor
- All positions come from Figma inspect (absolute coordinates)

---

### Task 0: Bundle Bitter + Poppins Fonts

**Why:** Figma uses Bitter (serif) and Poppins (sans-serif). Fonts are already downloaded to `ManifestAI - Gratitude Journal/Fonts/` but not added to the Xcode project.

**Files:**
- Modify: `ManifestAI - Gratitude Journal/Fonts/` (already has TTF files)
- Create: `ManifestAI - Gratitude Journal/Info.plist` (for UIAppFonts)
- Modify: Xcode project (add fonts to target)

**Step 1: Add fonts and Info.plist via Xcode**

This step MUST be done in Xcode GUI (not CLI):
1. Open the project in Xcode
2. Right-click `ManifestAI - Gratitude Journal` group → Add Files
3. Select the `Fonts` folder, check "Copy items if needed", check "Create folder references", check the main app target
4. Right-click again → New File → Property List → name it `Info.plist`
5. Add key `Fonts provided by application` (UIAppFonts) with values:
   - `Bitter[wght].ttf`
   - `Bitter-Italic[wght].ttf`
   - `Poppins-Regular.ttf`
   - `Poppins-Medium.ttf`
   - `Poppins-SemiBold.ttf`
6. In Build Settings → search "Info.plist" → set `Info.plist File` to `ManifestAI - Gratitude Journal/Info.plist`
7. Set `Generate Info.plist File` to `No`
8. Add all previously auto-generated keys to the plist (see list in the Info.plist section below)

**Step 2: Verify fonts load**

Add to ManifestAIApp.swift init() temporarily:
```swift
for family in UIFont.familyNames.sorted() {
    if family.contains("Bitter") || family.contains("Poppins") {
        print("📝 \(family)")
        for name in UIFont.fontNames(forFamilyName: family) {
            print("   → \(name)")
        }
    }
}
```

Expected output:
```
📝 Bitter
   → Bitter-Light
   → Bitter-Regular
   → Bitter-SemiBold
   → Bitter-Bold
📝 Poppins
   → Poppins-Regular
   → Poppins-Medium
   → Poppins-SemiBold
```

**Step 3: Update Theme.swift font functions with real PostScript names**

Replace system fallbacks with `.custom("PostScriptName", size:)` using the names from Step 2.

**Step 4: Remove debug logging, build, verify**

---

### Task 1: Welcome Screen (WelcomeStepView.swift)

**Figma node:** `258:1851`
**File:** `ManifestAI - Gratitude Journal/Features/Onboarding/Steps/WelcomeStepView.swift`

**Interface (preserve exactly):**
```swift
struct WelcomeStepView: View {
    let onContinue: () -> Void
}
```

**Figma measurements:**
- Screen: 393×852
- Purple glow: (0, 12), 578.67×677.5
- Stars bg: (-1, 0), 393×396, opacity 0.6
- Owl image: (-1, 120), 364×369 (scaled to fill, cropped)
- Badge glass: (81, 65), 229×75, r=14, border #63507A 2px
- Badge text: (98, 78), 195×50, Bitter Bold 18px, #FCD471
- Title: (34, 508), 330×132, Bitter Light Italic + SemiBold 37px, #EBEBEB
- Button: (31, 690), 332×56, r=13, gradient #3B2DF7→#7C38FF

**Step 1:** Rewrite WelcomeStepView.swift with exact Figma positions using `.position()` and scale factor
**Step 2:** Build and verify on simulator
**Step 3:** Compare screenshot with Figma screenshot, fix differences

---

### Task 2: Name Screen (NameStepView.swift)

**Figma node:** `255:1190`
**File:** `ManifestAI - Gratitude Journal/Features/Onboarding/Steps/NameStepView.swift`

**Interface (preserve exactly):**
```swift
struct NameStepView: View {
    @Binding var userName: String
    let onContinue: () -> Void
    let onBack: () -> Void
}
```

**Business logic to preserve:**
- `UserDefaults.standard.set(userName, forKey: "user_name")` on continue
- Keyboard auto-focus after 0.5s delay

**Figma measurements:**
- Stepper: (20, 76), 353×6, step 1/6 active (#685EF5)
- Title: (20, 122), "What should we call you?", Bitter SemiBold 26px, #EBEBEB
- Text field: (20, 177), 353×56, capsule r=150, border #63507A, placeholder "Enter Name" Poppins Regular 14px
- Bottom bar: (20, 734), back 56×56 + "Reveal My Path" gradient button

**Step 1:** Rewrite with Figma coordinates, use Theme tokens, preserve business logic
**Step 2:** Build, navigate to screen, verify

---

### Task 3: Category/Breakthrough Screen (BreakthroughStepView.swift)

**Figma node:** `255:1247`
**File:** `ManifestAI - Gratitude Journal/Features/Onboarding/Steps/BreakthroughStepView.swift`

**Interface (preserve exactly):**
```swift
struct BreakthroughStepView: View {
    @Binding var selected: String?
    let onContinue: () -> Void
    let onBack: () -> Void
}
```

**Figma measurements:**
- Stepper: step 2/6
- Title: "Where do you need a breakthrough?", Bitter SemiBold 26px
- 4 category cards (82px height each, r=16, glass border):
  - Love & Relationship (red glow icon)
  - Financial Abundance (orange glow icon)
  - Inner Peace (green glow icon)
  - Career Growth (blue glow icon)
- Each card: icon container 42×42, text Poppins Medium 16px, right arrow
- Bottom bar: back + "Reveal My Path"

**Step 1:** Rewrite with glass cards matching Figma
**Step 2:** Download 4 category icons from Figma via MCP
**Step 3:** Build and verify

---

### Task 4: Problems Screen (PainPointsStepView.swift)

**Figma node:** `256:1133`
**File:** `ManifestAI - Gratitude Journal/Features/Onboarding/Steps/PainPointsStepView.swift`

**Interface (preserve exactly):**
```swift
struct PainPointsStepView: View {
    @Binding var selected: [String]
    let userName: String
    let onContinue: () -> Void
    let onBack: () -> Void
}
```

**Figma measurements:**
- Stepper: step 3/6
- Title: "[Name], What is holding you back right now?", Bitter SemiBold 26px
- 7 pill checkboxes (52px height, r=200, glass border):
  - Select All, Procrastination, Self-Doubt, Lack of Direction, Don't know where to Start, Emotional Fatigue, Impostor Syndrome
- Selected state: border #685EF5, inner glow, check icon
- Unselected state: border #63507A, inner border #BA9DDE
- Bottom bar: back + "Reveal My Path"

**Step 1:** Rewrite with pill checkbox components matching Figma
**Step 2:** Build and verify selection states

---

### Task 5: Did You Know Screen (ScienceStepView.swift)

**Figma node:** `257:1658`
**File:** `ManifestAI - Gratitude Journal/Features/Onboarding/Steps/ScienceStepView.swift`

**Interface (preserve exactly):**
```swift
struct ScienceStepView: View {
    let onContinue: () -> Void
    let onBack: () -> Void
}
```

**Figma measurements:**
- Stepper: step 4/6
- Glass card (353×484, r=16, at y=151):
  - Owl with lightbulb image (194×194, centered, top=18)
  - Stars background inside card (opacity 0.6)
  - "Did you know?" Bitter SemiBold 26px, #FCD471
  - Body text Poppins Medium 16px, #EBEBEB
  - Sub-text Poppins Medium 16px, #B9B9B9
- Bottom bar: back + "Wow Tell Me More"

**Step 1:** Download owl-with-lightbulb image from Figma (node 257:1836)
**Step 2:** Rewrite with glass card and text layout
**Step 3:** Build and verify

---

### Task 6: DOB/Numerology Screen (NumerologyStepView.swift)

**Figma node:** `268:1060`
**File:** `ManifestAI - Gratitude Journal/Features/Onboarding/Steps/NumerologyStepView.swift`

**Interface (preserve exactly):**
```swift
struct NumerologyStepView: View {
    @Binding var birthDate: Date
    let onContinue: () -> Void
    let onBack: () -> Void
}
```

**Figma measurements:**
- Stepper: step 4-5/6
- Title: "Let's align with your stars.", Bitter SemiBold 26px
- Subtitle: "Enter your date of birth below", Poppins Regular 16px, #B9B9B9
- Info box: (20, ~218), bg #251540, r=18, info icon + "We use this to calculate your personal daily number." Poppins Regular 14px, #9F9E9E
- 3 date fields in HStack (Date=80w, Month=150w, Year=105w), glass capsules
- Bottom bar: back + "Calculate"

**Step 1:** Rewrite with 3 date picker fields
**Step 2:** Preserve birthDate binding logic
**Step 3:** Build and verify

---

### Task 7: Analysis Screen (AnalysisStepView.swift)

**Figma node:** `270:437`
**File:** `ManifestAI - Gratitude Journal/Features/Onboarding/Steps/AnalysisStepView.swift`

**Interface (preserve exactly):**
```swift
struct AnalysisStepView: View {
    let birthDate: Date
    let userName: String
    let onContinue: () -> Void
}
```

**Figma measurements:**
- Full-screen glass panel (392×853, r=16)
- Stars bg inside panel (opacity 0.7)
- Badge: "Analysis Complete, [Name]", Bitter Bold 18px, #FCD471, glass r=14
- Owl with crystal ball image (~281×208, centered)
- "According to Numberology", Poppins SemiBold 18px
- Numerology number in gold gradient icon container (88×88), Bitter Bold 58px
- "is your year of transformation", Poppins Medium 16px
- Bottom bar: back + "Continue"

**Step 1:** Download owl-with-crystal-ball image from Figma (node 276:538)
**Step 2:** Rewrite with full-screen glass layout, gold gradient number
**Step 3:** Preserve numerology calculation from birthDate
**Step 4:** Build and verify

---

### Task 8: Commitment Screen (CommitmentStepView.swift)

**Figma node:** `282:570`
**File:** `ManifestAI - Gratitude Journal/Features/Onboarding/Steps/CommitmentStepView.swift`

**Interface (preserve exactly):**
```swift
struct CommitmentStepView: View {
    let onComplete: () -> Void
    let onBack: () -> Void
}
```

**Business logic to preserve:**
- Long-press gesture to commit (holdDuration)
- Fallback "Complete Setup" button

**Figma measurements:**
- Stepper: step 6/6 (all active)
- Glass card (353×564, r=16, at y=135):
  - Stars bg inside card
  - Sleeping owl image (195×195, centered, top=18)
  - "A promise to you self", Bitter SemiBold 26px, #FCD471
  - Bullet: "Change requires consistency." Poppins Medium 16px
  - Bullet: "Can you commit to investing 3 minutes a day in yourself?"
  - Fingerprint icon in glass container (88×88)
  - "Touch and hold to commit", Poppins Regular 14px, #B9B9B9
- Bottom bar: back + "Continue"

**Step 1:** Download sleeping owl and fingerprint icons from Figma
**Step 2:** Rewrite preserving long-press gesture and fallback
**Step 3:** Build and verify

---

### Task 9: Subscription Screen (NEW — SubscriptionView.swift)

**Figma node:** `294:691`
**File:** Create `ManifestAI - Gratitude Journal/Features/Onboarding/Steps/SubscriptionStepView.swift`

**Note:** This screen exists in Figma but NOT in the current codebase. The current flow goes Commitment → NotificationSoftAsk → complete. We need to decide where to insert this. For now, implement as a UI stub that can be called by the container.

**Interface:**
```swift
struct SubscriptionStepView: View {
    let onContinue: () -> Void
    let onSkip: () -> Void
}
```

**Figma measurements:**
- Full-screen glass panel
- Title: "Start your 3-days Free Trial to continue" with "3-days Free" in Bitter Bold Italic 26px, #FCD471
- Timeline: 3 rows (Today, In 2 Days, In 3 Days) with glass icon containers + descriptions
- 2 plan options: Yearly (selected, gold border) and Weekly (unselected)
- CTA: "Start my 3-Day Free Trial" gradient button
- Sub-text: pricing info
- Footer: Privacy | Restore | Terms

**Step 1:** Create new file with exact Figma layout
**Step 2:** Wire into OnboardingContainerView (ask user before modifying flow)
**Step 3:** Build and verify

---

### Task 10: Final Verification

**Step 1:** Build the complete app
**Step 2:** Fresh install on simulator (clean UserDefaults)
**Step 3:** Screenshot each onboarding screen
**Step 4:** Side-by-side comparison with Figma via MCP
**Step 5:** Fix any remaining pixel differences
**Step 6:** Verify all navigation (forward/back) works
**Step 7:** Verify all business logic (name saves, birthDate, selection states)

---

## Info.plist Keys Reference

When creating the custom Info.plist, include these keys (previously auto-generated):

```xml
<key>CFBundleDisplayName</key>
<string>Gratitude Journal</string>
<key>LSApplicationCategoryType</key>
<string>public.app-category.healthcare-fitness</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>ManifestAI needs access to save your created Vision Boards to your Photos library.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>ManifestAI needs access to photos to allow you to create Vision Boards.</string>
<key>UIApplicationSceneManifest</key>
<dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <false/>
</dict>
<key>UIApplicationSupportsIndirectInputEvents</key>
<true/>
<key>UILaunchScreen</key>
<dict/>
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
</array>
<key>UISupportedInterfaceOrientations~ipad</key>
<array>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationPortraitUpsideDown</string>
</array>
```

## Image Assets Needed

| Asset Name | Figma Node | Description | Current Status |
|---|---|---|---|
| OwlIllustration | 265:960 | Owl on branch (welcome) | ✅ Exists (cropped) |
| OnboardingStars | 264:865 | Stars/nebula texture | ✅ Exists |
| WelcomeGlow | 258:1852 | Purple radial glow SVG | ✅ Created |
| OwlLightbulb | 257:1836 | Owl holding lightbulb (science) | ❌ Need to download |
| OwlCrystalBall | 276:538 | Owl with crystal ball (analysis) | ❌ Need to download |
| OwlSleeping | 282:685 | Sleeping owl on cloud (commitment) | ❌ Need to download |
| CategoryLove | 255:1354 | Heart icon (breakthrough) | ❌ Need to download |
| CategoryFinance | 256:1067 | Dollar icon (breakthrough) | ❌ Need to download |
| CategoryPeace | 256:1101 | Leaf icon (breakthrough) | ❌ Need to download |
| CategoryCareer | 256:1120 | Target icon (breakthrough) | ❌ Need to download |
| FingerprintIcon | 282:725 | Fingerprint/commit icon | ❌ Need to download |
