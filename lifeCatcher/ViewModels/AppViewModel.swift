import Foundation

class AppViewModel: ObservableObject {
    @Published var appState: AppState = .loggedOut
    @Published var userInfo: UserInfo?
}
