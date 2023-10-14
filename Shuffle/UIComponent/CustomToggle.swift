import SwiftUI

struct CustomToggleStyle: ToggleStyle {
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


