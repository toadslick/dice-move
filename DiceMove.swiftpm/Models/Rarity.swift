import UIKit

enum Rarity: String, RawRepresentable {
    case basic = "Basic"
    case common = "Common"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    case impossible = "Impossible"
    
    static var testOrder: [Rarity] = [
        .impossible,
        .legendary,
        .epic,
        .rare,
        .uncommon,
        .common,
    ]
    
    static func random(luckMultiplier: Int = 1) -> Rarity {
        let n = Float.random(in: 0..<1) * Float(luckMultiplier)
        for rarity in testOrder {
            if n <= rarity.frequency {
                return rarity
            }
        }
        return .common
    }
    
    var color: UIColor {
        switch self {
        case .basic:
            return .systemGray
        case .common:
            return .systemGray
        case .uncommon:
            return .systemGreen
        case .rare:
            return .systemBlue
        case .epic:
            return .systemPurple
        case .legendary:
            return .systemOrange
        case .impossible:
            return .systemRed
        }
    }
    
    var frequency: Float {
        switch self {
        case .basic:
            return 0
        case .common:
            return 1
        case .uncommon:
            return 1 / 20
        case .rare:
            return 1 / 50
        case .epic:
            return 1 / 100
        case .legendary:
            return 1 / 500
        case .impossible:
            return 1 / 1000
        }
    }
}
