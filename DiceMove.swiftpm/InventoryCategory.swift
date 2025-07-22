import Foundation

class InventoryCategory {
    
    static var skins: InventoryCategory {
        .init(
            title: "Dice Skin",
            defaultValue: "Ivory",
            storageKey: "skin",
            items: [
                "Ivory",
                "Gold",
                "Metal",
                "Wood",
                "Nebula",
                "Spark"
            ]
        )
    }
    
    static var particles: InventoryCategory {
        .init(
            title: "Particle Effect",
            defaultValue: "Embers",
            storageKey: "particle",
            items: filesWithExtension("scnp")
        )
    }
    
    static var all: [InventoryCategory] {
        [
            skins,
            particles
        ]
    }
    
    private static func filesWithExtension(_ ext: String) -> [String] {
        let urls = Bundle.main.urls(
            forResourcesWithExtension: ext,
            subdirectory: nil
        ) ?? []
        
        return urls.map { url in
            guard
                let fileName = url.pathComponents.last as? NSString
            else {
                return ""
            }
            return fileName.deletingPathExtension
        }
    }
    
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
