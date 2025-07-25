import SwiftUI

struct MoneyView: View {
    
    @ObservedObject var game = Game.shared
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            
            LabeledContent {
                Text(game.money, format: .number)
                    .animation(.bouncy)
                    .contentTransition(.numericText(value: Double(game.money)))
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
            
            HStack(alignment: .center, spacing: 3) {
                ForEach(0..<game.ammoUsed, id: \.self) { _ in
                    Image(systemName: "die.face.3.fill").imageScale(.large)
                        .foregroundStyle(.yellow)
                }
                ForEach(game.ammoUsed..<game.ammo, id: \.self) { _ in
                    Image(systemName: "die.face.3").imageScale(.large)
                        .foregroundStyle(.white)
                        .opacity(0.75)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .cornerRadius(10)

        }
        .padding(30)
        .allowsHitTesting(false)

    }
}
