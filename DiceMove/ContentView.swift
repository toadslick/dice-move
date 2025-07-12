import SwiftUI

struct ContentView: View {
    
    @AppStorage("money") private var money: Int = 0
    
    var body: some View {
        NavigationStack {
            DieView()
                .ignoresSafeArea()
                .navigationTitle("Dice Move")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink("Shop") {
                            ShopView()
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink("Inventory") {
                            InventoryView()
                        }
                    }
                }
                .toolbarBackground(.visible, for: .navigationBar)
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Text("$\(money)")
                    .foregroundColor(.yellow)
                    .font(.title2)
                    .fontWeight(.medium)
            }
        }
        .toolbarBackground(.visible, for: .bottomBar)
    }
}

#Preview {
    ContentView()
}
