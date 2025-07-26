import Foundation

class Game: NSObject, ObservableObject {
    
    enum StorageKey: String, RawRepresentable {
        case money
        case ammo
        case spins
        case luckMultiplier
        case luckSpins
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
            publishChange()
        }
    }
    
    // MARK: ammo
    
    let minimumAmmo = 2
    let maximumAmmo = 25
    
    var ammoUsed = 0 {
        didSet {
            publishChange()
        }
    }
    
    public private(set) var ammo: Int {
        get {
            max(UserDefaults.standard.integer(forKey: StorageKey.ammo.rawValue), minimumAmmo)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: StorageKey.ammo.rawValue)
            publishChange()
        }
    }
    
    var ammoPrice: Int {
        let n = ammo
        return n * n * n * 25
    }
    
    var canPurchaseAmmo: Bool {
        money >= ammoPrice
    }
    
    func purchaseAmmo() {
        guard canPurchaseAmmo else { return }
        money -= ammoPrice
        ammo += 1
    }
    
    // MARK: spins
    
    let spinPrice = 500
    
    var canPurchaseSpin: Bool {
        money >= spinPrice
    }
    
    func purchaseSpin() {
        guard canPurchaseSpin else { return }
        money -= spinPrice
        spins += 1
    }
    
    var canPerformSpin: Bool {
        spins > 1
    }
    
    func spin() -> Loot.Item {
        spins -= 1
        let rarity = Rarity.random(luckMultiplier: useLuck())
        return Loot.randomItem(ofRarity: rarity)
    }
    
    public private(set) var spins: Int {
        get {
            UserDefaults.standard.integer(forKey: StorageKey.spins.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: StorageKey.spins.rawValue)
            publishChange()
        }
    }
    
    // MARK: luck
    
    let defaultLuck = 1
    let spinsPerLuckPurchase = 10
    
    func useLuck() -> Int {
        if luckSpins < 1 {
            return defaultLuck
        }
        luckSpins -= 1
        let mult = luckMultiplier
        if luckSpins < 1 {
            luckMultiplier = defaultLuck
        }
        return mult
    }
    
    func luckPrice(multiplier: Int) -> Int {
        multiplier * spinsPerLuckPurchase * 200
    }
    
    func canPurchaseLuck(multiplier: Int) -> Bool {
        money >= luckPrice(multiplier: multiplier)
    }
    
    func purchaseLuck(multiplier: Int) {
        guard canPurchaseLuck(multiplier: multiplier) else { return }
        money -= luckPrice(multiplier: multiplier)
        luckSpins = spinsPerLuckPurchase
        luckMultiplier = multiplier
    }
    
    public private(set) var luckMultiplier: Int {
        get {
            max(UserDefaults.standard.integer(forKey: StorageKey.ammo.rawValue), defaultLuck)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: StorageKey.luckMultiplier.rawValue)
            publishChange()
        }
    }
    
    public private(set) var luckSpins: Int {
        get {
            UserDefaults.standard.integer(forKey: StorageKey.luckSpins.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: StorageKey.luckSpins.rawValue)
            publishChange()
        }
    }
    
    // MARK: pub/sub
    
    private func publishChange() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            objectWillChange.send()
        }
    }
}
