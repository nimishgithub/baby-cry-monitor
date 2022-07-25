//
//  BabyCryEvent.swift
//  CodingAssignment2021
//
//  Created by Nimish Sharma on 12/20/21.
//

import Foundation

struct BabyCryEvent: Identifiable {
    let id = UUID()
    let title: String
    let timestamp: Double
    
    var displayTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm:ss a"
        return dateFormatter.string(from: Date(timeIntervalSince1970: timestamp))
    }
}
