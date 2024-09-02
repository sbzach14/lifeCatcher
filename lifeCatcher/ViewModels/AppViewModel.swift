import Foundation

class AppViewModel: ObservableObject {
    @Published var appState: AppState = .loggedOut
    @Published var userInfo: UserInfo?
    @Published var vericode: String = ""
    
    init(){
        resetVericode()
    }
    
    func resetVericode(){
        let s1 = String(Int.random(in: 0...9))
        let s2 = String(Int.random(in: 0...9))
        let s3 = String(Int.random(in: 0...9))
        let s4 = String(Int.random(in: 0...9))
        vericode =  s1+s2+s3+s4
    }
}
