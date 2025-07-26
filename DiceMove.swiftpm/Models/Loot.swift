import UIKit

class Loot {
    
    static let faces: Loot = .init(
        title: "Dice Face",
        defaultValue: "Dots",
        storageKey: "face",
        items: [
            "Dots": .basic,
            "Numbers": .basic,
        ]
    )
    
    static let skins: Loot = .init(
        title: "Dice Skin",
        defaultValue: "Ivory",
        storageKey: "skin",
        items: [
            "Ivory": .basic,
            "Metal": .uncommon,
            "Wood": .uncommon,
            "Gold": .rare,
            "Acid": .rare,
            "Nebula": .epic,
            "Spark": .legendary,
        ]
    )
    
    static let trails: Loot = .init(
        title: "Trail",
        defaultValue: "None",
        storageKey: "trail",
        items: [
            "None": .basic,
            "Embers": .rare,
            "Fireworks": .epic,
            "Neon": .legendary,
        ]
    )
    
    static let backgrounds: Loot = .init(
        title: "Background",
        defaultValue: "Black",
        storageKey: "background",
        items: [
            "Black": .basic,
            "Felt": .common,
            "Cedar": .common,
            "Water": .uncommon,
            "Space": .rare,
        ]
    )
    
    static let auras: Loot = .init(
        title: "Aura",
        defaultValue: "None",
        storageKey: "aura",
        items: [
            "None": .basic,
            "Sunburst": .epic,
            "Oblivion": .epic,
            "Radioactive": .legendary,
            "Corona": .legendary,
            "Vortex": .impossible,
        ]
    )
    
    static let explosions: Loot = .init(
        title: "Explosion",
        defaultValue: "None",
        storageKey: "explosion",
        items: [
            "None": .basic,
            "Boom": .epic,
            "Wave": .legendary,
        ]
    )
    
    static var all: [Loot] = [
        faces,
        skins,
        trails,
        auras,
        explosions,
        backgrounds,
    ]
    
    typealias Item = (loot: Loot, item: String)
    
    static func randomItem(ofRarity targetRarity: Rarity) -> Item {
        let allItemsByLoot: [[Item]] = all.map({ loot in
            loot.items
                .filter({ (item, rarity) in
                    rarity == targetRarity
                })
                .map({ (item, _) in
                    (loot: loot, item: item)
                })
        })
        let allItems: [Item] = allItemsByLoot.flatMap({ $0 })
        guard let item = allItems.randomElement() else {
            fatalError("No item found of rarity: \(targetRarity.rawValue)")
        }
        return item
    }
    
    init(
        title: String,
        defaultValue: String,
        storageKey: String,
        items: [String: Rarity]
    ) {
        self.title = title
        self.defaultValue = defaultValue
        self.storageKey = storageKey
        self.items = items
    }
    
    var title: String
    var defaultValue: String
    var storageKey: String
    var items: [String: Rarity]
    
    var currentItemStorageKey: String {
        "\(storageKey)-current"    }
    
    var ownedItemsStorageKey: String {
        "\(storageKey)-owned"
    }
    
    var currentItem: String {
        get {
            UserDefaults.standard.string(forKey: currentItemStorageKey) ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: currentItemStorageKey)
        }
    }
    
    public private(set) var ownedItems: [String] {
        get {
            if let storedValue = UserDefaults.standard.array(forKey: ownedItemsStorageKey) {
                return storedValue as! [String]
            } else {
                return items.keys.filter { key in
                    items[key] == .basic
                }
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ownedItemsStorageKey)
        }
    }
    
    private func own(item: String) {
        var items = Array(ownedItems)
        items.append(item)
        ownedItems = items
    }
}
