import Foundation

final class Particle: InventoryItem {

    static var defaultValue = "Default"
    static var fileExtension = "scnp"
    static var storageKey = "currentParticle"

    required init(fileName: String) {
        self.fileName = fileName
    }
    
    var fileName: String
}
