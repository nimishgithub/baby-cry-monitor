//
//  BabyCryEventViewModel.swift
//  CodingAssignment2021
//
//  Created by Nimish Sharma on 12/20/21.
//

import Foundation
import SoundAnalysis
import SwiftUI

class BabyCryEventViewModel: ObservableObject {
    
    private let audioManager = AudioManager.shared

    @Published private(set) var babyCryEvents: [BabyCryEvent] = []
    
    
    //    MARK: Public Methods
    public func startListeningToUpdates() {
        audioManager.eventListener = eventOccured
        audioManager.start()
    }
    
    public func stopListeningToUpdates() {
        audioManager.stop()
    }
    
    public func addTestData(_ eventInfo: BabyCryEvent) {
        babyCryEvents.append(eventInfo)
    }
    
    public func eventOccured(eventIdentifier: String, confidence: Double, timestamp: Double) {
        guard eventIdentifier == BABY_CRY_CLASSIFICATION_IDENTIFIER else {return}
        print("Detected cry with confidence: ", confidence, "Time: ", timestamp)
        guard (confidence * 100) >= CONFIDENCE_LEVEL_THRESHOLD else {return}
        let event = BabyCryEvent(title: "Baby Crying...", timestamp: timestamp)
        if babyCryEvents.isEmpty {
            self.babyCryEvents.append(event)
        } else if let lastEvent = babyCryEvents.last, (timestamp - lastEvent.timestamp) > 20 {
            self.babyCryEvents.append(event)
        }
    }
    
}





