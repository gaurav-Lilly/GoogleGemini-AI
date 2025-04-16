//
//  ContentView.swift
//  ChatGenAI
//
//  Created by Gaurav Sharma on 08/02/25.
//

import SwiftUI
import GoogleGenerativeAI

struct ContentView: View {
    @State var textInput = ""
    @State var aiResponse = "Hello! How can I help you today?"
    @State var isLoading = false
    
    
    let model = GenerativeModel(name: "gemini-1.5-flash-latest", apiKey: "YOUR_API_KEY_HERE")
    
    var body: some View {
        VStack {
            Image("ai-final")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .padding()
            if isLoading {
                GradientProgressView()
            }
            ScrollView {
                Text(aiResponse)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            
            HStack {
                TextField("Enter a message", text: $textInput)
                    .textFieldStyle(.roundedBorder)
                    .foregroundStyle(.white)
                Button(action: sendMessage, label: {
                    Image(systemName: "paperplane.fill")
                })
            }
        }
        .foregroundStyle(.white)
        .padding()
        .background {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.black, Color.blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
            }.ignoresSafeArea()
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func sendMessage() {
        hideKeyboard()
        isLoading = true
        aiResponse = ""
        
        Task {
            do {
                let response = try await model.generateContent(textInput)
                
                guard let text = response.text else  {
                    textInput = "Sorry, I could not process that.\nPlease try again."
                    isLoading = false
                    return
                }
                
                textInput = ""
                aiResponse = text
                isLoading = false
                
            } catch {
                aiResponse = "Something went wrong!\n\(error.localizedDescription)"
                isLoading = false
            }
        }
    }
}

#Preview {
    ContentView()
}
