import SwiftUI
import Localize_Swift

struct MainMenuView: View {
    @StateObject var loginStatus = AppViewModel()
    @State private var historyNavigate: Int? = -1

    @AppStorage("appLanguage") private var appLanguage: String = "en"

    var body: some View {
        NavigationView {
            ZStack{
                VStack {
                    Divider().colorInvert()
                    
                    Image("sampleImage")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .bubbleBackground()

                    Spacer()

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        NavigationLink(destination: OriginVisionObjectRecognitionView()) {
                            VStack {
                                Image(systemName: "camera")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                Text("Collect".localized())
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.8)).frame(width: 150, height: 100, alignment: .center))
                        }

                        VStack {
                            Button(action: {
//                                if true{
//                                    historyNavigate = 1
//                                    return
//                                }
                                
                                AutoLogin(username: "", password: "")
                                
                                if !AuthManager.isLoginServer{
                                    historyNavigate = 0
                                } else if AuthManager.isActive{
                                    historyNavigate = 1
                                } else {
                                    historyNavigate = 2
                                }
                            }) {
                                VStack {
                                    Image(systemName: "clock")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                    Text("History".localized())
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.green.opacity(0.8)).frame(width: 150, height: 100, alignment: .center))
                            }
                            .background(
                                NavigationLink(destination: LoginView().environmentObject(loginStatus), tag: 0, selection: $historyNavigate) { EmptyView() }
                            )
                            .background(
                                NavigationLink(destination: DeprecatedMainView(), tag: 1, selection: $historyNavigate) { EmptyView() }
                            )
                            .background(
                                NavigationLink(destination: HistoryView(), tag: 2, selection: $historyNavigate) { EmptyView() }
                            )
                        }

                        NavigationLink(destination: InfoView()) {
                            VStack {
                                Image(systemName: "info.circle")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                Text("Information".localized())
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.orange.opacity(0.8)).frame(width: 150, height: 100, alignment: .center))
                        }

                        NavigationLink(destination: LoginView().environmentObject(loginStatus)) {
                            VStack {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                Text("Account".localized())
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.red.opacity(0.8)).frame(width: 150, height: 100, alignment: .center))
                        }
                        
//                        NavigationLink(destination: AuthTestView()) {
//                            VStack {
//                                Image(systemName: "person.crop.circle.fill")
//                                    .font(.largeTitle)
//                                    .foregroundColor(.white)
//                                Text("Auth".localized())
//                                    .foregroundColor(.white)
//                            }
//                            .padding()
//                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.red.opacity(0.8)).frame(width: 150, height: 100, alignment: .center))
//                        }
                    }

                    Spacer()

                    Image("lifeCatcherTitle")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .padding(.bottom, 20)
                        .cornerRadius(10)
                    
                }
            }
            .background(
                Image("Newbg2")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: toggleLanguage) {
                        Text(appLanguage == "en" ? "中文" : "EN")
                            .foregroundColor(.blue)
                    }
                }
            }
            .onAppear {
                Localize.setCurrentLanguage(appLanguage)
            }
            .navigationTitle("LifeCatcher".localized())
            
        }
    }

    private func toggleLanguage() {
        if appLanguage == "en" {
            appLanguage = "zh-Hans" // Simplified Chinese code
        } else {
            appLanguage = "en"
        }
        Localize.setCurrentLanguage(appLanguage)
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
