import Foundation

final class Skin: InventoryItem {

    static var defaultValue = "Default"
    static var fileExtension = "jpg"
    static var storageKey = "currentSkin"

    required init(fileName: String) {
        self.fileName = fileName
    }
    
    var fileName: String
}
