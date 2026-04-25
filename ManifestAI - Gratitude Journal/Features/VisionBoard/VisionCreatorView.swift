import SwiftUI
import SwiftData

struct VisionCreatorView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = VisionBoardViewModel()
    
    var boardToEdit: VisionBoardEntity?
    
    var body: some View {
        ZStack {
            // Background
            ZStack {
                Color(hex: "050510").ignoresSafeArea()
                RadialGradient(
                    colors: [Color(hex: "1a1147").opacity(0.6), Color(hex: "050510")],
                    center: .center,
                    startRadius: 0,
                    endRadius: 600
                ).ignoresSafeArea()
            }
            
            // Content
            switch viewModel.currentStep {
            case .energySelection:
                EnergySelectionStepView(viewModel: viewModel)
                    .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading)))
            case .guidance:
                GuidanceStepView(viewModel: viewModel)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .editor:
                VisionBoardEditorView(viewModel: viewModel)
                    .transition(.move(edge: .bottom))
            }
            
            // Close Button (Only for first two steps)
            if viewModel.currentStep != .editor {
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            ZStack {
                                // Glassmorphism background
                                Circle()
                                    .fill(Color.white.opacity(0.08))
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .opacity(0.5)
                                    )
                                
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.9))
                            }
                            .frame(width: 36, height: 36)
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 56) // Increased to avoid overlapping with title
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut, value: viewModel.currentStep)
        .onAppear {
            if let board = boardToEdit {
                viewModel.loadBoard(board)
            }
        }
    }
}
