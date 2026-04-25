import SwiftUI

struct Manifest369OnboardingView: View {
    @ObservedObject var viewModel: Manifest369ViewModel
    @State private var currentPage = 0
    @State private var affirmationText = ""
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "0F0520")
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                // Page 1: Introduction
                onboardingPage(
                    title: "The 369 Method",
                    description: "Inspired by Nikola Tesla, who believed the numbers 3, 6, and 9 hold the key to the universe. This powerful manifestation technique uses these divine numbers to amplify your intentions.",
                    imageName: "sparkles",
                    tag: 0
                )
                
                // Page 2: How it Works
                onboardingPage(
                    title: "How it Works",
                    description: "Morning: Write your affirmation 3 times.\nAfternoon: Write it 6 times.\nEvening: Write it 9 times.\n\nConsistency and feeling the emotion of already having your desire is key.",
                    imageName: "clock.arrow.circlepath",
                    tag: 1
                )
                
                // Page 3: Set Intention
                inputPage
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            // Navigation Buttons
            VStack {
                Spacer()
                
                HStack {
                    if currentPage < 2 {
                        Button("Skip") {
                            withAnimation {
                                currentPage = 2
                            }
                        }
                        .foregroundColor(.white.opacity(0.6))
                        .padding()
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            HStack {
                                Text("Next")
                                Image(systemName: "arrow.right")
                            }
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "0F0520"))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "FFD700"))
                            )
                        }
                        .padding()
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    private func onboardingPage(title: String, description: String, imageName: String, tag: Int) -> some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: imageName)
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "FFD700"))
                .padding()
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 160, height: 160)
                )
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 32)
                    .lineSpacing(4)
            }
            
            Spacer()
            Spacer()
        }
        .tag(tag)
    }
    
    private var inputPage: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("Set Your Intention")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("What do you want to manifest? Write it in the present tense, as if you already have it.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 32)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                TextEditor(text: $affirmationText)
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .padding()
                    .frame(height: 150)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "FFD700").opacity(0.3), lineWidth: 1)
                            )
                    )
                    .overlay(
                        Group {
                            if affirmationText.isEmpty {
                                Text("e.g., I am so happy and grateful now that I am earning $10,000 a month...")
                                    .foregroundColor(.white.opacity(0.3))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 24)
                                    .allowsHitTesting(false)
                            }
                        },
                        alignment: .topLeading
                    )
            }
            .padding(.horizontal, 24)
            
            Button(action: completeOnboarding) {
                Text("Start Manifesting")
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "0F0520"))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(affirmationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color(hex: "FFD700"))
                    )
            }
            .disabled(affirmationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 50)
            
            Spacer()
        }
    }
    
    private func completeOnboarding() {
        viewModel.updateAffirmation(affirmationText)
        viewModel.completeOnboarding()
    }
}




