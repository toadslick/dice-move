import Foundation

class InventoryCategory {
    
    static var faces: InventoryCategory = .init(
        title: "Dice Face",
        defaultValue: "Dots",
        storageKey: "face",
        items: [
            "Dots",
            "Numbers",
        ]
    )
    
    static var skins: InventoryCategory = .init(
        title: "Dice Skin",
        defaultValue: "Ivory",
        storageKey: "skin",
        items: [
            "Ivory",
            "Gold",
            "Metal",
            "Wood",
            "Nebula",
            "Spark",
        ]
    )
    
    static var particles: InventoryCategory = .init(
        title: "Trail",
        defaultValue: "None",
        storageKey: "trail",
        items: [
            "None",
            "Embers",
            "Neon",
            "Fireworks",
        ]
    )
    
    static var backgrounds: InventoryCategory = .init(
        title: "Background",
        defaultValue: "Black",
        storageKey: "background",
        items: [
            "Black",
            "Felt",
            "Cedar",
            "Water",
            "Space",
        ]
    )
    
    static var auras: InventoryCategory = .init(
        title: "Aura",
        defaultValue: "None",
        storageKey: "aura",
        items: [
            "None",
            "Sunburst",
            "Oblivion",
            "Radioactive",
            "Corona",
            "Vortex",
        ]
    )

    
    static var all: [InventoryCategory] = [
        faces,
        skins,
        particles,
        backgrounds,
        auras
    ]
    
    init(title: String, defaultValue: String, storageKey: String, items: [String]) {
        self.title = title
        self.defaultValue = defaultValue
        self.storageKey = storageKey
        self.items = items
    }
    
    var title: String
    var defaultValue: String
    var storageKey: String
    var items: [String]
    
    var currentItem: String {
        get {
            UserDefaults.standard.string(forKey: storageKey) ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: storageKey)
        }
    }
    
    var currentItemIndex: Int {
        get {
            items.firstIndex(of: currentItem) ?? 0
        }
        set {
            currentItem = items[newValue]
        }
    }
}
