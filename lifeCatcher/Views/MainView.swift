import SwiftUI

struct MainMenuView: View {
    @State private var historyNavigate : Int? = -1
    @StateObject var loginStatus = AppViewModel()

    var body: some View {
        NavigationView {
            ZStack{
                
                VStack {
                        Image("sampleImage") // Replace "customImageName" with your image name
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200) // Adjust the size as needed
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
                            
                            VStack {
                                Button(action: {
                                    if !AuthManager.isLoginServer{
                                        historyNavigate = 0
                                    }
                                    else if AuthManager.isActive{
                                        historyNavigate = 1
                                    }
                                    else{
                                        historyNavigate = 2
                                    }
                                }) {
                                    VStack {
                                        Image(systemName: "clock") // Replace with your custom icon
                                            .font(.largeTitle)
                                            .foregroundColor(.white)
                                        Text("History")
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.green.opacity(0.8))
                                        .frame(width: 150, height: 100, alignment: .center))
                                }
                                .background(
                                    NavigationLink(
                                        destination: LoginView().environmentObject(loginStatus),
                                        tag: 0,
                                        selection: $historyNavigate
                                    ) { EmptyView() }
                                )
                                .background(
                                    NavigationLink(
                                        destination: DeprecatedMainView(),
                                        tag: 1,
                                        selection: $historyNavigate
                                    ) { EmptyView() }
                                )
                                .background(
                                    NavigationLink(
                                        destination: HistoryView(),
                                        tag: 2,
                                        selection: $historyNavigate
                                    ) { EmptyView() }
                                )
                                
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
                            
                            NavigationLink(
                                destination: LoginView().environmentObject(loginStatus)
                            ) {
                                VStack {
                                    Image(systemName: "person.crop.circle.fill") // Replace with your custom icon
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                    Text("Account")
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.red.opacity(0.8)).frame(width: 150, height: 100, alignment: .center))
                            }

//                                                        NavigationLink(
//                                                            destination: AuthTestView()
//                                                        ) {
//                                                            VStack {
//                                                                Image(systemName: "info.circle") // Replace with your custom icon
//                                                                    .font(.largeTitle)
//                                                                    .foregroundColor(.white)
//                                                                Text("验证序列号")
//                                                                    .foregroundColor(.white)
//                                                            }
//                                                            .padding()
//                                                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.orange.opacity(0.8)))
//                                                        }
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
                        .padding(.bottom, 20) // Add some spacing above the image
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
            VStack {
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
                        Text("功能设置")
                            .foregroundColor(.white)
                        Divider().colorInvert()
                    }
                    .padding()
                }
                
                Spacer()
            }
            
        }
        .background(
            Image("Newbg2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationBarTitle("幻影")
    }
}
