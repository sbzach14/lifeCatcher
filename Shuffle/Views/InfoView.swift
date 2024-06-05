

import SwiftUI

struct InfoView: View {
    @StateObject var viewModel = SettingViewModel()

    var body: some View {
        VStack{
            SearchBar(searchText: $viewModel.searchText)
                .onAppear {
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: .main) { notification in
                        // Handle the "Return" button pressed event here
                        // For example, you can call a method in your ViewModel
                        viewModel.onReturnKeyPressed()
                    }
                }
                .onDisappear {
                    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
                }
            
            NavigationLink(destination: PanguMainMenuView(), isActive: $viewModel.isLogin) {
            }
            .hidden()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0)  {
                    Text("版本:1.0").padding()
                        .foregroundColor(.white)
                    
                    Divider().colorInvert()
                    
                    Text("序列号:" + viewModel.uniqueID).textSelection(.enabled).padding()
                        .foregroundColor(.white)
                    
                    Divider().colorInvert()
                    
                    Text("激活日期:" + viewModel.activeDate).padding()
                        .foregroundColor(.white)
                    
                    Divider().colorInvert()
                    
                    Text("声明:本软件的使用范围仅限于日常生活图像识别与记录用途，使用本程序造成的任何后果及责任由使用者承担，本公司不承担因用户或代理商在非允许使用范围内使用或销售而导致的任何后果及相关责任。").padding()
                        .foregroundColor(.white)
                    
                    Divider().colorInvert()
                }
            }
        }
        .background(
            Image("bg")
                .resizable()
                .scaledToFill()
        )
        .navigationBarTitle("信息")
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
