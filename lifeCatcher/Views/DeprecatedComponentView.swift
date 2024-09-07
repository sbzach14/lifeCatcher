

import SwiftUI

class DealClass{
    static let dealDic:[Int:String] = [
        0:"正面发牌",
        1:"反面发牌",
    ]
    
    static let coloringDic: [Int: String] = [
        0:"正面打色",
        1:"反面打色",
        2:"不打色"
    ]
}
struct DealStatus{
    var shouldDeal:Bool = false
    var isCommuity:Bool = false
    var shouldRemove:Bool = false
}

struct TurnSettingView: View {
    @Binding var dealNum: Int
    @Binding var coloringType: Int
    @Binding var dealType: Int
    @Binding var diyDealNum: [Int]
    @Binding var diyDealStatus: [[Bool]] // [[0，派牌，1，公牌， 2， 去牌]]
    var body: some View {
        VStack{
            Divider().colorInvert()
            
            HStack{
                Text("发牌模式").frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.white)
                    .padding(.leading,20)
                Picker("dealType", selection: $dealNum) {
                    ForEach(0...generalRuleSetting.allDealType.count - 1, id: \.self){
                        index in Text(generalRuleSetting.allDealType[index]!).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 180, height: 30, alignment: .trailing)
                .padding(.trailing,20) // 右侧间距
                .accentColor(.white)
                
            }
            
            Divider().colorInvert()
            
            HStack{
                Text("发牌方向").frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.white)
                    .padding(.leading,20)
                Picker("dealType", selection: $dealType) {
                    ForEach(0...DealClass.dealDic.count - 1, id: \.self){
                        index in Text(DealClass.dealDic[index]!).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 160, height: 30, alignment: .trailing)
                .padding(.trailing,20) // 右侧间距
                .accentColor(.white)
            }
            
            Divider().colorInvert()
            
            HStack{
                Text("打色方向").frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.white)
                    .padding(.leading,20)
                
                Picker("dealType", selection: $coloringType) {
                    ForEach(0...DealClass.coloringDic.count - 1, id: \.self){
                        index in Text(DealClass.coloringDic[index]!).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 160, height: 30, alignment: .trailing)
                .padding(.trailing,20) // 右侧间距
                .accentColor(.white)
            }
            
            Divider().colorInvert()
            
            if dealNum == 1{
                Group{
                    VStack{
                        
                        Spacer().frame(height: 25)

                        HStack{
                            
                            Text("牌数").frame(maxWidth: 40, alignment: .leading)
                                .foregroundColor(.white)
                                .padding(.leading,30)
                            
                            Spacer()
                            
                            Text("派牌").frame(maxWidth: 40, alignment: .trailing)
                                .foregroundColor(.white)
                            
                            Text("公牌").frame(maxWidth: 40, alignment: .trailing)
                                .foregroundColor(.white)

                            Text("去牌").frame(maxWidth: 40, alignment: .trailing)
                                .foregroundColor(.white).padding(.trailing, 30)

                        }
                        ScrollView{
                            ForEach(diyDealNum.indices, id:\.self){
                                index in
                                HStack{
                               
                                    Stepper("\(diyDealNum[index])", value: $diyDealNum[index]).frame(maxWidth: 150, alignment: .leading)
                                        .foregroundColor(.white)
                                        .padding(.leading,40)
                                        .onChange(of: diyDealNum[index]) { newValue in
                                            if newValue <= 0 {
                                                diyDealNum[index] = 1 // 确保值始终大于0
                                            }
                                        }
                                    
                                    Spacer()
                                    
                                    
                                    Image(systemName: diyDealStatus[index][0] ? "checkmark.square.fill" : "square")
                                        .onTapGesture {
                                            HandleDealStatusToggle(roundIndex: index, toggleIndex: 0)
                                        }.frame(maxWidth: 40, alignment: .trailing)
                                        .foregroundColor(.white)
                                    
                                    Image(systemName: diyDealStatus[index][1] ? "checkmark.square.fill" : "square")
                                        .onTapGesture {
                                            HandleDealStatusToggle(roundIndex: index, toggleIndex: 1)
                                        }.frame(maxWidth: 40, alignment: .trailing)
                                        .foregroundColor(.white)
                                    
                                    Image(systemName: diyDealStatus[index][2] ? "checkmark.square.fill" : "square")
                                        .onTapGesture {
                                            HandleDealStatusToggle(roundIndex: index, toggleIndex: 2)
                                        }.frame(maxWidth: 40, alignment: .trailing)
                                        .foregroundColor(.white).padding(.trailing, 30)
                                    
                                }
                            }
                        }
                        
                        Spacer()
                        
                        HStack{
                            Spacer()
                            
                            Button(action: {AddNewDealSetting()}){
                                Image("icon_add").resizable().frame(width: 150, height: 60)
                            }
                            
                            Spacer()
                            
                            Button(action: {DeleteNewDealSetting()}){
                                Image("icon_delete").resizable().frame(width: 150, height: 60)
                            }
                            
                            Spacer()
                        }.padding()
                    }
                }
            }
            Spacer()

        }.background(Image("Newbg2").resizable()
            .scaledToFill()
            .ignoresSafeArea())
        .navigationTitle("发牌设置")
        
        
    }
    
    private func HandleDealStatusToggle(roundIndex: Int, toggleIndex: Int){
        for i in 0...2{
            if i != toggleIndex && diyDealStatus[roundIndex][i] == true{
                diyDealStatus[roundIndex][i].toggle()
            } else if i == toggleIndex {
                diyDealStatus[roundIndex][i].toggle()
            }
        }
    }
    private func AddNewDealSetting(){
        self.diyDealNum.append(1)
        self.diyDealStatus.append([true, false, false])
    }
    
    private func DeleteNewDealSetting(){
        if self.diyDealNum.count > 0{
            self.diyDealNum.removeLast()
            self.diyDealStatus.removeLast()
        }
    }
}

struct NumRangeSettingView: View {
    @Binding var cutNumRangeSetting:[Int]
    var body: some View {
        VStack{
            HStack{
                Text("    最小位置   ").foregroundColor(.white)
                TextField("X = ", value: $cutNumRangeSetting[0], format: .number).textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding().onChange(of: cutNumRangeSetting[0]){
                        newValue in cutNumRangeSetting[0] = max(1, min(newValue, 54))
                    }
            }
            HStack{
                Text("    最大位置   ").foregroundColor(.white)

                TextField("Y = ", value: $cutNumRangeSetting[1], format: .number).textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding().onChange(of: cutNumRangeSetting[1]){
                        newValue in
                                        // 限制输入值在1到54之间
                                        cutNumRangeSetting[1] = max(1, min(newValue, 54))
                    }
                
            }
            
            Spacer()
        }.background(Image("Newbg2").resizable()
            .scaledToFill()
            .ignoresSafeArea())
        .navigationTitle("范围设置")
    }
}
