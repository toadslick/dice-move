import SwiftUI

@main
struct DiceMoveApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .bottom) {
                ContentView()
                    .ignoresSafeArea()
                MoneyView()
            }
        }
    }
}
