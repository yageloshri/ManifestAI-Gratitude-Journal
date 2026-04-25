# 369 Manifestation Method Feature

## Overview
The 369 Manifestation Method is a powerful daily ritual feature that helps users manifest their desires through repetitive writing. Based on Nikola Tesla's belief in the power of numbers 3, 6, and 9.

## How It Works

### Daily Ritual Structure
Users write their affirmation **18 times** throughout the day:
- **Morning**: 3 repetitions ☀️
- **Afternoon**: 6 repetitions 🌤
- **Evening**: 9 repetitions 🌙

### Sequential Unlocking
- Morning phase is always available
- Afternoon unlocks only after Morning is complete
- Evening unlocks only after Afternoon is complete

## Features

### 1. Main View (`Manifest369View`)
- **Circular Progress Bar**: Shows total daily progress (0-18)
- **Phase Cards**: Three glassmorphic cards representing each phase
- **Visual Feedback**: Cards turn gold when completed, locked phases are dimmed
- **Edit Affirmation**: Users can customize their daily affirmation

### 2. Writing Ritual View (`WritingRitualView`)
- **Focused Writing**: Distraction-free interface for writing affirmations
- **Real-time Validation**: Checks if typed text matches the affirmation
- **Haptic Feedback**: Heavy haptic on success, error haptic on mismatch
- **Visual Celebration**: Gold animations and "Frequency Aligned" celebration screen
- **Progress Tracking**: Shows completed repetitions and current progress

### 3. Data Persistence
- Progress automatically saves after each repetition
- Survives app restarts
- **Automatic Midnight Reset**: New day starts fresh at midnight

## Design Language
- **Background**: Deep Purple `#0F0520`
- **Accents**: Gold `#FFD700`
- **Style**: Mystical/Dark Mode with glassmorphism effects

## Integration

### Tab Bar
The feature is accessible via:
1. **Tab Bar**: Dedicated "369" tab with sparkles icon
2. **Dashboard**: "369 Method" card in the Bento grid (navigates to tab 3)

### Navigation Structure
```swift
// In DashboardView.swift
TabView(selection: $selection) {
    // ... other tabs ...
    
    Manifest369View()
        .tabItem {
            Label("369", systemImage: "sparkles")
        }
        .tag(3)
}
```

## File Structure
```
Features/
  └── Manifestation369/
      ├── Manifest369View.swift          // Main view with progress
      ├── Manifest369ViewModel.swift     // State management & persistence
      ├── WritingRitualView.swift        // Writing interface
      └── README.md                      // This file

Core/
  └── Models/
      └── ManifestationCycle.swift       // Data model
```

## User Flow

1. User opens 369 tab or taps "369 Method" card
2. Sees circular progress (0/18) and three phase cards
3. Taps "Morning" card (always active)
4. Enters writing ritual view
5. Types affirmation 3 times with validation
6. Gets celebration animation
7. Returns to main view - Afternoon now unlocked
8. Repeats for Afternoon (6x) and Evening (9x)
9. Completes all 18 repetitions
10. At midnight, progress resets for new day

## Technical Details

### Data Model
```swift
struct ManifestationCycle: Codable {
    var affirmation: String
    var morningCount: Int      // 0-3
    var afternoonCount: Int    // 0-6
    var eveningCount: Int      // 0-9
    var lastUpdatedDate: Date
}
```

### Persistence
- Uses `UserDefaults` with JSON encoding
- Key: `"manifestationCycle369"`
- Checks date on load for midnight reset

### Midnight Reset
- Timer scheduled to fire at next midnight
- Automatically resets all counters
- Reschedules for following midnight

## Default Affirmation
"I am worthy of all my desires manifesting effortlessly"

Users can edit this at any time via the "Edit Affirmation" button.

## 🔔 Notification System

### Daily Reminders
The feature includes a smart notification system that reminds users to complete each phase:

- **Morning Reminder**: Default at 8:00 AM ☀️
- **Afternoon Reminder**: Default at 2:00 PM 🌤
- **Evening Reminder**: Default at 8:00 PM 🌙

### How It Works
1. **Enable Notifications**: Toggle the "Daily Reminders" switch in the main view
2. **Permission Request**: App requests notification permission (first time only)
3. **Customize Times**: Tap "Customize Times" to set your preferred notification hours
4. **Smart Cancellation**: Notifications are automatically cancelled when you complete a phase
5. **Daily Reset**: At midnight, all notifications are rescheduled for the new day

### Features
- ✅ Automatic cancellation when phase is completed
- ✅ Customizable notification times for each phase
- ✅ Badge counter to remind users
- ✅ Beautiful notification content with emojis
- ✅ Persistent across app restarts
- ✅ Daily reset at midnight

### Technical Implementation
- Uses `UNUserNotificationCenter` for local notifications
- `NotificationManager369` handles all notification logic
- Times stored in `UserDefaults`
- Integration with `Manifest369ViewModel` for state management

