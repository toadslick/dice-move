import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            DieView()
                .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}
