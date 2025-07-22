import SwiftUI

struct InventoryView: View {
    
    @AppStorage(InventoryCategory.skins.storageKey) var skin = InventoryCategory.skins.defaultValue
    @AppStorage(InventoryCategory.particles.storageKey) var particle = InventoryCategory.particles.defaultValue
    
    var body: some View {
        Form {
            Picker(InventoryCategory.skins.title, selection: $skin) {
                ForEach(InventoryCategory.skins.items, id: \.self) { item in
                    Text(item)
                }
            }
            .pickerStyle(.inline)
            Picker(InventoryCategory.particles.title, selection: $particle) {
                ForEach(InventoryCategory.particles.items, id: \.self) { item in
                    Text(item)
                }
            }
            .pickerStyle(.inline)
        }
        .background(.ultraThinMaterial)
    }
}

