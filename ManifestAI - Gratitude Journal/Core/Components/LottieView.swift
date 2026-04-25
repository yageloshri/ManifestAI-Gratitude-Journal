// LottieView.swift
// SwiftUI wrapper for Lottie animations.
// Includes explicit teardown to prevent memory growth when screens are created/destroyed repeatedly.
import SwiftUI
import Lottie
import UIKit

struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    let animationSpeed: CGFloat
    let tintColor: Color?
    
    init(name: String, loopMode: LottieLoopMode = .loop, animationSpeed: CGFloat = 1.0, tintColor: Color? = nil) {
        self.name = name
        self.loopMode = loopMode
        self.animationSpeed = animationSpeed
        self.tintColor = tintColor
    }
    
    func makeUIView(context: Context) -> UIView {
        let parentView = UIView()
        
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed
        animationView.contentMode = .scaleAspectFit
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.backgroundBehavior = .pauseAndRestore
        
        if let tintColor = tintColor {
            let color = UIColor(tintColor)
            let r = Double(color.cgColor.components?[0] ?? 0)
            let g = Double(color.cgColor.components?[1] ?? 0)
            let b = Double(color.cgColor.components?[2] ?? 0)
            let a = Double(color.cgColor.alpha)
            
            let lottieColor = LottieColor(r: r, g: g, b: b, a: a)
            let colorProvider = ColorValueProvider(lottieColor)
            
            // Apply to all Color properties (Stroke and Fill)
            let keypath = AnimationKeypath(keypath: "**.Color")
            animationView.setValueProvider(colorProvider, keypath: keypath)
        }
        
        parentView.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: parentView.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
            animationView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor)
        ])
        
        animationView.play()
        
        return parentView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // No update logic needed for static looping animation
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        // Stop and remove any Lottie animation views to avoid retained layers/animations.
        for subview in uiView.subviews {
            if let animationView = subview as? LottieAnimationView {
                animationView.stop()
                animationView.removeFromSuperview()
            } else {
                subview.removeFromSuperview()
            }
        }
        uiView.layer.removeAllAnimations()
    }
}
