# Paywall & Subscription System

## Overview
Complete paywall implementation with feature gating for free vs. Pro users.

## Features & Access Control

### 🔒 Free Users (Limited Access)
1. **369 Method**: ❌ Completely blocked - Paywall appears immediately
2. **Vision Board**: ⚠️ Can create but cannot save - Paywall on save
3. **Journal**: ⚠️ Limited to 3 entries per week - Paywall when limit reached
4. **Notifications**: ✅ Full access

### 👑 Pro Users (Unlimited Access)
1. **369 Method**: ✅ Unlimited daily manifestations
2. **Vision Board**: ✅ Save unlimited boards
3. **Journal**: ✅ Unlimited entries
4. **All Features**: ✅ No restrictions

## Implementation

### Core Files

#### `SubscriptionManager.swift`
Manages subscription status and feature access:
- Tracks Pro/Free status
- Checks feature permissions
- Counts journal entries per week
- Persists to UserDefaults

```swift
let subscriptionManager = SubscriptionManager.shared

// Check access
if subscriptionManager.can369Method { ... }
if subscriptionManager.canSaveVisionBoard { ... }
if subscriptionManager.canWriteJournalEntry(entriesThisWeek: count) { ... }
```

#### `PaywallView.swift`
Beautiful premium paywall with:
- Feature showcase
- Pricing display
- Trial information
- Superwall integration

```swift
PaywallView(feature: .manifestation369)
PaywallView(feature: .visionBoardSave)
PaywallView(feature: .journalLimit)
```

### Feature Integration

#### 1. 369 Method (`Manifest369View.swift`)
- **Block**: Entire feature locked for free users
- **When**: Immediate on view appear
- **UX**: Shows locked overlay with "Upgrade to Pro" button

```swift
if subscriptionManager.can369Method {
    // Show feature
} else {
    // Show locked overlay
}

.fullScreenCover(isPresented: $showPaywall) {
    PaywallView(feature: .manifestation369)
}

.onAppear {
    if !subscriptionManager.can369Method {
        showPaywall = true
    }
}
```

#### 2. Vision Board (`VisionBoardEditorView.swift`)
- **Block**: Save action only
- **When**: User taps "Save" button
- **UX**: Free users can create/edit but not save

```swift
Button(action: {
    if !subscriptionManager.canSaveVisionBoard {
        showPaywall = true
        return
    }
    // Continue with save...
}) { ... }

.fullScreenCover(isPresented: $showPaywall) {
    PaywallView(feature: .visionBoardSave)
}
```

#### 3. Journal (`JournalInputView.swift`)
- **Block**: After 3 entries per week
- **When**: On view appear
- **UX**: Shows paywall if limit reached

```swift
.onAppear {
    checkJournalAccess()
}

.fullScreenCover(isPresented: $showPaywall) {
    PaywallView(feature: .journalLimit)
}

private func checkJournalAccess() {
    entriesThisWeek = subscriptionManager.getJournalEntriesThisWeek()
    if !subscriptionManager.canWriteJournalEntry(entriesThisWeek: entriesThisWeek) {
        showPaywall = true
    }
}
```

#### 4. Journal Stats (`JournalListView.swift`)
- Shows free users how many entries left this week
- Visual indicator with hourglass/lock icon
- Countdown: "2 free entries left this week"

## Testing

### Enable Pro Mode (Debug Build)
In `PaywallView.swift`, the subscribe button automatically unlocks Pro in debug builds:

```swift
#if DEBUG
subscriptionManager.unlockPro()
dismiss()
#endif
```

### Manually Toggle Status
In any view during development:

```swift
// Unlock Pro
SubscriptionManager.shared.unlockPro()

// Reset to Free
SubscriptionManager.shared.resetToFree()
```

### Test Scenarios

#### Test 1: 369 Method Access
1. Reset to free: `SubscriptionManager.shared.resetToFree()`
2. Navigate to 369 tab
3. ✅ Should show locked overlay
4. Tap "Upgrade to Pro"
5. ✅ Paywall appears
6. (In debug) Tap "Start Free Trial"
7. ✅ Automatically unlocks and shows feature

#### Test 2: Vision Board Save
1. Reset to free
2. Create a vision board with images
3. Tap "Save"
4. ✅ Paywall appears
5. Close paywall
6. ✅ Board not saved, still in editor

#### Test 3: Journal Limit
1. Reset to free
2. Write 3 journal entries
3. Try to write 4th entry
4. ✅ Paywall appears immediately
5. Close paywall
6. ✅ Returned to journal list

## Data Persistence

### UserDefaults Keys
- `user_is_pro`: Boolean subscription status
- `journal_entries_dates`: Array of timestamps for weekly tracking

### Weekly Reset Logic
- Journal entries tracked by week of year
- Old entries (>2 weeks) automatically cleaned up
- Resets every Sunday at midnight

## Production Integration

### Superwall Setup
The paywall integrates with Superwall for real subscription handling:

```swift
// In PaywallView.swift
func handleSubscribe() {
    Superwall.shared.register(event: "subscription_start")
}

func handleRestore() {
    Superwall.shared.restorePurchases()
}
```

### Update Subscription Status
When a purchase completes via Superwall:

```swift
// In your Superwall delegate
func didPurchase() {
    SubscriptionManager.shared.unlockPro()
}
```

## User Flow

### First Launch After Onboarding
1. User completes onboarding (can skip paywall with X)
2. Enters app with free status
3. Can access:
   - Today tab ✅
   - Journal (3/week) ⚠️
   - Vision (can't save) ⚠️
   - 369 (blocked) ❌
   - Profile ✅

### Hitting First Limit
1. User tries to use 369 Method
2. Sees locked screen with benefits
3. Taps "Upgrade to Pro"
4. Beautiful paywall with all features listed
5. Can subscribe or close
6. If closes: Returns to previous screen

### After Subscription
1. All features unlock immediately
2. No more paywalls
3. Stats show "Pro" badge
4. Unlimited access to everything

## Design Language
- **Background**: Deep purple gradient (#0F0520 → #2d1b69)
- **Accent**: Gold (#FFD700)
- **Icons**: Crown for Pro, Lock for blocked
- **Style**: Mystical/Premium aesthetic matching app theme

## Notes
- Paywall uses `.fullScreenCover` for immersive experience
- Can be dismissed with X button (follows App Store guidelines)
- Clear messaging about what's locked and why
- Beautiful feature showcase to drive conversions
- Seamless integration with existing app design

