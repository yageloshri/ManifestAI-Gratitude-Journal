import SwiftUI

// MARK: - Step A: Energy Selection
struct EnergySelectionStepView: View {
    @ObservedObject var viewModel: VisionBoardViewModel
    @State private var titleAppear = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with decorative elements
            VStack(spacing: 16) {
                // Decorative sparkle
                Image(systemName: "sparkles")
                    .font(.system(size: 24))
                    .foregroundStyle(Color(hex: "FFD700"))
                    .symbolEffect(.pulse, options: .repeating)
                    .opacity(titleAppear ? 1 : 0)
                    .scaleEffect(titleAppear ? 1 : 0.5)
                
                Text("WHAT ENERGY ARE YOU\nCALLING IN?")
                    .font(.system(size: 18, weight: .bold))
                    .tracking(3)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color(hex: "FFD700").opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .shadow(color: Color(hex: "FFD700").opacity(0.3), radius: 10, x: 0, y: 4)
                    .opacity(titleAppear ? 1 : 0)
                    .offset(y: titleAppear ? 0 : -20)
                
                // Subtle subtitle
                Text("Select the vibes you want to manifest")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.white.opacity(0.5))
                    .opacity(titleAppear ? 1 : 0)
            }
            .padding(.top, 60)
            .padding(.bottom, 32)
            
            // Grid of Energies with ScrollView for better UX
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 16)], spacing: 16) {
                    ForEach(viewModel.availableEnergies, id: \.0) { energy in
                        EnergyGlassChip(
                            title: energy.0,
                            icon: energy.1,
                            isSelected: viewModel.selectedEnergies.contains(energy.0)
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.toggleEnergy(energy.0)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 120) // Space for button
            }
            
            Spacer()
            
            // Bottom gradient overlay for button
            if !viewModel.selectedEnergies.isEmpty {
                VStack(spacing: 0) {
                    LinearGradient(
                        colors: [Color(hex: "050510").opacity(0), Color(hex: "050510")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 60)
                    
                    VStack(spacing: 12) {
                        // Selection count indicator
                        HStack(spacing: 6) {
                            ForEach(0..<min(viewModel.selectedEnergies.count, 5), id: \.self) { _ in
                                Circle()
                                    .fill(Color(hex: "FFD700"))
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .transition(.scale.combined(with: .opacity))
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                viewModel.advanceToGuidance()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Text("CONTINUE")
                                    .font(.system(size: 15, weight: .bold))
                                    .tracking(2.5)
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundStyle(.black)
                            .padding(.vertical, 18)
                            .frame(maxWidth: .infinity)
                            .background(
                                ZStack {
                                    Color(hex: "FFD700")
                                    
                                    // Shine effect
                                    LinearGradient(
                                        colors: [.white.opacity(0.3), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                }
                            )
                            .clipShape(Capsule())
                            .shadow(color: Color(hex: "FFD700").opacity(0.5), radius: 20, x: 0, y: 10)
                        }
                        .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 40)
                    .background(Color(hex: "050510"))
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                titleAppear = true
            }
        }
    }
}

struct EnergyGlassChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: isSelected ? .semibold : .regular))
                    .symbolRenderingMode(.hierarchical)
                
                Text(title.uppercased())
                    .font(.system(size: 11, weight: isSelected ? .bold : .semibold))
                    .tracking(1.2)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 8)
            .foregroundStyle(isSelected ? Color.black : Color.white.opacity(0.9))
            .background(
                ZStack {
                    if isSelected {
                        // Selected state with gradient
                        LinearGradient(
                            colors: [Color(hex: "FFD700"), Color(hex: "FFC700")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // Shine overlay
                        LinearGradient(
                            colors: [.white.opacity(0.4), .clear],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    } else {
                        // Glass effect for unselected
                        Color.white.opacity(0.05)
                        
                        // Subtle gradient
                        LinearGradient(
                            colors: [.white.opacity(0.08), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: isSelected 
                                ? [Color(hex: "FFD700"), Color(hex: "FFC700")] 
                                : [Color.white.opacity(0.25), Color.white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? Color(hex: "FFD700").opacity(0.5) : Color.clear,
                radius: isSelected ? 12 : 0,
                x: 0,
                y: isSelected ? 8 : 0
            )
            .scaleEffect(isPressed ? 0.95 : (isSelected ? 1.05 : 1.0))
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Step B: Guidance
struct GuidanceStepView: View {
    @ObservedObject var viewModel: VisionBoardViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(Color(hex: "FFD700"))
                .symbolEffect(.pulse, options: .repeating)
            
            Text(viewModel.guidanceText)
                .font(.custom("Times New Roman", size: 28)) // Mystical font feel
                .italic()
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(.horizontal, 32)
                .lineSpacing(8)
                .shadow(color: Color(hex: "FFD700").opacity(0.3), radius: 10)
            
            Text("Take a moment to find photos that match this energy.")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    viewModel.advanceToEditor()
                }
            }) {
                Text("I HAVE MY PHOTOS READY")
                    .font(.system(size: 14, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(.black)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "FFD700"))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}





