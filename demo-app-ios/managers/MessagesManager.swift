//
//  MessagesManager.swift
//  demo-app-ios
//
//  Created by Yurii Zhuk on 22.04.2024.
//

import Foundation
import CoreData
import WebitelSdkIos


class MessagesManager: ObservableObject, DialogListener {
    @Published var messages: [MessageData] = []
    @Published var toast: Toast? = nil
    
    static let shared = MessagesManager()
    
    private var currentDialog: Dialog? = nil
    private let core = CoreDataManager()
    
    private let jwt = "eyJhbGciOiJSUzI1NiIsImtpZCI6Im1YRjdVdzhMb2JOWERUQUVrbVh1ZFEiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJodHRwczovL2FwaS5wb3MuZmhsLndvcmxkIiwiZXhwIjoxNzExOTcyODAwLCJpYXQiOjE3MTEzNjgyOTMsImlpZCI6Imp3dF9tb2JpbGVfZGVtb19jdXN0b21lcl9pZCIsImlzcyI6Imh0dHBzOi8vZGV2LndlYml0ZWwuY29tL3BvcnRhbCIsImp0aSI6IiIsIm5hbWUiOiJZdXJpaSBUZXN0IChKV1QpIiwibmJmIjoxNzExMzY4MjkzLCJwbHRmIjoiTkFUSVZFIiwicm9sZSI6ImNsaWVudCIsInNjb3BlIjpbIm9mZmxpbmVfYWNjZXNzIiwib3BlbmlkIiwicG9zLWNsaWVudCIsInBvcy1jbGllbnQtdW52ZXJpZmllZCJdLCJzdWIiOiI1ZGQ2OTMzOTU3MDUzYTkwYmE3ZGEwYTEzNjI0NDMzZiIsInVpZCI6ImNkNjY5N2Y3LTk4OGUtNDJlNy1hYWFmLWFjYTFiOTJlNGViOSJ9.KJm1lcv_0wfPjUpxBX666Mh0RzAF4xbFobEdkgKZ1-JkTkfMuIFLSZBsQlrFNu1YgCzxXzkXVJamtHaxwKhqwvnxTKOedsEPwx0DjNv1rzqCx6t2lRhyjJsL-EZ0odX-YPHtcn4hkhZ8UJ_0d2tOiHdyxtQbThvYe_RUH6ZxKz2vWhN4kQDHBGQ-UNONclziaoU3FdZW_pb6NI3t4LjLpdSMk1_GA2eovLuWiWEdn6X_FCv_I1aiFP17qHyIzfHd-MD5kCNBns0jFUI1emppCd7cZT8tDc73O-Trcth-FtlKyZhpMlF_jc_lHpIshZTWZkddPEujVRt3JQH9m6X09w"
    
    // Init Webitel library
    private let portalClient = try! PortalClientBuilder(
        address: "grpcs://demo.webitel.com",
        token: "49sFBWUGEtlHz7iTWjIXIgRGnZXQ14dQZOy7fdM8AyffZ3oEQzNC5Noa6Aeem6BAw"
    )
        .logLevel(.trace)
        .setDeviceId("test-ios-device-id")  // UUID().uuidString
        .build()
    
    
    func viewContext() -> NSManagedObjectContext {
        return core.persistentContainer.viewContext
    }
    
    
    // DialogListener.onNewMessage
    // on receive a new message from the server
    func onNewMessage(_ message: Message) {
        core.saveMessage(message: message)
        loadMessages()
    }
    
    
    // load message from local storage
    func loadMessages() {
        DispatchQueue.main.async {
            self.messages = self.core.getAllMessages()
            self.objectWillChange.send()
        }
    }
    
    
    // call when you have a new jwt
    func setToken() {
        portalClient.setAccessToken(token: jwt)
        self.setToast(Toast(
            style: .success,
            message: "JWT Saved."
        ))
    }
    
    
    func getUpdates() {
        findDialog { dialog, error in
            
            // Returns the chat history updates (difference) since offset (state message.id).
            dialog?.getUpdates { r in
                switch r {
                    case .success(let messages):
                        self.setToast(Toast(style: .info, message: "updates - \(messages.count)"))
                    case .failure(let error):
                        self.setToast(Toast(style: .error, message: "getUpdates - \(error)"))
                }
            }
        }
    }
    
    
    func getHistory() {
        findDialog { dialog, error in
            
            //Returns the conversation history, last 50 messages.
            dialog?.getHistory { result in
                switch result {
                    case .success(let messages): // TODO: Save Messages in local storage and update view
                        
                        self.setToast(Toast(style: .info, message: "history - \(messages.count)"))
                        
                    case .failure(let error): // TODO: Handling 401 error: call setAccessToken and try again
                        self.setToast(Toast(style: .error, message: "getHistory - \(error)"))
                        
                }
            }
        }
    }
    
    
    func sendMessage(text: String) {
        let sendId = UUID().uuidString
        let options = Message
            .options()
            .sendId(sendId)
            .withText(text)
        
        let data = self.core.saveMessage(sendId: sendId, text: text, options: options)
        self.loadMessages()
        
        findDialog { dialog, error in
            if dialog != nil {
                self.send(dialog!, options: options, data: data)
                
            } else {
                DispatchQueue.main.async {
                    self.core.messageError(data: data, error: error!)
                }
                self.loadMessages()
            }
        }
    }
    
    
    private func findDialog(completion: @escaping (Dialog?, NSError?) -> Void) {
        if let chat = currentDialog {
            completion(chat, nil)
        } else {
            portalClient.chatClient.getServiceDialog { result in
                switch result {
                    case .success(let newDialog):
                        self.currentDialog = newDialog
                        self.currentDialog?.addListener(listener: self)
                        completion(newDialog, nil)
                        
                    case .failure(let error): // TODO: Handling 401 error: call setAccessToken and try again
                        
                        self.setToast(Toast(style: .error, message: "getServiceDialog - \(error)"))
                        completion(nil, error)
                }
            }
        }
    }
    
    
    private func send(_ chat: Dialog, options: Message.options, data: MessageData) {
        chat.sendMessage(options: options) {r in
            switch r {
                case .success(let message):
                    DispatchQueue.main.async {
                        self.core.messageSent(data: data, message: message)
                    }
                    self.loadMessages()
                    
                case .failure(let error): // TODO: Handling 401 error: call setAccessToken and try again
                    
                    DispatchQueue.main.async {
                        self.core.messageError(data: data, error: error)
                    }
                    self.setToast(Toast(style: .error, message: "sendMessage - \(error)"))
                    self.loadMessages()
            }
        }
    }
    
    
    private func setToast(_ t: Toast) {
        DispatchQueue.main.async {
            self.toast = t
        }
    }
}
