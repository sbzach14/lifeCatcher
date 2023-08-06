//
//  RecordHistoryViewModel.swift
//  Shuffle
//
//  Created by Zhangyi Chen on 8/6/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

class RecordHistoryViewModel: ObservableObject {
    @Published var isActive: Bool = false
    @Published var recordHistoryData : [String:[String]]

    init() {
        // Load data from config.json
        if let configData = readConfigJSON() {
            self.isActive = configData["isActive"]!
        } else {
            self.isActive = false
        }
        
        recordHistoryData = readRecordHistoryJSON()!
    }

}


