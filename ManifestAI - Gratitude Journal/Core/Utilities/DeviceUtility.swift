// DeviceUtility.swift
// Utilities for detecting device type and providing responsive values

import UIKit
import SwiftUI

struct DeviceUtility {
    /// Detect if the current device is an iPad
    static var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    /// Detect if the current device is an iPhone
    static var isIPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    /// Get screen width
    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    /// Get screen height
    static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    /// Scaling factor for iPad (iPad gets ~1.4x scaling for better use of space)
    static var scaleFactor: CGFloat {
        return isIPad ? 1.4 : 1.0
    }
    
    /// Safe bottom padding for buttons - ensures buttons are never cut off on iPad
    /// Uses larger minimum padding on iPad due to scaled content
    static var safeBottomPadding: CGFloat {
        if isIPad {
            // iPad Air 11-inch and similar: use generous bottom padding
            // to account for scaled content and ensure button visibility
            return max(60, safeAreaInsets.bottom + 40)
        } else {
            // iPhone: standard padding above home indicator
            return max(40, safeAreaInsets.bottom + 16)
        }
    }
    
    /// Get current safe area insets
    static var safeAreaInsets: UIEdgeInsets {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return .zero
        }
        return window.safeAreaInsets
    }
}

// MARK: - Responsive Extensions
extension CGFloat {
    /// Returns a responsive value that scales up on iPad
    var responsive: CGFloat {
        return self * DeviceUtility.scaleFactor
    }
    
    /// Returns a responsive value with custom iPad multiplier
    func responsive(iPadMultiplier: CGFloat = 1.4) -> CGFloat {
        return DeviceUtility.isIPad ? self * iPadMultiplier : self
    }
}

extension Int {
    /// Returns a responsive value that scales up on iPad
    var responsive: CGFloat {
        return CGFloat(self) * DeviceUtility.scaleFactor
    }
}

extension Double {
    /// Returns a responsive value that scales up on iPad
    var responsive: CGFloat {
        return CGFloat(self) * DeviceUtility.scaleFactor
    }
}

// MARK: - View Extension for Device-Specific Modifiers
extension View {
    /// Apply different padding for iPhone vs iPad
    func responsivePadding(_ edges: Edge.Set = .all, iPhone: CGFloat, iPad: CGFloat) -> some View {
        self.padding(edges, DeviceUtility.isIPad ? iPad : iPhone)
    }
    
    /// Apply different frame height for iPhone vs iPad
    func responsiveHeight(_ iPhone: CGFloat, iPad: CGFloat? = nil) -> some View {
        let height = DeviceUtility.isIPad ? (iPad ?? iPhone * DeviceUtility.scaleFactor) : iPhone
        return self.frame(height: height)
    }
    
    /// Apply different frame width for iPhone vs iPad
    func responsiveWidth(_ iPhone: CGFloat, iPad: CGFloat? = nil) -> some View {
        let width = DeviceUtility.isIPad ? (iPad ?? iPhone * DeviceUtility.scaleFactor) : iPhone
        return self.frame(width: width)
    }
    
    /// Apply safe bottom padding that prevents buttons from being cut off on iPad
    func safeBottomPadding() -> some View {
        self.padding(.bottom, DeviceUtility.safeBottomPadding)
    }
}

// MARK: - Safe Area Wrapper for Onboarding Screens
/// A container view that ensures content is properly laid out with safe areas on iPad
struct SafeOnboardingContainer<Content: View>: View {
    let backgroundImage: String?
    let backgroundColor: Color?
    let content: Content
    
    init(backgroundImage: String? = nil,
         backgroundColor: Color? = nil,
         @ViewBuilder content: () -> Content) {
        self.backgroundImage = backgroundImage
        self.backgroundColor = backgroundColor
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                if let imageName = backgroundImage {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .ignoresSafeArea()
                } else if let bgColor = backgroundColor {
                    bgColor.ignoresSafeArea()
                }
                
                // Content with proper safe area handling
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

