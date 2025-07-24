import SwiftUI

struct MoneyView: View {
    
    @AppStorage(Game.StorageKey.money.rawValue) var money = 0
    
    var body: some View {
        LabeledContent {
            Text(money, format: .number)
                .animation(.bouncy)
                .contentTransition(.numericText(value: Double(money)))
                .foregroundStyle(.yellow)
        } label: {
            Label("Gold", systemImage: "dollarsign.circle.fill")
                .labelStyle(.iconOnly)
                .foregroundStyle(.yellow)
                .opacity(0.4)
        }
        .fixedSize()
        .font(.largeTitle)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.ultraThinMaterial)
        .cornerRadius(10)
        .padding(30)
        .allowsHitTesting(false)
    }
}

#Preview {
    MoneyView()
}
