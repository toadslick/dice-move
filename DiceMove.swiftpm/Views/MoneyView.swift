import SwiftUI

struct MoneyView: View {
    
    @ObservedObject var game = Game.shared
    
    var body: some View {
        GeometryReader { geometry in
            
            VStack(alignment: .center, spacing: 20) {
                Spacer()
                    .frame(maxWidth: .infinity)
                    .allowsHitTesting(false)
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
                
//                HStack(alignment: .bottom, spacing: 3) {
//                    ForEach(0..<game.ammo, id: \.self) { index in
//                        
//                        let isUsed = index < game.ammoUsed
//                        
//                        Image(systemName: isUsed ? "die.face.3.fill" : "square")
//                            .imageScale(.large)
//                            .foregroundStyle(isUsed ? .yellow : .white)
//                            .opacity(isUsed ? 1 : 0.5)
//                            .animation(.linear, value: isUsed)
//                            .contentTransition(.symbolEffect(.replace))
//                    }
//                }
                AmmoView()
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                .frame(maxWidth: geometry.frame(in: .global).width)
            }
            .padding(30)
        }
        .allowsHitTesting(false)
    }

}
