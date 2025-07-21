import SwiftUI

struct ContentView: View {
    
    @AppStorage("money") private var money: Int = 0
    @State private var showingPopover = false
    
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
                                .navigationTitle("Shop")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Inventory") {
                            showingPopover = true
                        }
                        .popover(isPresented: $showingPopover) {
                            InventoryView()
                                .frame(width: 300, height: 600)

                        }
                    }
                }
                .toolbarBackground(.visible, for: .navigationBar)
        }
        .overlay(alignment: .bottom) {
            Text("$\(money)")
                .foregroundColor(.yellow)
                .font(.largeTitle)
                .fontWeight(.medium)
                .animation(.bouncy)
                .contentTransition(.numericText(value: Double(money)))
                .id("money")
        }
    }
}

#Preview {
    ContentView()
}
