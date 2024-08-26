import SwiftUI

struct HistoryItemView: View {
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
            // print("Error reading recordHistory.json: \(error)")
        }
        return []
    }
    
    var body: some View {
        ScrollView {
            Spacer()
            VStack {
                    ForEach(imagePaths, id: \.self) { imageName in
                        HStack{
                            if let imagePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("recordHistory").appendingPathComponent(imageName).path {
                                if let image = UIImage(contentsOfFile: imagePath) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 150, height: 150) // 设置图片的大小
                                        .cornerRadius(10)
                                } else {
                                    Color.black // 如果加载图片失败，显示黑色背景
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(10)
                                }
                            }
                           
                            Text(imageName)
                    }
                        
                    Divider()
                }
            }
            .padding(16)
        }
        .background(
            Image("Newbg2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationTitle(cls)
    }

}
