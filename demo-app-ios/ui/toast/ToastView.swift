//
//  ToastView.swift
//  demo-app-ios
//
//  Created by Yurii Zhuk on 29.03.2024.
//

import Foundation
import SwiftUI

struct ToastView: View {
    
    var style: ToastStyle
    var message: String
    var width = CGFloat.infinity
    var onCancelTapped: (() -> Void)
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: style.iconFileName)
                .foregroundColor(style.themeColor)
            Text(message)
                .font(Font.caption)
                .foregroundColor(Color("toastForeground"))
            
            Spacer(minLength: 10)
            
            Button {
                onCancelTapped()
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(style.themeColor)
            }
        }
        .padding()
        .frame(minWidth: 0, maxWidth: width)
        .background(Color("toastBackground"))
        .cornerRadius(8)
        //    .overlay(
        //      RoundedRectangle(cornerRadius: 8)
        //        .opacity(0.6)
        //    )
        .overlay( /// apply a rounded border
            RoundedRectangle(cornerRadius: 8)
                .stroke(style.themeColor)
            // .opacity(0.9)
        )
        //.opacity(0.9)
        .padding(.horizontal, 16)
    }
}

