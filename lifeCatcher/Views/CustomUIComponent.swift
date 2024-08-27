import SwiftUI
import CreateMLComponents

struct CustomToggleStyle: ToggleStyle{
    let onImage: Image = Image("icon_slider_bg_on")
    let offImage: Image = Image("icon_slider_bg_off")
    let buttonImage: Image = Image(systemName: "circle") // 使用系统提供的圆形图像

    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            ZStack {
                if configuration.isOn {
                    onImage
                        .resizable()
                        .frame(width: 60, height: 25)
                    Text("开")
                        .foregroundColor(.red)
                        .offset(x:-10)
                        .font(.system(size: 15, weight: .bold))
                } else {
                    offImage
                        .resizable()
                        .frame(width: 60, height: 25)
                    Text("关")
                        .foregroundColor(.white)
                        .offset(x:10)
                        .font(.system(size: 15, weight: .bold))
                }
                
                buttonImage
                    .resizable()
                    .frame(width: 30, height: 30)
                    .offset(x: configuration.isOn ? 15 : -15)
            }
        }
    }
}

struct CustomToggleStyle_NoText: ToggleStyle{
    let onImage: Image = Image("icon_slider_bg_on")
    let offImage: Image = Image("icon_slider_bg_off")
    let buttonImage: Image = Image(systemName: "circle") // 使用系统提供的圆形图像

    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            ZStack {
                if configuration.isOn {
                    onImage
                        .resizable()
                        .frame(width: 60, height: 25)
                } else {
                    offImage
                        .resizable()
                        .frame(width: 60, height: 25)
                }
                
                buttonImage
                    .resizable()
                    .frame(width: 30, height: 30)
                    .offset(x: configuration.isOn ? 15 : -15)
            }
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
                .accentColor(.gray)
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




