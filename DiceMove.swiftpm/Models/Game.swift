import Foundation

class Game: NSObject {
    
    enum StorageKey: String, RawRepresentable {
        case money
        case ammo
    }
    
    static let shared = Game()
    
    private override init() {
        super.init()
    }
    
    // MARK: money
    
    var previousMoney: Int = 0
    
    var money: Int {
        get {
            UserDefaults.standard.integer(forKey: StorageKey.money.rawValue)
        }
        set {
            previousMoney = money
            UserDefaults.standard.set(newValue, forKey: StorageKey.money.rawValue)
        }
    }
    
    // MARK: ammo
    
    static let minimumAmmo = 1
    static let maximumAmmo = 25
    
    public private(set) var ammo: Int {
        get {
            max(UserDefaults.standard.integer(forKey: StorageKey.ammo.rawValue), 1)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: StorageKey.ammo.rawValue)
        }
    }
    
    var nextAmmoPrice: Int {
        let n = ammo
        return n * n * n * 25
    }
    
    func purchaseAmmo() {
        guard money > nextAmmoPrice else { return }
        money -= nextAmmoPrice
        ammo += 1
    }
}
