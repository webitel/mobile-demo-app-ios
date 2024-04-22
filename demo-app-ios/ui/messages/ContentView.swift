//
//  ContentView.swift
//  demo-app-ios
//
//  Created by Yurii Zhuk on 29.03.2024.
//

import SwiftUI
import Combine


struct ContentView: View {
    @ObservedObject var messagesManager = MessagesManager.shared
    @State var newMessage: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Button(action: getUpdates)   {
                    Text("get Updates")
                }
                Button(action: setToken)   {
                    Text("set JWT")
                }
                Button(action: getHistory)   {
                    Text("get History")
                }
            }
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(messagesManager.messages, id: \.self) { message in
                            MessageView(message: message)
                                .id(message)
                        }
                    }
                    .onChange(of: messagesManager.messages.count) { _ in
                        withAnimation {
                            proxy.scrollTo(messagesManager.messages[messagesManager.messages.count - 1])
                        }
                    }
                    
                    .onAppear {
                        messagesManager.loadMessages()
                        withAnimation {
                            proxy.scrollTo(messagesManager.messages.last, anchor: .bottom)
                        }
                    }
                    
                }
                
                HStack {
                    TextField("Send a message", text: $newMessage)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(action: sendMessage)   {
                        Image(systemName: "paperplane")
                    }
                    
                }
                .padding()
            }
            
        }.toastView(toast: $messagesManager.toast)
    }
    
    
    func setToken() {
        messagesManager.setToken()
    }
    
    
    func sendMessage() {
        if !newMessage.isEmpty{
            messagesManager.sendMessage(text: newMessage)
            newMessage = ""
        }
    }
    
    
    func getUpdates() {
        messagesManager.getUpdates()
    }
    
    
    func getHistory() {
        messagesManager.getHistory()
    }
}



#Preview {
    ContentView()
}
