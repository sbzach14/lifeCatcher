

import Foundation
import CoreML



// Helper method to read config.json and return the data as a dictionary
func createParaJSON() {
    // Create the config dictionary with default values
    let paraDict: [String: String] = [
        "activeTime": "",
        "uniqueID": AuthManager.getUniqueID()!,
        "authKey": ""
    ]

    do {
        // Convert the dictionary to JSON Data
        let jsonData = try JSONSerialization.data(withJSONObject: paraDict, options: .prettyPrinted)

        // Get the Documents directory path in the app's sandbox
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        // Create the config.json file URL
        let fileURL = documentsURL.appendingPathComponent("para.json")

        // Check if config.json already exists
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            // Write the JSON Data to the config.json file
            try jsonData.write(to: fileURL)
            // print("para.json file created successfully")
        } else {
            // print("para.json file already exists, skipping write operation.")
        }


    } catch {
        // print("Error creating the para.json file: \(error)")
    }
}


public func readParaJSON() -> [String: String]? {
    do {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("para.json")

        let jsonData = try Data(contentsOf: fileURL)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])

        if let paraData = jsonObject as? [String: String] {
            return paraData
        }
    } catch {
        // print("Error reading para.json: \(error)")
    }
    return nil
}


func createConfigJSON() {
    // Create the config dictionary with default values
    
    let intDict : [String: Int] = [
        "volumeUp": 0,
        "volumeDown": 0
    ]
    
    let floatDict : [String: Float] = [
        "volumeValue": 0,
        "zoomFactor": 0,
        "focusFactor": 0.65
    ]
    
    let boolDict: [String: Bool] = [
        "isBlack": false,
        "isMute": false,
        "isBackCamera": true,
        "isCameraHorizon": true,
        "isRemote": true,
        "isAutoFocus": true
    ]
    
    let configDict: [String: Any] = [
        "Int": intDict,
        "Float": floatDict,
        "Bool": boolDict
    ]
    

    do {
        // Convert the dictionary to JSON Data
        let jsonData = try JSONSerialization.data(withJSONObject: configDict, options: .prettyPrinted)

        // Get the Documents directory path in the app's sandbox
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        // Create the config.json file URL
        let fileURL = documentsURL.appendingPathComponent("config.json")

        // Check if config.json already exists
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            // Write the JSON Data to the config.json file
            try jsonData.write(to: fileURL)
            // print("config.json file created successfully")
        } else {
            // print("config.json file already exists, skipping write operation.")
        }


    } catch {
        // print("Error creating the config.json file: \(error)")
    }
}


public func readConfigJSON() -> [String: Any]? {
    do {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("config.json")

        let jsonData = try Data(contentsOf: fileURL)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])

        if let configData = jsonObject as? [String: Any] {
            return configData
        }
    } catch {
        // print("Error reading config.json: \(error)")
    }
    return nil
}



func createRecordHistoryJSON() {
    // 获取resnet MLModel文件的URL
    guard let modelURL = Bundle.main.url(forResource: "cls_main", withExtension: "mlmodelc") else {
        // print("找不到MLModel文件")
        return
    }
    
    do {
        // Parse the MLModel file to get the model description
        let model = try MLModel(contentsOf: modelURL)
        
        let modelDescription = model.modelDescription
        // Create an empty record dictionary
        var recordDict: [String: [String]] = [:]

        // Get all class labels and initialize corresponding empty string lists
        if let classLabels = modelDescription.classLabels as? [String] {
            for key in classLabels {
                var resultString = key
                if let firstCommaIndex = key.firstIndex(of: ","){
                    let substring = key[..<firstCommaIndex]
                    resultString = String(substring)
                }
                recordDict[resultString] = []
            }
            
        }
        
        // Get the Documents directory path in the app's sandbox
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        

        // Convert the dictionary to JSON Data
        let jsonData = try JSONSerialization.data(withJSONObject: recordDict, options: .prettyPrinted)

        // Create the recordHistory.json file URL
        let fileURL = documentsURL.appendingPathComponent("recordHistory.json")
        
        // Check if config.json already exists
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            // Write the JSON Data to the recordHistory.json file
            try jsonData.write(to: fileURL)
            // print("recordHistory.json file created successfully")
        } else {
            // print("recordHistory.json file already exists, skipping write operation.")
        }
        
        // print("recordHistory.json file and directories created successfully")
        
        
        // Create the recordHistory directory URL
        let recordHistoryURL = documentsURL.appendingPathComponent("recordHistory")

        
        // Create the recordHistory directory if it doesn't exist
        try FileManager.default.createDirectory(at: recordHistoryURL, withIntermediateDirectories: true, attributes: nil)

    } catch {
        // print("Error creating the recordHistory.json file: \(error)")
    }
}

public func readRecordHistoryJSON() -> [String: [String]]? {
    do {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("recordHistory.json")

        let jsonData = try Data(contentsOf: fileURL)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])

        if let recordHistroyData = jsonObject as? [String: [String]] {
            return recordHistroyData
        }
    } catch {
        // print("Error reading recordHistory.json: \(error)")
    }
    return nil
}
