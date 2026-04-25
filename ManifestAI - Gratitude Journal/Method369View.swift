import SwiftUI

struct Method369View: View {
    // MARK: - Storage
    @AppStorage("hasOnboarded369") private var hasOnboarded = false
    @AppStorage("manifestationGoal") private var manifestationGoal = ""
    
    var body: some View {
        NavigationView {
            if !hasOnboarded {
                Onboarding369View(hasOnboarded: $hasOnboarded, manifestationGoal: $manifestationGoal)
            } else {
                Daily369View(manifestationGoal: manifestationGoal)
            }
        }
    }
}

// MARK: - Onboarding View
struct Onboarding369View: View {
    @Binding var hasOnboarded: Bool
    @Binding var manifestationGoal: String
    @State private var tempGoal = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("The 369 Method")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("How it works")
                        .font(.headline)
                    
                    Text("Inspired by Nikola Tesla's theory on the divine numbers 3, 6, and 9, this method helps you align with your desires.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .top) {
                        Text("3")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .frame(width: 40)
                        Text("Write your desire 3 times in the morning to set your intention.")
                    }
                    
                    HStack(alignment: .top) {
                        Text("6")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                            .frame(width: 40)
                        Text("Write it 6 times in the afternoon to amplify it.")
                    }
                    
                    HStack(alignment: .top) {
                        Text("9")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                            .frame(width: 40)
                        Text("Write it 9 times in the evening to seal it into your subconscious.")
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("What do you want to manifest?")
                        .font(.headline)
                    
                    TextField("I am so happy and grateful now that...", text: $tempGoal)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 8)
                    
                    Text("Write it in the present tense, as if you already have it.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                Button(action: {
                    manifestationGoal = tempGoal
                    withAnimation {
                        hasOnboarded = true
                    }
                }) {
                    Text("Start My Journey")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(tempGoal.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(tempGoal.isEmpty)
                .padding(.top, 16)
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Daily View
struct Daily369View: View {
    let manifestationGoal: String
    @State private var currentSession: Session = .morning
    
    enum Session: String, CaseIterable {
        case morning = "Morning (3x)"
        case afternoon = "Afternoon (6x)"
        case evening = "Evening (9x)"
        
        var count: Int {
            switch self {
            case .morning: return 3
            case .afternoon: return 6
            case .evening: return 9
            }
        }
    }
    
    var body: some View {
        VStack {
            Text("Your Manifestation")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(manifestationGoal)
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding()
            
            Picker("Session", selection: $currentSession) {
                ForEach(Session.allCases, id: \.self) { session in
                    Text(session.rawValue).tag(session)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(0..<currentSession.count, id: \.self) { index in
                        HStack {
                            Text("\(index + 1).")
                                .foregroundColor(.secondary)
                                .frame(width: 30)
                            
                            TextField("Type here...", text: .constant("")) // In a real app, bind to an array
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                }
                .padding()
            }
            
            Spacer()
        }
        .navigationTitle("369 Method")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct Method369View_Previews: PreviewProvider {
    static var previews: some View {
        Method369View()
    }
}

