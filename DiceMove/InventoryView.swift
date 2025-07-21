import SwiftUI

struct InventoryView: View {
    
    var body: some View {
        Form {
            ForEach(InventoryCategory.all, id: \.storageKey) { category in
                
                @AppStorage(category.storageKey) var item: String = category.defaultValue
                
                Picker(category.title, selection: $item) {
                    ForEach(category.items, id: \.self) { item in
                        Text(item).tag(item)
                    }
                }
                .pickerStyle(.inline)
            }
        }
    }
}
