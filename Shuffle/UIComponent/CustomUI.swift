import SwiftUI

struct CustomToggleStyle: ToggleStyle{
    let onImage: Image = Image("icon_slider_bg_on")
    let offImage: Image = Image("icon_slider_bg_off")
    let buttonImage: Image = Image("icon_slider_point")

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

struct CustomPickerStyle: PickerStyle {
    
    var arrowImage: Image = Image("")// 自定义箭头图像
    var background: Image = Image("")// 自定义背景图像
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Text(configuration.label)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            arrowImage
                .resizable()
                .frame(width: 20, height: 20) // 调整箭头图像大小
            
        }
        .background(
            background
                .resizable()
                .scaledToFill()
        )
        .onTapGesture {
            configuration.trigger()
        }
    }
}





