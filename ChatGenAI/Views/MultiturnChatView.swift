//
//  MultiturnChatView.swift
//  ChatGenAI
//
//  Created by Gaurav Sharma on 12/02/25.
//

import SwiftUI
import Speech
import PhotosUI


struct MultiturnChatView: View {
    @State var textInput = ""
    @State var chatService = ChatService()
    @State var aiResponse = "Hello! How can I help you today?"
    
    @State private var photoPickerItems = [PhotosPickerItem]()
    @State private var selectedMedia = [Media]()
    @State private var showAttachmentOptions = false
    @State private var showPhotoPicker = false
    @State private var showFilePicker = false
    @State private var showEmptyTextAlert = false
    @State private var loadingMedia = false
    
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @GestureState private var isMicPressed = false
    
    var body: some View {
        VStack {
            // MARK: Animating logo
            Image("ai-final")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .background(Color.yellow)
            Text(aiResponse)
                .font(.callout)
                .fontWeight(.bold)
                .padding()
            
            // MARK: Chat message list
            ScrollViewReader(content: { proxy in
                ScrollView {
                    ForEach(chatService.messages, id:\.self.id) { message in
                        // MARK: Chat message view
                        ChatMessageView(chatMessage: message)
                    }
                }
                .onChange(of: chatService.messages) { _, _ in
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: chatService.loadingResponse) {
                    scrollToBottom(proxy: proxy)
                }
            })
            
            // MARK: Image preview
            if selectedMedia.count > 0 {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 10, content: {
                        if let thumbnail = selectedMedia.last?.thumbnail {
                            Image(uiImage: thumbnail)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 50)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                    })
                }
                .frame(height: 50)
                .padding(.bottom, 8)
            }
            
            // MARK: Input fields
            HStack {
                Button {
                    showAttachmentOptions.toggle()
                } label: {
                    if loadingMedia {
                        GradientProgressView()
                    } else {
                        Image(systemName: "paperclip")
                            .frame(width: 40, height: 25)
                    }
                }
                .disabled(chatService.loadingResponse)
                .confirmationDialog("What would you like to attach?",
                                    isPresented: $showAttachmentOptions,
                                    titleVisibility: .visible) {
                    Button("Images") {
                        showPhotoPicker.toggle()
                    }
                    Button("Documents") {
                        showFilePicker.toggle()
                    }
                }.photosPicker(isPresented: $showPhotoPicker,
                               selection: $photoPickerItems,
                               maxSelectionCount: 2,
                               matching: .any(of: [.images]))
                .onChange(of: photoPickerItems) { oldValue, newValue in
                    Task {
                        loadingMedia.toggle()
                        selectedMedia.removeAll()
                        
                            let item = photoPickerItems.last!
                            do {
                                let (mimeType, data, thumbnail) = try await MediaService().processPhotoPickerItem(for: item)
                                selectedMedia.append(.init(mimeType: mimeType, data: data, thumbnail: thumbnail))
                            } catch {
                                print(error.localizedDescription)
                            }
                        
                        loadingMedia.toggle()
                    }
                }
                .fileImporter(isPresented: $showFilePicker,
                              allowedContentTypes: [.text, .pdf],
                              allowsMultipleSelection: true) { result in
                    selectedMedia.removeAll()
                    loadingMedia.toggle()
                    
                    switch result {
                    case .success(let urls):
                        for url in urls {
                            do {
                                let (mimeType, data, thumbnail) = try MediaService().processDocumentItem(for: url)
                                selectedMedia.append(.init(mimeType: mimeType, data: data, thumbnail: thumbnail))
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    case .failure(let error):
                        print("Failed to import file(s): \(error.localizedDescription)")
                    }
                    
                    loadingMedia.toggle()
                }
                
                if chatService.loadingResponse {
                    ZStack {
                        GradientProgressView()
                    }
                } else {
                    Button {
                        sendMessage(text: textInput)
                        hideKeyboard()
                    } label: {
                        Image(systemName: "paperplane.fill")
                    }
                    .frame(width: 30)
                }
                TextField("Enter a message...", text: $textInput)
                    .textFieldStyle(.roundedBorder)
                    .foregroundStyle(.white)
                    .alert("Please enter a message", isPresented: $showEmptyTextAlert, actions: {})
                // 🎤 Mic Button
                Button(action: {}, label: {
                    Image(systemName: "mic.fill")
                        .foregroundColor(isMicPressed ? .red : .white)
                        .frame(maxWidth: .infinity)
                })
                .frame(width: 25, height: 25)
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.1)
                        .updating($isMicPressed) { currentState, state, _ in
                            state = currentState
                        }
                        .onEnded { _ in
                            try? speechRecognizer.startRecording()
                        }
                )
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { _ in
                            speechRecognizer.stopRecording()
                            textInput = speechRecognizer.transcribedText
                        }
                )
                
            }
        }
        .onAppear {
            SFSpeechRecognizer.requestAuthorization { status in
                // Handle authorization status if needed
            }
        }
        .foregroundStyle(.white)
        .padding()
        .background {
            // MARK: Background
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.black, Color.blue]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .ignoresSafeArea()
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let recentMessage = chatService.messages.last else { return }
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.5), {
                proxy.scrollTo(recentMessage.id, anchor: .bottom)
            })
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // MARK: Fetch response
    private func sendMessage(text: String) {
        guard !textInput.isEmpty else {
            showEmptyTextAlert.toggle()
            return
        }
        Task {
            let chatMedia = selectedMedia
            selectedMedia.removeAll()
            await chatService.sendMessage(message: textInput, media: chatMedia)
            textInput = ""
        }
    }
}

#Preview {
    MultiturnChatView()
}

