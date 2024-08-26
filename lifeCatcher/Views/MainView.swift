

import SwiftUI


class AppViewModel: ObservableObject {
    @Published var appState: AppState = .loggedOut
    @Published var userInfo: UserInfo?
}


struct MainMenuView: View {
    @StateObject var loginStatus = AppViewModel()

    var body: some View {
        NavigationView {
            ZStack{
                
                VStack {
                        Image("sampleImage") // Replace "customImageName" with your image name
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200) // Adjust the size as needed
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.3)))
                        
                    Spacer()
                    
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            
                            NavigationLink(
                                destination: OriginVisionObjectRecognitionView()
                            ) {
                                VStack {
                                    Image(systemName: "camera") // Replace with your custom icon
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                    Text("Collect")
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.8)).frame(width: 150, height: 100, alignment: .center))
                            }
                            
                            NavigationLink(
                                destination: HistoryView()
                            ) {
                                VStack {
                                    Image(systemName: "clock") // Replace with your custom icon
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                    Text("History")
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.green.opacity(0.8)).frame(width: 150, height: 100, alignment: .center))
                            }
                            
                            NavigationLink(
                                destination: InfoView()
                            ) {
                                VStack {
                                    Image(systemName: "info.circle") // Replace with your custom icon
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                    Text("Infomation")
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.orange.opacity(0.8)).frame(width: 150, height: 100, alignment: .center))
                                
                            }
                            
                            // Add another NavigationLink here if needed for the 4th item in the grid
                            
                            NavigationLink(
                                destination: LoginView(loginStatus: loginStatus)) {
                                                        VStack {
                                                            Image(systemName: "person.crop.circle.fill") // Replace with your custom icon
                                                                .font(.largeTitle)
                                                                .foregroundColor(.white)
                                                            Text("用户登录")
                                                                .foregroundColor(.white)
                                                        }
                                                        .padding()
                                                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.red.opacity(0.8)))
                                                    }
                        }
                    
                    Spacer()
                    
                    Image("lifeCatcherTitle") // Replace with your image name
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.3))
                        )
                        .padding(.top, 20) // Add some spacing above the image
                }
            }
            .background(
                Image("Newbg2")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
            .navigationTitle("LifeCatcher")
        }
    }
}


struct DeprecatedMainView: View {
    var body: some View {
        ZStack{
            //Image("Logo")
            VStack{
                Spacer()
                ScrollView {
                    VStack(spacing: 0) {
                        NavigationLink(
                            destination: SettingRecordView()
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
        .navigationBarTitle("  ")
    }
}
