

import SwiftUI

struct MainMenuView: View {

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Spacer()
                    
                    // Title Above Custom Image
                    VStack(alignment: .leading) {
                        Text("最新美图")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.leading)
                        
                        Image("sampleImage") // Replace "customImageName" with your image name
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200) // Adjust the size as needed
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.3)))
                    }
                    .padding(.bottom, 20) // Add some spacing between the image and the grid
                    
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            
                            NavigationLink(
                                destination: VisionObjectRecognitionView()
                            ) {
                                VStack {
                                    Image(systemName: "camera") // Replace with your custom icon
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                    Text("开始记录")
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.8)))
                            }
                            
                            NavigationLink(
                                destination: RecordHistoryView()
                            ) {
                                VStack {
                                    Image(systemName: "clock") // Replace with your custom icon
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                    Text("历史记录")
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.green.opacity(0.8)))
                            }
                            
                            NavigationLink(
                                destination: InfoView()
                            ) {
                                VStack {
                                    Image(systemName: "info.circle") // Replace with your custom icon
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                    Text("使用信息")
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.orange.opacity(0.8)))
                            }
                            
                            // Add another NavigationLink here if needed for the 4th item in the grid
                        }
                        .padding()
                    }
                }
            }
            .background(
                Image("Newbg2")
                    .resizable()
                    .scaledToFill()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("lifeCatcherTitle")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40) // Adjust the height as needed
                }
            }
        }
    }
}


struct SingleIconView: View{
    var index: Int
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(5)
                .shadow(radius: 2)
                .frame(width: 27, height: 27)
            Text(ClassifierSettingArgs.singlefeatureLabelDic[index]!)
                .font(.system(size: 10)).foregroundColor(Color.black)
        }
    }
}

extension View {
    func bubbleBackground() -> some View {
        self.padding()
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.gray)
                    .opacity(0.7)
            }
    }
}


struct SearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            TextField("Search", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)
                .accentColor(.white)
                .padding(.leading, 10).frame(maxWidth: .infinity, alignment: .leading)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .trailing).padding(.trailing, 10)
            }
        }
        .padding()
    }
}

struct DeprecatedMainMenuView: View {
    var body: some View {
        ZStack{
            Image("Logo")
            VStack{
                Spacer()
                ScrollView {
                    VStack(spacing: 0) {
                        NavigationLink(
                            destination: DeprecatedRecordSettingView()
                        ) {
                            VStack(alignment: .leading) {
                                Text("历史记录")
                                    .foregroundColor(.white)
                                Divider().colorInvert()
                            }
                            .padding()
                        }
                        NavigationLink(
                            destination: DeprecatedInfoView()
                        ) {
                            VStack(alignment: .leading) {
                                Text("系统设置")
                                    .foregroundColor(.white)
                                Divider().colorInvert()
                            }
                            .padding()
                        }
                    }
                }
            }
        }
        .background(
            Image("bg")
                .resizable()
                .scaledToFill()
        )
        .navigationBarTitle("盘古")
    }
}
