//
//  Toast.swift
//  demo-app-ios
//
//  Created by Yurii Zhuk on 29.03.2024.
//

import Foundation


struct Toast: Equatable {
    var style: ToastStyle
    var message: String
    var duration: Double = 3
    var width: Double = .infinity
}

