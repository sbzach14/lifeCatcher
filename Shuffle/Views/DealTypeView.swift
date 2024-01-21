//
//  DealTypeView.swift
//  Shuffle
//
//  Created by Zhangyi Chen on 12/17/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI

class DealClass{
    static let dealDic:[Int:String] = [
        0:"正发",
        1:"反发",
    ]
}
struct DealStatus{
    var shouldDeal:Bool = false
    var isCommuity:Bool = false
    var shouldRemove:Bool = false
}

struct DealTypeView: View {
    @Binding var dealType: Int
    @Binding var diyDealType: Int
    @Binding var diyDealNum: [Int]
    @Binding var diyDealStatus: [[Bool]] // [[0，派牌，1，公牌， 2， 去牌]]
    var body: some View {
        VStack{
            HStack{
                Text("发牌定制").frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.white)
                Picker("dealType", selection: $dealType) {
                    ForEach(0...generalRuleSetting.allDealType.count - 1, id: \.self){
                        index in Text(generalRuleSetting.allDealType[index]!).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 160, height: 30, alignment: .trailing)
                .padding(.trailing,30) // 右侧间距
                .accentColor(.white)
                
            }
            
            if dealType == 2{
                Group{
                    VStack{
                        
                        HStack{
                            Text("正发反发").frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white)
                            Picker("diyDealType", selection: $diyDealType) {
                                ForEach(0...DealClass.dealDic.count - 1, id: \.self){
                                    index in Text(DealClass.dealDic[index]!).tag(index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 160, height: 30, alignment: .trailing)
                            .padding(.trailing,30) // 右侧间距
                            .accentColor(.white)
                        }
                        Spacer().frame(height: 50) // 这里设置了Spacer的高度为20

                        HStack{
                            Spacer().frame(width: 10)
                            Text("轮").frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white)
                            Spacer().frame(width: 20)
                            Text("牌数").frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white)
                            Spacer().frame(width: 120)
                            Text("派牌").frame(maxWidth: .infinity, alignment: .trailing)
                                .foregroundColor(.white).padding(.trailing, -40)
                            
                            Text("公牌").frame(maxWidth: .infinity, alignment: .trailing)
                                .foregroundColor(.white).padding(.trailing, -20)

                            Text("去牌").frame(maxWidth: .infinity, alignment: .trailing)
                                .foregroundColor(.white)

                        }
                        ForEach(diyDealNum.indices, id:\.self){
                            index in
                            HStack{
                                Spacer().frame(width: 10)

                                Text("  \(index + 1)").foregroundColor(Color.white)
                                Spacer().frame(width: 50)
                                Stepper("\(diyDealNum[index])", value: $diyDealNum[index]).foregroundColor(Color.white)

                                Spacer().frame(width: 50)
                                Image(systemName: diyDealStatus[index][0] ? "checkmark.square.fill" : "square")
                                        .onTapGesture {
                                            HandleDealStatusToggle(roundIndex: index, toggleIndex: 0)
                                        }
                                Spacer().frame(width: 20)
                                    Image(systemName: diyDealStatus[index][1] ? "checkmark.square.fill" : "square")
                                        .onTapGesture {
                                            HandleDealStatusToggle(roundIndex: index, toggleIndex: 1)
                                        }
                                Spacer().frame(width: 20)
                                    Image(systemName: diyDealStatus[index][2] ? "checkmark.square.fill" : "square")
                                        .onTapGesture {
                                            HandleDealStatusToggle(roundIndex: index, toggleIndex: 2)
                                        }

                            }
                        }
                        
                        Spacer().frame(height: 50) // 这里设置了Spacer的高度为20
                        Button("添加"){
                            AddNewDealSetting()
                            
                        }.foregroundColor(Color.white).border(Color.white, width: 1.5)
                    }
                }
            }
            Spacer()

        }.background(Image("bg").resizable().scaledToFill()).navigationTitle("打色范围设置")
        
        
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
}



struct DealTypeView_Previews: PreviewProvider {
    static var previews: some View {
        let dealType: Binding<Int> = .constant(2)
        let diyDealType: Binding<Int> = .constant(0)
        let diyDealNum: Binding<[Int]> = .constant([2,1,1,1])
        let diyDealStatus: Binding<[[Bool]]> = .constant([[false, false, true], [false,true,false], [true, false,false], [true, false,false]])
        DealTypeView(dealType: dealType, diyDealType: diyDealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus)
    }
}
