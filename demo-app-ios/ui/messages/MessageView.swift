//
//  MessageView.swift
//  demo-app-ios
//
//  Created by Yurii Zhuk on 29.03.2024.
//

import Foundation
import SwiftUI


struct MessageView : View {
    @ObservedObject var message: MessageData
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            
            if message.isIncoming {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40, alignment: .center)
                    .cornerRadius(20)
                
            } else {
                Spacer()
            }
            
            VStack(alignment: message.isIncoming ? .leading : .trailing) {
                Text(message.body ?? "")
                    .padding(10)
                    .foregroundColor(message.isIncoming ? Color.black : Color.white)
                    .background(message.isIncoming ? Color(UIColor.systemGray6) : Color.blue)
                    .cornerRadius(10)
                
                if let err = message.errorMessage {
                    Text("❌ 10:23")
                        .foregroundColor(Color.black)
                    Text("\(err)")
                        .foregroundColor(Color.red)
                    
                } else {
                    
                    HStack {
                        if !message.sent {
                            ProgressView()
                                .frame(height: 10)
                        }
                        Text("10:23")
                            .foregroundColor(Color.black)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}

