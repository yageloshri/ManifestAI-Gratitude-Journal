# Notification "Soft Ask" Implementation

## Overview
A "Pre-permission" onboarding screen designed to increase notification opt-in rates using psychological priming techniques.

## Why "Soft Ask"?
Traditional notification permission requests have low opt-in rates (~40-50%). By "priming" users with the **value proposition first**, we can increase opt-in rates to 70-80%+.

## Implementation Strategy

### 1. **The Priming Effect**
- Show a beautiful, calm screen **before** the system dialog
- Explain the **benefits** to the user (not just "we want to send you notifications")
- Use positive, spiritual language that aligns with the app's mission

### 2. **Psychology-Driven Copy**
- **Headline**: "Start your day with intention." (Focus on the feeling)
- **Subtext**: Explains the 'why' - daily reminders for manifestations and gratitude
- **Primary CTA**: "Yes, I want inspiration" (Positive affirmation phrasing)
- **Secondary CTA**: "Maybe later" (Low friction opt-out)

### 3. **Visual Design**
- Calm, spiritual aesthetic with mystical gradient background
- Gentle bell icon with breathing animation (glow rings)
- Golden accent colors (`#FFD700`) matching app theme
- Generous whitespace for a peaceful feel

### 4. **Functional Flow**

```
User lands on NotificationSoftAskStepView
    ↓
User clicks "Yes, I want inspiration"
    ↓
System permission dialog appears (ONLY NOW)
    ↓
User grants/denies permission
    ↓
Continue to complete onboarding (regardless of result)
    
OR

User clicks "Maybe later"
    ↓
Skip system dialog entirely
    ↓
Continue to complete onboarding
```

## Files Created/Modified

### New Files
- `NotificationSoftAskStepView.swift` - The soft ask screen implementation

### Modified Files
- `OnboardingContainerView.swift`:
  - Added `.notificationSoftAsk` to `OnboardingStep` enum
  - Integrated the new step after commitment step
  - Both "accept" and "skip" paths call `completeOnboarding()`

## Key Features

### ✅ Priming Strategy
- Value proposition shown BEFORE permission request
- Calm, spiritual design to reduce anxiety
- Positive language framing

### ✅ Iconography
- Bell with badge icon (peaceful, not aggressive)
- Breathing animation with golden glow rings
- Matches app's mystical aesthetic

### ✅ UX Best Practices
- Primary button clearly shows benefit ("Yes, I want inspiration")
- Secondary option is non-judgmental ("Maybe later")
- Loading state during permission request
- Haptic feedback for interactions
- Works regardless of user's choice (no dead ends)

### ✅ Technical Implementation
- Uses `UNUserNotificationCenter.requestAuthorization()`
- Properly handles permission result
- Continues onboarding flow seamlessly
- Console logging for debugging

## Design System Consistency

The screen follows the existing onboarding design patterns:
- **Colors**: `#0a0e17`, `#0f0c29`, `#2d1b4e`, `#FFD700` (gold accent)
- **Typography**: System fonts with light/semibold weights
- **Spacing**: Consistent 32px horizontal padding
- **Animations**: Smooth easeInOut transitions (0.4s duration)
- **Button Style**: 56pt height, 16pt corner radius, golden accent

## Testing Recommendations

1. **Test both paths**:
   - Click "Yes, I want inspiration" → Verify system dialog appears
   - Click "Maybe later" → Verify no dialog appears
   
2. **Test permission states**:
   - First time user (no previous permission state)
   - User who previously denied
   - User who previously granted
   
3. **Test on different devices**:
   - iPhone (various sizes)
   - iPad (if supported)

## Expected Results

Based on industry research, this approach should increase opt-in rates from ~45% to ~70-80% by:
1. Explaining the value before asking
2. Using positive, benefit-driven language
3. Creating a calm, trust-building visual experience
4. Providing a low-pressure opt-out option

## Notes

- The screen appears as the **last step** before completing onboarding
- Position maximizes conversion (user is already invested in the flow)
- No back button (intentional - reduces decision fatigue)
- Screen can be easily repositioned in the flow if needed (just change the enum order in `OnboardingContainerView`)

