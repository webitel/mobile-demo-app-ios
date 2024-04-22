//
//  CoreDataManager.swift
//  demo-app-ios
//
//  Created by Yurii Zhuk on 22.03.2024.
//

import Foundation
import CoreData
import WebitelSdkIos

class CoreDataManager {
    
    let persistentContainer: NSPersistentContainer
    private let fetchRequest: NSFetchRequest<MessageData> = MessageData.fetchRequest()
    private var dateCreated = NSSortDescriptor(key:"dateCreated", ascending: true)
    
    
    init() {
        persistentContainer = NSPersistentContainer(name: "DemoCoreDataModel")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data Store failed \(error.localizedDescription)")
            }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }
    
    
    func getAllMessages() -> [MessageData] {
        fetchRequest.sortDescriptors = [dateCreated]
        
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("getAllMessages - \(error.localizedDescription)")
            return []
        }
    }
    
    
    func saveMessages(messages: [Message]) {
        for item in messages {
            let md = MessageData(context: persistentContainer.viewContext)
            md.uuid = if item.sendId.isEmpty { UUID().uuidString } else { item.sendId }
            md.id = item.id
            md.dateCreated = NSNumber(value: item.date)
            md.isIncoming = item.isIncoming
            md.sent = true
            md.authorName = item.from.name
            md.authorType = item.from.type
            md.body = item.text
            do {
                try persistentContainer.viewContext.save()
            } catch {
                print("failed to save message - \(error.localizedDescription)")
            }
        }
    }
    
    
    func saveMessage(message: Message) {
        print(message)
        let md = MessageData(context: persistentContainer.viewContext)
        md.uuid = if message.sendId.isEmpty {UUID().uuidString}else {message.sendId}
        md.id = message.id
        md.dateCreated = (Date().currentTimeMillis()) as NSNumber
        md.isIncoming = message.isIncoming
        md.sent = true
        md.authorName = message.from.name
        md.authorType = message.from.type
        md.body = message.text
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("failed to save message - \(error.localizedDescription)")
        }
    }
    
    
    func messageSent(data: MessageData, message: Message) {
        data.sent = true
        
        if message.id > 0 {
            data.id = message.id
        }
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("failed to save message - \(error.localizedDescription)")
        }
    }
    
    
    func messageError(data: MessageData, error: NSError) {
        data.errorCode = Int32(error.code)
        data.errorMessage = error.description
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("failed to save message - \(error.localizedDescription)")
        }
    }
    
    
    func saveMessage(sendId: String, text: String, options: Message.options) -> MessageData {
        let md = MessageData(context: persistentContainer.viewContext)
        md.uuid = sendId
        md.setNilValueForKey("id")
        md.dateCreated = (Date().currentTimeMillis()) as NSNumber
        md.isIncoming = false
        md.sent = false
        md.body = text
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("failed to save message - \(error.localizedDescription)")
        }
        return md
    }
}


extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
