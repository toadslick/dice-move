import SwiftUI

struct InventoryView: View {
    
    @AppStorage(Skin.storageKey) private var currentSkin: String = Skin.defaultValue
    @AppStorage(Particle.storageKey) private var currentParticle: String = Particle.defaultValue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Dice Skin")
                .font(.title2.weight(.bold))
                .padding(.horizontal, 20)
                .foregroundStyle(.secondary)
            List(
                Skin.all,
                selection: Binding(
                    get: { currentSkin },
                    set: { currentSkin = $0 ?? Skin.defaultValue }
                )
            ) {
                Text($0.fileName)
            }
            Text("Particle Effect")
                .font(.title2.weight(.bold))
                .padding(.horizontal, 20)
                .foregroundStyle(.secondary)
            List(
                Particle.all,
                selection: Binding(
                    get: { currentParticle },
                    set: { currentParticle = $0 ?? Particle.defaultValue }
                )
            ) {
                Text($0.fileName)
            }
        }.padding(.top, 40)
    }
}
