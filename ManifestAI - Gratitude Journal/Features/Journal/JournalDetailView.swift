import SwiftUI

struct JournalDetailView: View {
    let entry: JournalEntry
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Theme.Colors.mysticalGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                        .font(Theme.Fonts.display(size: 14, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(.white.opacity(0.6))
                        .textCase(.uppercase)
                    
                    Spacer()
                    
                    // Invisible spacer for alignment
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 24)
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Title / Status
                        HStack(spacing: 8) {
                            Image(systemName: entry.isElevated ? "sparkles" : "pencil")
                                .foregroundStyle(Theme.Colors.primary)
                            
                            Text(entry.isElevated ? "Elevated Entry" : "Daily Gratitude")
                                .font(Theme.Fonts.display(size: 16, weight: .semibold))
                                .foregroundStyle(Theme.Colors.primary)
                                .tracking(1)
                        }
                        
                        // Content
                        Text(entry.elevatedText ?? entry.rawText)
                            .font(.system(size: 20, weight: .light, design: .serif))
                            .foregroundStyle(.white.opacity(0.95))
                            .lineSpacing(8)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Original text (if elevated) - optional context
                        if entry.isElevated {
                            VStack(alignment: .leading, spacing: 12) {
                                Divider()
                                    .background(Color.white.opacity(0.2))
                                
                                Text("Original Thought")
                                    .font(Theme.Fonts.display(size: 12, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.4))
                                    .textCase(.uppercase)
                                    .tracking(1)
                                
                                Text(entry.rawText)
                                    .font(.system(size: 16, weight: .light, design: .serif))
                                    .foregroundStyle(.white.opacity(0.5))
                                    .italic()
                            }
                            .padding(.top, 24)
                        }
                    }
                    .padding(24)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

