import SwiftUI

struct SettingRecordConfigView_leishen: View{
    
    var selectedSaveIndex: Int
    @State private var initdone : Bool = false
    @State private var _selectedSaveIndex: Int = -1
    @State private var editType: Int = 0
    
    @State private var DatasetType: Int = 0
    @State private var setting: Int = 0
    @State private var dealNum: Int = 0
    @State private var coloringType: Int = 0
    @State private var dealType: Int = 0
    @State private var diyDealNum: [Int] = []
    @State private var diyDealStatus: [[Bool]] = []
    @State private var rcNum: Int = 2
    @State private var shuffleMode: [Int] = [1,0]
    @State private var cutMode: [Int] = [1,0]
    @State private var specialCard: [Int] = [0, 0]
    @State private var singlefeatureToUse: [Int] = []
    //色点设置
    @State private var cutNumSetting: Int = 0
    @State private var reportSetting: [Int] = [0,0]
    //打色范围
    @State private var cutNumRangeSetting: [Int] = [1,5]
    @State private var positionSetting: Int = 0
    @State private var consecutiveReport: Int = 1
    @State private var reportNumber: Int = 0
    @State private var voiceReport: Int = 0
    @State private var args:[Int] = []
    @State private var suitRules: [Int] = []
    @State private var rankRules: [Int] = []
    
    @State private var showAlert = false
    @State private var showRuleInfo = false
    @State private var saveSuccessAlert = false
    @State private var alertMessage = ""
    @State private var isNavigateToSelectRuleView = false
    @State private var isNavigateToMainContentView = false
    @State private var rcNumList:[Int] = [2,3,4,5,6,7,8]
    @State private var currentNum: Int = 2
    @State private var minSingleFeatureNum:Int = 0
    @State private var recgReport: Bool = false
    
    @State private var shuffleRiffleMode: Int = 0
    
    private func SetUpAll(){
        if (self.selectedSaveIndex == -1 && _selectedSaveIndex == -1) && self.editType == 0{
            
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType]!
            self.rcNumList = selectedRule.rcNum
            
            self.cutNumRangeSetting = [1,5]
            
            self.args = DetectSettingArgs.allPreSetRules[self.DatasetType]![self.setting]![0]
            self.suitRules = DetectSettingArgs.allPreSetRules[self.DatasetType]![self.setting]![1]
            self.rankRules = []
            for rankIndex in 0...DetectSettingArgs.allPreSetRules[self.DatasetType]![self.setting]![2].count - 1 {
                let isChecked = DetectSettingArgs.allPreSetRules[self.DatasetType]![self.setting]![3][rankIndex] == 1
                if isChecked{
                    self.rankRules.append( DetectSettingArgs.allPreSetRules[self.DatasetType]![self.setting]![2][rankIndex])
                }
            }
            self.singlefeatureToUse = DatasetGetAllSingleFeatureIndex()
            
            self.currentNum = rcNumList[self.rcNum]
        }else if (self.selectedSaveIndex > -1 || self._selectedSaveIndex > -1) && editType == 0{
            
            if self._selectedSaveIndex == -1{
                _selectedSaveIndex = self.selectedSaveIndex
            }

            let rules = DetectSettingArgs.allUsersDatasetRule[self._selectedSaveIndex]
            
            self.DatasetType = rules.DatasetType
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
            self.rankRules = rules.rankRules
            self.minSingleFeatureNum = minSingleFeatureNum
            self.recgReport = rules.recgReport
            
            self.currentNum = rcNumList[self.rcNum]
            self.singlefeatureToUse = rules.singlefeatureToUse
            self.specialCard = rules.specialCard
        }
        
        //leishen
        if self.shuffleMode[0] == 1{
            self.shuffleRiffleMode = 0
        }
        else if self.shuffleMode[1] == 1{
            self.shuffleRiffleMode = 1
        }
        else if self.shuffleMode[1] == 2{
            self.shuffleRiffleMode = 2
        }
        else{
            self.shuffleRiffleMode = 0
        }
        
        self.cutMode[1] = self.cutMode[0]
        self.specialCard[1] = self.specialCard[0]
        self.reportSetting[1] = self.reportSetting[0]
        
        self.editType = 1
        self.initdone = true
    }
    
    
    var body: some View{
        VStack{
            ScrollView{
                VStack(spacing: 5){
                    if self.initdone{
                        
                        let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType]
                        
                        VStack(spacing: 10){
                            HStack{
                                Text("游戏选择")
                                    .frame(width: 100, alignment: .leading)
                                    .foregroundColor(.white)
                                    .font(.system(size: 20))
                                    .bold()
                                
                                Picker("DatasetType", selection: $DatasetType) {
                                    ForEach(Array(ClassifierSettingArgs.targetSetting.keys).sorted(), id: \.self){
                                        key in
                                        if let value = ClassifierSettingArgs.targetSetting[key]{
                                            Text(value.ruleName).tag(key)
                                        }
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .multilineTextAlignment(.leading)
                                .onChange(of: DatasetType) { _ in
                                    handleDatasetTypeChange()
                                }
                                .accentColor(.white)
                            }
                            .frame(height: 40)
                            
                            HStack{
                                Text("玩法选择")
                                    .frame(width: 100, alignment: .leading)
                                    .foregroundColor(.white)
                                    .font(.system(size: 20))
                                    .bold()
                                
                                Picker("setting", selection: $setting) {
                                    ForEach(0...(selectedRule?.setting.count)! - 1, id: \.self){
                                        index in Text(selectedRule!.setting[index]!).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .multilineTextAlignment(.leading)
                                .onChange(of: setting) { _ in
                                    handleSettingChange()
                                }
                                .accentColor(.white)
                                
                            }
                            .frame(height: 40)
                        }.padding(10)
                        
                        VStack(spacing: 5){
                            Text("规则说明")
                                .frame(height: 25)
                                .foregroundColor(.white)
                                .bold()
                            
                            Divider().colorInvert()
                            
                            ScrollView{
                                Text(selectedRule!.ruleInfo[self.setting] ?? "")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                            }
                            .frame(height: 100)
                        }.bluebubbleBackground().padding(3)
                        
                        HStack{
                            Text("人数设置")
                                .frame(width: 100, alignment: .leading)
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                                .bold()
                                .padding(.leading, 10)
                            
                            Picker("rcNum", selection: $rcNum) {
                                ForEach(0...(self.rcNumList.count) - 1, id: \.self){
                                    index in Text(String(self.rcNumList[index])).tag(index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .accentColor(.blue).onChange(of: rcNum) { _ in
                                handleRCNumChange(rcNumIndex: rcNum)
                            }
                        }
                        .frame(height: 40)
                        .bluebubbleBackground()
                        
                        HStack{
                            Text("手法设置")
                                .frame(width: 100, alignment: .leading)
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                                .bold()
                                .padding(.leading, 10)
                            
                            Picker("shuffleMode", selection: $shuffleRiffleMode) {
                                ForEach(0...generalRuleSetting.allShuffleRiffleMode.count - 1, id: \.self){
                                    index in Text(generalRuleSetting.allShuffleRiffleMode[index]!).tag(index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .accentColor(.blue)
                        }.frame(height: 40)
                        .bluebubbleBackground()
                        
                        HStack{
                            Text("发牌定制")
                                .frame(width: 100, alignment: .leading)
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                                .bold()
                                .padding(.leading, 10)
                            
                            NavigationLink(destination: TurnSettingView(dealNum: $dealNum, coloringType: $coloringType, dealType: $dealType, diyDealNum: $diyDealNum, diyDealStatus: $diyDealStatus)){
                                Text("\(DealClass.dealDic[dealType]!) \(generalRuleSetting.allDealType[dealNum]!)  \(DealClass.coloringDic[coloringType]!)")
                            }.frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 10)
                            
                        }.frame(height: 40)
                        .bluebubbleBackground()
                        
                        HStack{
                            Text("用牌设置")
                                .frame(width: 100, alignment: .leading)
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                                .bold()
                                .padding(.leading, 10)
                            
                            NavigationLink(destination: UsedFeatureSelectView(singlefeatureToUse: $singlefeatureToUse)){
                                Text("使用\(singlefeatureToUse.count)张牌")
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 10)
                            
                            
                        }.frame(height: 40)
                        .bluebubbleBackground()
                            
                        if coloringType != 2{
                            HStack{
                                Text("色点设置")
                                    .frame(width: 100, alignment: .leading)
                                    .foregroundColor(.white)
                                    .font(.system(size: 20))
                                    .bold()
                                    .padding(.leading, 10)
                                
                                //色点设置
                                Picker("cutNumSetting", selection: $cutNumSetting) {
                                    ForEach(0...generalRuleSetting.allCutNumSetting.count - 1, id: \.self){
                                        index in Text(generalRuleSetting.allCutNumSetting[index]!).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .frame(height: 40)
                            .bluebubbleBackground()
                        }
                        
                        HStack{
                            Text("报法设置")
                                .frame(width: 100, alignment: .leading)
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                                .bold()
                                .padding(.leading, 10)
                            
                            NavigationLink(destination: ReportSettingView(reportSetting: $reportSetting, target: 0)){
                                let text = ReportManager.allReportName[reportSetting[0]]!
                                Text(text).multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 10)
                            
                        }.frame(height: 40)
                        .bluebubbleBackground()
                        
                        
                        if coloringType != 2{
                            HStack{
                                Text("打色范围")
                                    .frame(width: 100, alignment: .leading)
                                    .foregroundColor(.white)
                                    .font(.system(size: 20))
                                    .bold()
                                    .padding(.leading, 10)
                                
                                //打色范围
                                NavigationLink(destination:  NumRangeSettingView(cutNumRangeSetting: $cutNumRangeSetting)){
                                    Text("X = \(cutNumRangeSetting[0])   Y = \(cutNumRangeSetting[1])")
                                }.frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.trailing, 10)
                                
                            }.frame(height: 40)
                                .bluebubbleBackground()
                        }
                        
                        HStack{
                            Text("位置设置")
                                .frame(width: 100, alignment: .leading)
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                                .bold()
                                .padding(.leading, 10)
                            
                            Picker("positionSetting", selection: $positionSetting) {
                                ForEach(0...self.currentNum - 1, id: \.self){
                                    index in Text(String(index + 1)).tag(index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .accentColor(.blue)
                        }
                        .frame(height: 40)
                        .bluebubbleBackground()
                        
                        HStack{
                            Text("连报轮数")
                                .frame(width: 100, alignment: .leading)
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                                .bold()
                                .padding(.leading, 10)
                            
                            Picker("consecutiveReport", selection: $consecutiveReport) {
                                ForEach(1...generalRuleSetting.maxConsecutiveReport, id: \.self){
                                    index in Text(String(index)).tag(index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }.frame(height: 40)
                        .bluebubbleBackground()
                        
                        HStack{
                            Text("切牌设置")
                                .frame(width: 100, alignment: .leading)
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                                .bold()
                                .padding(.leading, 10)
                            
                            //看手牌不能选切牌
                            if ReportManager.allHandSpecialCardReport.contains(self.reportSetting[0]){
                                Spacer()
                                Text("无")
                                    .padding(.trailing, 10)
                                    .foregroundColor(.white)
                                    .font(.system(size: 20))
                            }
                            //看色牌不能选连续看底和看手牌
                            else if ReportManager.allColorSpecialCardReport.contains(self.reportSetting[0]){
                                Picker("cutMode", selection: $cutMode[0]) {
                                    ForEach(0...generalRuleSetting.allCutMode.count - 3, id: \.self){
                                        index in Text(generalRuleSetting.allCutMode[index]!).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .accentColor(.blue)
                            }
                            else{
                                Picker("cutMode", selection: $cutMode[0]) {
                                    ForEach(0...generalRuleSetting.allCutMode.count - 1, id: \.self){
                                        index in Text(generalRuleSetting.allCutMode[index]!).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .accentColor(.blue)
                            }
                        }.frame(height: 40)
                        .bluebubbleBackground()
                        
                            
                        HStack{
                            Text("识别任意牌报下轮")
                                .frame(width: 200, alignment: .leading)
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                                .bold()
                                .padding(.leading, 10)
                            
                            Toggle("", isOn: $recgReport).toggleStyle(CustomToggleStyle())
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .accentColor(.white)
                                .padding(.trailing, 10)
                        }.frame(height: 40)
                        .bluebubbleBackground()
                    }
                }
            }
                
            Spacer()
            
            HStack {
     
                Spacer()
                
                Button(action: {
                    alertMessage = alertMessageCheck()
                    if(alertMessage != "")
                    {
                        showAlertWithMessage()
                    }
                    else {
                        self.saveData(isShowAlert: false)
                        self.editType = 0
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
                                                CurrentVisionObjectRecognitionView(saveRuleIndex: self._selectedSaveIndex, configType: 1)
                                                ,
                                            isActive: $isNavigateToMainContentView,
                                            label: EmptyView.init).hidden()
                )
                
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
            }.frame(height: 60, alignment: .bottom)
            
        }
        .background(Image("Newbg2").resizable()
            .scaledToFill()
            .ignoresSafeArea())
        .navigationTitle("参数设置")
        .onAppear(){
            self.SetUpAll()
        }
        .onDisappear(){
            self.saveData(isShowAlert: false)
        }
        
    }
    
    private func saveData(isShowAlert: Bool){
        if self.shuffleRiffleMode == 0{
            self.shuffleMode[0] = 1
            self.shuffleMode[1] = 0
        }
        else if self.shuffleRiffleMode == 1{
            self.shuffleMode[0] = 0
            self.shuffleMode[1] = 1
        }
        else if self.shuffleRiffleMode == 2{
            self.shuffleMode[0] = 0
            self.shuffleMode[1] = 2
        }
        
        self.cutMode[1] = self.cutMode[0]
        self.specialCard[1] = self.specialCard[0]
        self.reportSetting[1] = self.reportSetting[0]
        
        //看手牌
        if ReportManager.allHandSpecialCardReport.contains(self.reportSetting[0]){
            self.specialCard[0] = 1
            self.cutMode[0] = 0 //看手牌情况下不能切牌
        }
        //看色牌
        else if ReportManager.allColorSpecialCardReport.contains(self.reportSetting[0]){
            self.specialCard[0] = 2
            if self.cutMode[0] == 3{
                self.cutMode[0] = 1 //看色牌情况下把连续看底变成看底
            }
            if self.cutMode[0] == 4{
                self.cutMode[0] = 0 //看色牌情况下把看手变成不切牌
            }
        }
        else{
            self.specialCard[0] = 0
        }
        
        //看手牌
        if ReportManager.allHandSpecialCardReport.contains(self.reportSetting[1]){
            self.specialCard[1] = 1
            self.cutMode[1] = 0
        }
        //看色牌
        else if ReportManager.allColorSpecialCardReport.contains(self.reportSetting[1]){
            self.specialCard[1] = 2
            if self.cutMode[1] == 3{
                self.cutMode[1] = 1
            }
            if self.cutMode[1] == 4{
                self.cutMode[1] = 0 //看色牌情况下把看手变成不切牌
            }
        }
        else{
            self.specialCard[1] = 0
        }
        
        
        
        let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType]
        self.minSingleFeatureNum = self.DatasetGetMinSingleFeatureNum()
        
        let ruleToAdd = DatasetRule(RuleName: selectedRule!.setting[setting]!, DatasetType: DatasetType, setting: setting, dealNum: dealNum, coloringType: coloringType, dealType: dealType, diyDealNum: diyDealNum, diyDealStatus: diyDealStatus, rcNum: rcNum, shuffleMode: shuffleMode, cutMode: cutMode,  singlefeatureToUse: singlefeatureToUse, cutNumSetting: cutNumSetting, reportSetting: reportSetting, cutNumRangeSetting: cutNumRangeSetting, positionSetting: positionSetting, consecutiveReport: consecutiveReport, reportNumber: reportNumber, voiceReport: voiceReport, args: args, suitRanks: suitRules, rankRules: rankRules, minSingleFeatureNum: minSingleFeatureNum, recgReport: recgReport, specialCard: specialCard)
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
    
    private func handleSettingChange(){
        let selectedRule = ClassifierSettingArgs.targetSetting[self.DatasetType]!
        
        args = DetectSettingArgs.allPreSetRules[self.DatasetType]![self.setting]![0]
        singlefeatureToUse = DatasetGetAllSingleFeatureIndex()
        suitRules = DetectSettingArgs.allPreSetRules[self.DatasetType]![self.setting]![1]
        rankRules = []
        
        for rankIndex in 0...DetectSettingArgs.allPreSetRules[self.DatasetType]![self.setting]![2].count - 1{
            let isChecked = DetectSettingArgs.allPreSetRules[self.DatasetType]![self.setting]![3][rankIndex] == 1
            if isChecked{
                self.rankRules.append( DetectSettingArgs.allPreSetRules[self.DatasetType]![self.setting]![2][rankIndex])
            }
        }
    }
    
    private func handleDatasetTypeChange(){
        let selectedRule = ClassifierSettingArgs.targetSetting[self.DatasetType]!
        self.rcNum = 2
        self.rcNumList = selectedRule.rcNum
        self.currentNum = self.rcNumList[self.rcNum]
        self.setting = 0
        
        handleSettingChange()
    }
    
    private func handleRCNumChange(rcNumIndex: Int){
        self.currentNum = self.rcNumList[rcNumIndex]
        self.positionSetting = 0
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
        case 17:
            allSingleFeatureIndex = Ain.getAllSingleFeatureIndex(minRank: args[2])
            break
        case 18:
            allSingleFeatureIndex = RFastDataset.getAllSingleFeatureIndex(setting: self.setting)
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
        case 17:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! AinRule
            minSingleFeatureNum = Ain.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
        case 18:
            let selectedRule = ClassifierSettingArgs.targetSetting[DatasetType] as! RFastDatasetRule
            minSingleFeatureNum = RFastDataset.getMinSingleFeatureNum(rcNum: selectedRule.rcNum[rcNum], handNum: args[0], communityNum: args[1], dealType: self.dealType, diyDealNum: self.diyDealNum, diyDealStatus: self.diyDealStatus)
        default:
            print("error")
        }
        return minSingleFeatureNum
    }
    
    private func alertMessageCheck()-> String{
        var alertMessage:String = ""
//        if cutNumRangeSetting[0] > self.singlefeatureToUse.count || cutNumRangeSetting[1] > self.singlefeatureToUse.count || cutNumRangeSetting[0] > cutNumRangeSetting[1]{
//            alertMessage = "打色范围设置超出可用牌范围，或X值>Y值，请重新设置"
//
//        }
        if dealNum == 1 && diyDealNum.count == 0{
            alertMessage = "自定义发牌为空"
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
