import UIKit

struct ShopItem {
    
    let title: String
    let price: Int
    let icon: String
    let isEnabled: Bool
    let purchaseHandler: () -> Void
    
    static var all: [ShopItem] {[
        .init(
            title: "Increase Ammo",
            price: Game.shared.ammoPrice,
            icon: "🎲+1",
            isEnabled: Game.shared.canPurchaseAmmo,
            purchaseHandler: Game.shared.purchaseAmmo
        ),
        .init(
            title: "Buy a Spin",
            price: Game.shared.spinPrice,
            icon: "🎰+1",
            isEnabled: Game.shared.canPurchaseSpin,
            purchaseHandler: Game.shared.purchaseSpin
        ),
        luckItem(multiplier: 2),
        luckItem(multiplier: 10),
    ]}
    
    static func luckItem(multiplier: Int) -> ShopItem {
        .init(
            title: "\(multiplier)× Luck for \(Game.shared.spinsPerLuckPurchase) Spins",
            price: Game.shared.luckPrice(multiplier: multiplier),
            icon: "☘️×\(multiplier)",
            isEnabled: Game.shared.canPurchaseLuck(multiplier: multiplier),
            purchaseHandler: {
                Game.shared.purchaseLuck(multiplier: multiplier)
            }
        )
    }
}
