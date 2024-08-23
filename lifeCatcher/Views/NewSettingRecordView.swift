import SwiftUI

struct NewSettingRecordView: View {
    var body: some View {
        
        VStack{
            ScrollView{
                Spacer()
                
                VStack{
                    
                    ForEach(Array(ClassifierSettingArgs.targetSetting.keys).sorted(), id: \.self) { key in
                        if let value = ClassifierSettingArgs.targetSetting[key] {
                            NavigationLink(
                                destination: SettingRecordConfigView(DatasetType: key, selectedSaveIndex: -1)
                            ){
                                Text(value.ruleName)
                                    .font(.system(size: 24)) // 设置字体大小为 24，你可以根据需要调整
                                    .foregroundColor(.white) // 设置字体颜色为白色
                                    .bold() // 设置字体加粗
                                    .frame(height: 50)
                            }
                            
                            Divider().colorInvert()
                        }
                    }
                }
            }.padding()
            
        }
        .background(Image("bg").resizable().scaledToFill())
            .navigationTitle("选择类别")
    }
}
