import Foundation

class Game: NSObject {
    
    enum StorageKey: String, RawRepresentable {
        case money
    }
    
    protocol MoneyDelegate {
        func moneyDidChange(from previousAmount: Int, to newAmount: Int)
    }
    
    static let shared = Game()
    
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
    
    var moneyDelegate: MoneyDelegate?
    
    private override init() {
        super.init()
        
        UserDefaults.standard.addObserver(self, forKeyPath: StorageKey.money.rawValue, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case StorageKey.money.rawValue:
            moneyDelegate?.moneyDidChange(from: previousMoney, to: money)
        default:
            ()
        }
    }
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: StorageKey.money.rawValue)
    }
    
}
