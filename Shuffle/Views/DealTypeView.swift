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
    
    static let coloringDic: [Int: String] = [
        0:"正面打色",
        1:"反面打色"
    ]
}
struct DealStatus{
    var shouldDeal:Bool = false
    var isCommuity:Bool = false
    var shouldRemove:Bool = false
}

struct DealTypeView: View {
    @Binding var dealNum: Int
    @Binding var coloringType: Int
    @Binding var dealType: Int
    @Binding var diyDealNum: [Int]
    @Binding var diyDealStatus: [[Bool]] // [[0，派牌，1，公牌， 2， 去牌]]
    var body: some View {
        VStack{
            
            HStack{
                Image("icon_shufflemode")
                    .resizable()
                    .frame(width: 40, height: 40).padding(.leading, 20)
                
                Text("发牌定制").frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.white)
                Picker("dealType", selection: $dealNum) {
                    ForEach(0...generalRuleSetting.allDealType.count - 1, id: \.self){
                        index in Text(generalRuleSetting.allDealType[index]!).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 180, height: 30, alignment: .trailing)
                .padding(.trailing,30) // 右侧间距
                .accentColor(.white)
                
            }.background(
                Image("list_bg") // 背景图片
                    .resizable()
                    .scaledToFill()
            )
            .frame(height: 50)
            
            HStack{
                Image("icon_shufflemode")
                    .resizable()
                    .frame(width: 40, height: 40).padding(.leading, 20)
                
                Text("打色模式").frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.white)
                Picker("dealType", selection: $coloringType) {
                    ForEach(0...DealClass.coloringDic.count - 1, id: \.self){
                        index in Text(DealClass.coloringDic[index]!).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 160, height: 30, alignment: .trailing)
                .padding(.trailing,30) // 右侧间距
                .accentColor(.white)
            }.background(
                Image("list_bg") // 背景图片
                    .resizable()
                    .scaledToFill()
            )
            .frame(height: 50)
            
            HStack{
                Image("icon_shufflemode")
                    .resizable()
                    .frame(width: 40, height: 40).padding(.leading, 20)
                
                Text("正发反发").frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.white)
                Picker("dealType", selection: $dealType) {
                    ForEach(0...DealClass.dealDic.count - 1, id: \.self){
                        index in Text(DealClass.dealDic[index]!).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 160, height: 30, alignment: .trailing)
                .padding(.trailing,30) // 右侧间距
                .accentColor(.white)
            }.background(
                Image("list_bg") // 背景图片
                    .resizable()
                    .scaledToFill()
            )
            .frame(height: 50)
            
            if dealNum == 1{
                Group{
                    VStack{
                        
                        Spacer().frame(height: 50) // 这里设置了Spacer的高度为20

                        HStack{
                            
                            Text("轮").frame(maxWidth: 40, alignment: .leading)
                                .foregroundColor(.white)
                                .padding(.leading,30)
                            
                            Text("牌数").frame(maxWidth: 40, alignment: .leading)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("派牌").frame(maxWidth: 40, alignment: .trailing)
                                .foregroundColor(.white)
                            
                            Text("公牌").frame(maxWidth: 40, alignment: .trailing)
                                .foregroundColor(.white)

                            Text("去牌").frame(maxWidth: 40, alignment: .trailing)
                                .foregroundColor(.white).padding(.trailing, 30)

                        }
                        ForEach(diyDealNum.indices, id:\.self){
                            index in
                            HStack{

                                Text("  \(index + 1)").frame(maxWidth: 40, alignment: .leading)
                                    .foregroundColor(.white)
                                    .padding(.leading,30)
                                
                                Stepper("\(diyDealNum[index])", value: $diyDealNum[index]).frame(maxWidth: 200, alignment: .leading)
                                    .foregroundColor(.white)
                                    .padding(.leading,20)
                                
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
                        
                        Spacer().frame(height: 50) // 这里设置了Spacer的高度为20
                        
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
                        }
                    }
                }
            }
            Spacer()

        }.background(Image("bg").resizable().scaledToFill()).navigationTitle("发牌设置")
        
        
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



struct DealTypeView_Previews: PreviewProvider {
    static var previews: some View {
        let dealNum: Binding<Int> = .constant(1)
        let coloringType: Binding<Int> = .constant(1)
        let dealType: Binding<Int> = .constant(0)
        let diyDealNum: Binding<[Int]> = .constant([2,1,1,1])
        let diyDealStatus: Binding<[[Bool]]> = .constant([[false, false, true], [false,true,false], [true, false,false], [true, false,false]])
        DealTypeView(dealNum: dealNum, coloringType: coloringType, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus)
    }
}
