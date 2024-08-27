import SwiftUI

class generalRuleSetting{
    static let allDatasetType: [Int: String] = [
        0:"德州",
        1:"牛牛",
        2:"炸金花",
        3:"小九",
        4:"三公",
        5:"二八杠",
        6:"九点半",
        7:"宝子",
        8:"佳佳宝",
        9:"牌九",
        10:"九点",
        11:"4张",
        12:"2张",
        13:"3张",
        14:"10点半",
        15:"比鸡",
        16:"十三水"
    ]
    static let allShuffleMode: [Int:String] = [
        0:"洗牌",
        1:"拨到顶",
        2:"拨中间",
        3:"洗牌+拨到顶",
        4:"洗牌+拨中间"
    ]
    static let allCutMode: [Int:String] = [
        0:"不切牌",
        1:"看底",
        2:"看顶",
        3:"连续切牌",
        4:"看手牌"
    ]
    static let allDealType: [Int: String] = [
        0:"默认每轮发一张",
        1:"自定义"
    ]
    
    static let allCutNumSetting:[Int:String] = [
        0:"点数打色, J = 11, Q = 12, K = 13, 王 = 6",
        1:"点数打色, J = 1, Q = 2, K = 3，王 = 6",
        2:"点数打色, J = 1, Q = 2, K = 1, 王 = 1",
        3:"点数打色, J = 4, Q = 3, K = 2, 王 = 1",
        4:"花色打色, 黑 = 1，红 = 2，梅 = 3，方 = 4",
        5:"花色打色, 黑 = 4，红 = 3，梅 = 2，方 = 1"
    ]
    
    static let allReportSetting:[Int:String] = [
        0:"报最大",
        1:"报最小",
        2:"报切几张目标位置最大",
        3:"报切几张目标位置最小",
        4:"报目标生死门",
        5:"啊啊啊阿啊阿啊阿啊阿啊阿啊阿啊阿啊阿啊阿啊阿啊阿啊阿啊阿啊阿啊阿啊阿啊阿啊"
    ]
    
    static let maxConsecutiveReport: Int = 5
    static let maxReportNumber: Int = 10
    
    static let allVoiceReport:[Int:String] = [
        0:"无",
        1:"有"
    ]
    
    static let allResultReportType:[Int:String] = [
        0:"无",
        1:"识别任意牌报下一轮"
    ]
}

struct SettingRecordConfigView: View{
    var DatasetType: Int
    var selectedSaveIndex: Int
    @State private var _selectedSaveIndex: Int = -1
    @State private var editType: Int = 0
    @State private var setting: Int = 0
    @State private var dealNum: Int = 0
    @State private var coloringType: Int = 0
    @State private var dealType: Int = 0
    @State private var diyDealNum: [Int] = []
    @State private var diyDealStatus: [[Bool]] = []
    @State private var rcNum: Int = 2
    @State private var shuffleMode: Int = 0
    @State private var cutMode: Int = 0
    @State private var singlefeatureToUse: [Int] = []
    //色点设置
    @State private var cutNumSetting: Int = 0
    @State private var reportSetting: Int = 0
    //打色范围
    @State private var cutNumRangeSetting: [Int] = [1,5]
    @State private var positionSetting: Int = 0
    @State private var consecutiveReport: Int = 1
    @State private var reportNumber: Int = 0
    @State private var voiceReport: Int = 0
    @State private var args:[Int] = []
    @State private var suitRules: [Int] = []
    @State private var rankRules: [RankRulesSate] = []
    
    @State private var showAlert = false
    @State private var showRuleInfo = false
    @State private var saveSuccessAlert = false
    @State private var alertMessage = ""
    @State private var isNavigateToSelectRuleView = false
    @State private var isNavigateToMainContentView = false
    @State private var rcNumList:[Int] = [2,3,4,5,6,7,8]
    @State private var currentNum: Int = 2
    @State private var minSingleFeatureNum:Int = 0
    @State private var resultReportType: Int = 0
    
    private func SetUpAll(){
        if self.selectedSaveIndex == -1 && self.editType == 0{
            
            _selectedSaveIndex = self.selectedSaveIndex

            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType]!
            self.rcNumList = selectedRule.rcNum
            
            self.cutNumRangeSetting = [1,5]
            for singlefeatureIndex in 0...54{
                if singlefeatureIndex != 52{
                    self.singlefeatureToUse.append(singlefeatureIndex)
                }
            }
           
            self.args = DetectSettingArgs.allPreSetRules[self.DatasetType]![self.setting]![0]
            self.suitRules = DetectSettingArgs.allPreSetRules[self.DatasetType]![self.setting]![1]
            for rankIndex in 0...DetectSettingArgs.allPreSetRules[self.DatasetType]![self.setting]![2].count - 1 {
                self.rankRules.append(RankRulesSate(index: DetectSettingArgs.allPreSetRules[self.DatasetType]![self.setting]![2][rankIndex], isChecked: (DetectSettingArgs.allPreSetRules[self.DatasetType]![self.setting]![3][rankIndex] != 0)))
            }
            self.singlefeatureToUse = DatasetGetAllSingleFeatureIndex()
            
            self.currentNum = rcNumList[self.rcNum]
        }else if self.selectedSaveIndex > -1 && editType == 0{
            _selectedSaveIndex = self.selectedSaveIndex

            let rules = DetectSettingArgs.allUsersDatasetRule[self.selectedSaveIndex]
            
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType]!
            self.rcNumList = selectedRule.rcNum
            
            self.setting = rules.setting
            self.dealNum = rules.dealNum
            self.coloringType = rules.coloringType
            self.dealType = rules.dealType
            self.diyDealNum = rules.diyDealNum
            self.diyDealStatus = rules.diyDealStatus
            self.rcNum = rules.rcNum
            self.cutMode = rules.cutMode
            self.shuffleMode = rules.shuffleMode
            self.singlefeatureToUse = rules.singlefeatureToUse
            self.cutNumSetting = rules.cutNumSetting
            self.reportSetting = rules.reportSetting
            self.cutNumRangeSetting = rules.cutNumRangeSetting
            self.positionSetting = rules.positionSetting
            self.consecutiveReport = rules.consecutiveReport
            self.reportNumber = rules.reportNumber
            self.voiceReport = rules.voiceReport
            self.args = rules.args
            self.suitRules = rules.suitRanks
            for i in 0...rules.rankRules.count - 1{
                self.rankRules.append(RankRulesSate(index: rules.rankRules[i], isChecked: (rules.rankRuleChecked[i] != 0)))
            }
            self.minSingleFeatureNum = minSingleFeatureNum
            self.resultReportType = rules.resultReportType
            
            self.currentNum = rcNumList[self.rcNum]
        }
        
        self.editType = 1
    }
    
    
    var body: some View{
            VStack{
                Spacer()
                ScrollView{
                    VStack{
                        let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType]
                        
                        HStack{
                            Text("游戏玩法")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white)
                                .padding(.leading,20)// 左侧间距
                            Picker("setting", selection: $setting) {
                                ForEach(0...(selectedRule?.setting.count)! - 1, id: \.self){
                                    index in Text(selectedRule!.setting[index]!).tag(index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 200, height: 30, alignment: .trailing).padding(.trailing,20)
                            .multilineTextAlignment(.leading)
                            .accentColor(.white)
                            .onChange(of: setting) { _ in
                                handleSettingChange(selectedRuleIndex: DatasetType)
                            }
                            
                        }.background(
                            Image("list_bg") // 背景图片
                                .resizable()
                                .scaledToFill()
                        )
                        .frame(height: 45)
                        
                        HStack{
                            Text("游戏规则")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white)
                                .padding(.leading,20)// 左侧间距
                            Button(action: {
                                // 点击按钮时，显示弹出窗口
                                self.showRuleInfo = true

                            }) {
                                Image("icon_next").resizable().frame(width: 30, height: 30)
                            }
                            .padding(.trailing, 40)
                                .alert(isPresented: $showRuleInfo) {
                                    Alert(
                                        title: Text("规则说明"),
                                        message: Text(selectedRule!.ruleInfo[setting]!),
                                        dismissButton: .default(Text("关闭"))
                                    )
                                }
                            }.background(
                                Image("list_bg") // 背景图片
                                    .resizable()
                                    .scaledToFill()
                            )
                            .frame(height: 45)
                            
                            
                            HStack{
                                Text("人数设置")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white)
                                    .padding(.leading,20)// 左侧间距
                                Picker("rcNum", selection: $rcNum) {
                                    ForEach(0...(self.rcNumList.count) - 1, id: \.self){
                                        index in Text(String(self.rcNumList[index])).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 160, height: 30, alignment: .trailing)
                                .padding(.trailing, 20) // 右侧间距
                                .accentColor(.white).onChange(of: rcNum) { _ in
                                    handleRCNumChange(rcNumIndex: rcNum)
                                    
                                }
                                
                            }.background(
                                Image("list_bg") // 背景图片
                                    .resizable()
                                    .scaledToFill()
                            )
                            .frame(height: 45)
                        
                        
                        
                            HStack{
                                Text("洗牌模式")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white)
                                    .padding(.leading,20)// 左侧间距
                                Picker("shuffleMode", selection: $shuffleMode) {
                                    ForEach(0...generalRuleSetting.allShuffleMode.count - 1, id: \.self){
                                        index in Text(generalRuleSetting.allShuffleMode[index]!).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 160, height: 30, alignment: .trailing)
                                .padding(.trailing,20) // 右侧间距
                                .accentColor(.white)
                                
                            }.background(
                                Image("list_bg") // 背景图片
                                    .resizable()
                                    .scaledToFill()
                            )
                            .frame(height: 45)
                            
                            HStack{
                                Text("切牌模式")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white)
                                    .padding(.leading,20)// 左侧间距
                                Picker("cutMode", selection: $cutMode) {
                                    ForEach(0...generalRuleSetting.allCutMode.count - 1, id: \.self){
                                        index in Text(generalRuleSetting.allCutMode[index]!).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 160, height: 30, alignment: .trailing)
                                .padding(.trailing,20) // 右侧间距
                                .accentColor(.white)
                                
                            }.background(
                                Image("list_bg") // 背景图片
                                    .resizable()
                                    .scaledToFill()
                            )
                            .frame(height: 45)
                        
                            HStack{
                                Text("发牌定制")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white)
                                    .padding(.leading,20)// 左侧间距
                                NavigationLink(destination: TurnSettingView(dealNum: $dealNum, coloringType: $coloringType, dealType: $dealType, diyDealNum: $diyDealNum, diyDealStatus: $diyDealStatus)){
                                    Image("icon_next").resizable().frame(width: 30, height: 30).padding(.trailing, 40)
                                }
                            }.background(
                                Image("list_bg") // 背景图片
                                    .resizable()
                                    .scaledToFill()
                            )
                            .frame(height: 45)
                            
                            HStack{
                                Text("用牌设置")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white)
                                    .padding(.leading,20)// 左侧间距
                                NavigationLink(destination: UsedFeatureSelectView(singlefeatureToUse: $singlefeatureToUse)){
                                    Image("icon_next").resizable().frame(width: 30, height: 30).padding(.trailing, 40)
                                }
                                
                                
                            }.background(
                                Image("list_bg") // 背景图片
                                    .resizable()
                                    .scaledToFill()
                            )
                            .frame(height: 45)
                            
                
                            HStack{
                                Text("报法设置")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white)
                                    .padding(.leading,20)// 左侧间距
                                NavigationLink(destination:  ReportSettingView(reportSetting: $reportSetting)){
                                
                                    let text = ReportManager.allReportName[reportSetting]!
                                    Text(text).frame(width: 180, height: 50, alignment: .trailing)
                                        .foregroundColor(.white).padding(.trailing,40)
                                        .multilineTextAlignment(.leading)
                                }
                            }.background(
                                Image("list_bg") // 背景图片
                                    .resizable()
                                    .scaledToFill()
                            )
                            .frame(height: 45)
                        
                        
                        
                        Group{
                            HStack{
                                Text("色点设置")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white)
                                    .padding(.leading,20)// 左侧间距
                                Picker("cutNumSetting", selection: $cutNumSetting) {
                                    ForEach(0...generalRuleSetting.allCutNumSetting.count - 1, id: \.self){
                                        index in Text(generalRuleSetting.allCutNumSetting[index]!).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 200, height: 30, alignment: .trailing)
                                .multilineTextAlignment(.leading)
                                .padding(.trailing,20) // 右侧间距
                                .accentColor(.white)
                                
                            }.background(
                                Image("list_bg") // 背景图片
                                    .resizable()
                                    .scaledToFill()
                            ).frame(height: 45)
                            
                            //打色范围
                            HStack{
                                Text("打色参数")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white)
                                    .padding(.leading,20)// 左侧间距
                                NavigationLink(destination:  NumRangeSettingView(cutNumRangeSetting: $cutNumRangeSetting)){
                                    Text("X = \(cutNumRangeSetting[0])   Y = \(cutNumRangeSetting[1])").frame(maxWidth: .infinity, alignment: .trailing)
                                        .foregroundColor(.white).padding(.trailing,40)
                                }
                            }.background(
                                Image("list_bg") // 背景图片
                                    .resizable()
                                    .scaledToFill()
                            ).frame(height: 45)
                        }
                        
                        Group{
                            
                            HStack{
                                Text("位置设置")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white)
                                    .padding(.leading,20)// 左侧间距
                                Picker("positionSetting", selection: $positionSetting) {
                                    ForEach(0...self.currentNum - 1, id: \.self){
                                        index in Text(String(index + 1)).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 160, height: 30, alignment: .trailing)
                                .padding(.trailing,20) // 右侧间距
                                .accentColor(.white)
                            }.background(
                                Image("list_bg") // 背景图片
                                    .resizable()
                                    .scaledToFill()
                            )
                            .frame(height: 45)
                        
                            
                            HStack{
                                Text("连报轮数")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white)
                                    .padding(.leading,20)// 左侧间距
                                Picker("consecutiveReport", selection: $consecutiveReport) {
                                    ForEach(1...generalRuleSetting.maxConsecutiveReport, id: \.self){
                                        index in Text(String(index)).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 160, height: 30, alignment: .trailing)
                                .padding(.trailing,20) // 右侧间距
                                .accentColor(.white)
                                
                            }.background(
                                Image("list_bg") // 背景图片
                                    .resizable()
                                    .scaledToFill()
                            )
                            .frame(height: 45)
                            
                            HStack{
                                Text("结果播报")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white)
                                    .padding(.leading,20)// 左侧间距
                                Picker("reportResultType", selection: $resultReportType) {
                                    ForEach(0...generalRuleSetting.allResultReportType.count - 1, id: \.self){
                                        index in Text(generalRuleSetting.allResultReportType[index]!).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 200, height: 30, alignment: .trailing)
                                .padding(.trailing,20) // 右侧间距
                                .accentColor(.white)
                                
                            }.background(
                                Image("list_bg") // 背景图片
                                    .resizable()
                                    .scaledToFill()
                            )
                            .frame(height: 45)
                        }
                    }
                }
                
                Spacer()
                
                HStack {
                    
                    Spacer()
                    
                    Button(action: {self.saveData(isShowAlert: true)}){
                        Image("icon_save").resizable().frame(width: 150, height: 60)
                    }.alert(isPresented: $saveSuccessAlert) {
                        Alert(
                            title: Text("保存成功"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        alertMessage = alertMessageCheck()
                        if(alertMessage != "")
                        {
                            showAlertWithMessage()
                        }
                        else {
                            self.saveData(isShowAlert: false)
                            self.isNavigateToMainContentView = true
                        }
                        
                    }) {
                        Image("icon_start").resizable().frame(width: 150, height: 60)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("参数错误"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }.background(NavigationLink(destination:
                                                    CurrentVisionObjectRecognitionView(saveRuleIndex: self._selectedSaveIndex)
                                                    ,
                                                isActive: $isNavigateToMainContentView,
                                                label: EmptyView.init).hidden()
                    )
                    
                    Spacer()
                }.padding()
                
            }.background(Image("bg").scaledToFill())
            .onAppear(){
                self.SetUpAll()
            }
            .navigationTitle("配置设置")
    }
    
    private func saveData(isShowAlert: Bool){
        var rankRulesToAdd: [Int] = []
        var rankRuleToAddChecked: [Int] = []
        let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType]
        self.minSingleFeatureNum = self.DatasetGetMinSingleFeatureNum()
        for i in rankRules{
            rankRulesToAdd.append(i.index)
            if i.isChecked{
                rankRuleToAddChecked.append(1)
            } else {
                rankRuleToAddChecked.append(0)
            }
        }
        let ruleToAdd = DatasetRule(RuleName: selectedRule!.setting[setting]!, DatasetType: DatasetType, setting: setting, dealNum: dealNum, coloringType: coloringType, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus, rcNum: rcNum, shuffleMode: shuffleMode, cutMode: cutMode,  singlefeatureToUse: singlefeatureToUse, cutNumSetting: cutNumSetting, reportSetting: reportSetting, cutNumRangeSetting: cutNumRangeSetting, positionSetting: positionSetting, consecutiveReport: consecutiveReport, reportNumber: reportNumber, voiceReport: voiceReport, args: args, suitRanks: suitRules, rankRules: rankRulesToAdd, rankRuleChecked: rankRuleToAddChecked, minSingleFeatureNum: minSingleFeatureNum, resultReportType: resultReportType)
        if _selectedSaveIndex == -1{
            DetectSettingArgs.allUsersDatasetRule.append(ruleToAdd)
            _selectedSaveIndex = DetectSettingArgs.allUsersDatasetRule.count - 1
        }else {
            DetectSettingArgs.allUsersDatasetRule[_selectedSaveIndex] = ruleToAdd
        }
        DetectSettingArgs.saveDatasetRule()
        if isShowAlert{
            self.saveSuccessAlert = true
        }
    }
    
    private func handleSettingChange(selectedRuleIndex: Int){
        let selectedRule = ClassifierSettingArgs.targetSetting[selectedRuleIndex]!
        if self.setting != selectedRule.setting.count - 1 || selectedRule.setting.count == 1{
            args = DetectSettingArgs.allPreSetRules[self.DatasetType]![self.setting]![0]
            singlefeatureToUse = DatasetGetAllSingleFeatureIndex()
            suitRules = DetectSettingArgs.allPreSetRules[self.DatasetType]![self.setting]![1]
            rankRules.removeAll()
            for index in 0...DetectSettingArgs.allPreSetRules[self.DatasetType]![self.setting]![2].count - 1{
                rankRules.append(RankRulesSate(index: DetectSettingArgs.allPreSetRules[self.DatasetType]![self.setting]![2][index], isChecked: (DetectSettingArgs.allPreSetRules[self.DatasetType]![self.setting]![3][index] != 0)))
            }
        }
    }
    
    private func handleDatasetTypeChange(selectedRuleIndex: Int){
        self.setting = 0
        self.rcNum = 0
        let selectedRule = ClassifierSettingArgs.targetSetting[selectedRuleIndex]!
        self.rcNumList = selectedRule.rcNum
        self.currentNum = self.rcNumList[rcNum]
        self.handleSettingChange(selectedRuleIndex: selectedRuleIndex)
    }
    
    private func handleRCNumChange(rcNumIndex: Int){
        self.currentNum = self.rcNumList[rcNumIndex]
    }
    
    private func DatasetGetAllSingleFeatureIndex()-> [Int]{
        var allSingleFeatureIndex:[Int] = []
        switch DatasetType{
        case 0:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! TPRule
            allSingleFeatureIndex = TP.getAllSingleFeatureIndex(minRank: selectedRule.minRank[args[2]])
            break
        case 1:
            allSingleFeatureIndex = PB.GetAllSingleFeatureIndex(setting: self.setting)
            break
        case 2:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! ZJHDatasetRule
            allSingleFeatureIndex = ZJHDataset.getAllSingleFeatureIndex(minRank: selectedRule.minRank[args[3]], isAce: args[4], isHeadSingleFeature: args[6], isRedspecialfeature: args[7], isBlackspecialfeature: args[10])
            break
        case 3:
            allSingleFeatureIndex = TNDataset.getAllSingleFeatureIndex(setting: self.setting)
            break
        case 4:
            allSingleFeatureIndex = TMDataset.getAllSingleFeatureIndex(setting: self.setting)
            break
        case 5:
            allSingleFeatureIndex = TEGDataset.getAllSingleFeatureIndex(setting: self.setting)
            break
        case 6:
            allSingleFeatureIndex = NPFiveDataset.getAllSingleFeatureIndex(setting: self.setting)
            break
        case 7:
            allSingleFeatureIndex = BZDataset.getAllSingleFeatureIndex(setting: self.setting)
            break
        case 8:
            allSingleFeatureIndex = JJBDataset.getAllSingleFeatureIndex(setting: self.setting)
            break
        case 9:
            allSingleFeatureIndex = CNDataset.getAllSingleFeatureIndex(setting: self.setting)
            break
        case 10:
            allSingleFeatureIndex = NPDataset.getAllSingleFeatureIndex(setting: self.setting)
            break
        case 11:
            allSingleFeatureIndex = FCDataset.getAllSingleFeatureIndex(setting: self.setting)
            break
        case 12:
            allSingleFeatureIndex = TCDataset.getAllSingleFeatureIndex(setting: self.setting)
            break
        case 13:
            allSingleFeatureIndex = TCPDataset.getAllSingleFeatureIndex(setting: self.setting)
            break
        case 14:
            allSingleFeatureIndex = TPFiveDataset.getAllSingleFeatureIndex(setting: self.setting)
            break
        case 15:
            allSingleFeatureIndex = CBDataset.getAllSingleFeatureIndex(setting: self.setting)
            break
        case 16:
            allSingleFeatureIndex = TWDataset.getAllSingleFeatureIndex(setting: self.setting)
            break
        default:
            print("error")
        }
        return allSingleFeatureIndex
    }
    
    private func DatasetGetMinSingleFeatureNum()-> Int{
        var minSingleFeatureNum:Int = 0
        switch DatasetType {
        case 0:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! TPRule
            minSingleFeatureNum = TP.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 1:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! PBRule
            minSingleFeatureNum = PB.GetMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
        case 2:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! ZJHDatasetRule
            minSingleFeatureNum = ZJHDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 3:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! TNDatasetRule
            minSingleFeatureNum = TNDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 4:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType]
            as! TMDatasetRule
            minSingleFeatureNum = TMDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum],handNum: args[0], communityNum: args[1],dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 5:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! TEGDatasetRule
            minSingleFeatureNum = TEGDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum],handNum: args[0], communityNum: args[1],dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 6:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! NPFiveDatasetRule
            minSingleFeatureNum = NPFiveDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum],handNum: args[0], communityNum: args[1],dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 7:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as!
            BZDatasetRule
            minSingleFeatureNum = BZDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum],handNum: args[0], communityNum: args[1],dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 8:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! JJBDatasetRule
            minSingleFeatureNum = JJBDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1],dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
        case 9:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! CNDatasetRule
            minSingleFeatureNum = CNDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
        case 10:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! NPDatasetRule
            minSingleFeatureNum = NPDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 11:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! FCDatasetRule
            minSingleFeatureNum = FCDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 12:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! TCDatasetRule
            minSingleFeatureNum = TCDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 13:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! TCPDatasetRule
            minSingleFeatureNum = TCPDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 14:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! TPFiveDatasetRule
            minSingleFeatureNum = TPFiveDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
            
        case 15:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! CBDatasetRule
            minSingleFeatureNum = CBDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        case 16:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! TWDatasetRule
            minSingleFeatureNum = TWDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
            break
        default:
            print("error")
        }
        return minSingleFeatureNum
    }
    
    private func alertMessageCheck()-> String{
        var alertMessage:String = ""
        if cutNumRangeSetting[0] > self.singlefeatureToUse.count || cutNumRangeSetting[1] > self.singlefeatureToUse.count || cutNumRangeSetting[0] > cutNumRangeSetting[1]{
            alertMessage += "打色范围设置超出可用牌范围，或X值>Y值，请重新设置"
            
        }
        return alertMessage
    }
    
    private func showAlertWithMessage() {
        showAlert = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showAlert = false
        }
    }
}
