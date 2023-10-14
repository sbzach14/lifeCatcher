//
//  ShowRecordHistoryView.swift
//  Shuffle
//
//  Created by Zhangyi Chen on 8/6/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI

struct ShowRecordHistoryView: View {
    var cls: String
    
    // Read the recordHistory.json file and get the corresponding value for the cls
    private var imagePaths: [String] {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("recordHistory.json")
        do {
            let jsonData = try Data(contentsOf: fileURL)
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            
            if let recordData = jsonObject as? [String: [String]], let images = recordData[cls] {
                return images
            }
        } catch {
            print("Error reading recordHistory.json: \(error)")
        }
        return []
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(imagePaths, id: \.self) { imageName in
                        if let imagePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("recordHistory").appendingPathComponent(imageName).path {
                            if let image = UIImage(contentsOfFile: imagePath) {
                                Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100) // 设置图片的大小
                                .cornerRadius(10)
                        } else {
                            Color.black // 如果加载图片失败，显示黑色背景
                                .frame(width: 100, height: 100)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(
            Image("bg")
                .resizable()
                .scaledToFill()
        )
        .navigationTitle(cls)
    }

}

struct ShowRecordHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ShowRecordHistoryView(cls: "person")
    }
}

