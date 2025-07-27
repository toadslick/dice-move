import UIKit
import Combine

class ContentViewController:
    GameSubscribingViewController,
    DiceController.Delegate,
    Game.Delegate
{
    var titleLabel: UILabel!
    var luckLabel: UILabel!
    var inventoryButton: VibrancyButton!
    var shopButton: VibrancyButton!
    var spinButton: VibrancyButton!
    
    var game = Game.shared
    
    override func viewDidLoad() {
        game.delegate = self
        
        view.backgroundColor = .black
        
        let diceController = DiceController()
        diceController.delegate = self
        addChild(diceController)
        diceController.didMove(toParent: self)
        diceController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(diceController.view)

        titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Dice Move"
        titleLabel.textColor = .label
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.isUserInteractionEnabled = false
        titleLabel.numberOfLines = 1
        view.addSubview(titleLabel)
        
        luckLabel = UILabel(frame: .zero)
        luckLabel.translatesAutoresizingMaskIntoConstraints = false
        luckLabel.text = "Dice Move"
        luckLabel.textColor = .systemGreen
        luckLabel.font = .preferredFont(forTextStyle: .body)
        luckLabel.textAlignment = .center
        luckLabel.isUserInteractionEnabled = false
        luckLabel.numberOfLines = 1
        view.addSubview(luckLabel)
        
        inventoryButton = VibrancyButton(frame: .zero)
        inventoryButton.translatesAutoresizingMaskIntoConstraints = false
        inventoryButton.setup(title: "Inventory", target: self, action: #selector(inventoryAction))
        view.addSubview(inventoryButton)

        shopButton = VibrancyButton(frame: .zero)
        shopButton.translatesAutoresizingMaskIntoConstraints = false
        shopButton.setup(title: "Shop", target: self, action: #selector(shopAction))
        view.addSubview(shopButton)

        spinButton = VibrancyButton(frame: .zero)
        spinButton.translatesAutoresizingMaskIntoConstraints = false
        spinButton.setup(title: "", target: self, action: #selector(spinAction))
        view.addSubview(spinButton)

        let buttonTopSpacing = 30.0
        let buttonSideSpacing = 30.0
        
        NSLayoutConstraint.activate([
            shopButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: buttonTopSpacing),
            shopButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: buttonSideSpacing),

            spinButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: buttonTopSpacing),
            spinButton.leftAnchor.constraint(equalTo: shopButton.rightAnchor, constant: buttonSideSpacing),

            inventoryButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: buttonTopSpacing),
            inventoryButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -buttonSideSpacing),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: inventoryButton.centerYAnchor),
            
            luckLabel.centerXAnchor.constraint(equalTo: spinButton.centerXAnchor),
            luckLabel.topAnchor.constraint(equalToSystemSpacingBelow: spinButton.bottomAnchor, multiplier: 1),

            diceController.view.topAnchor.constraint(equalTo: view.topAnchor),
            diceController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            diceController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            diceController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    }
    
    override func viewDidLayoutSubviews() {
        titleLabel.isHidden = view.frame.width < 700
    }
    
    // MARK: game pub/sub
    
    override func gameDidChange() {
        spinButton.title = "Spin: \(game.spins)"
        spinButton.isEnabled = game.canPerformSpin
        
        if game.luckSpins > 0 {
            luckLabel.isHidden = false
            luckLabel.text = "\(game.luckMultiplier)× for \(game.luckSpins) spins"
        } else {
            luckLabel.isHidden = true
        }
    }
    
    // MARK: game delegate
    
    func game(_ game: Game, didAddItemToInventory item: String, fromLoot loot: Loot, ofRarity rarity: Rarity) {
        let itemNotificationView = ItemNotificationView(frame: .zero)
        itemNotificationView.translatesAutoresizingMaskIntoConstraints = false
        itemNotificationView.setup(itemName: item, lootName: loot.title, rarity: rarity)
        view.addSubview(itemNotificationView)
        
        NSLayoutConstraint.activate([
            itemNotificationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            itemNotificationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        let translateX = 400.0
        let scale = 0.5
        let animationDuration = 0.5
        let pauseDuration = 3.0
        
        itemNotificationView.alpha = 0
        itemNotificationView.transform = .identity
            .translatedBy(x: -translateX, y: 0)
            .scaledBy(x: scale, y: scale)
        UIView.animate(.smooth(duration: animationDuration, extraBounce: 0.2)) { [unowned itemNotificationView] in
            itemNotificationView.alpha = 1
            itemNotificationView.transform = .identity
        } completion: {
            UIView.animate(withDuration: animationDuration, delay: pauseDuration) { [unowned itemNotificationView] in
                itemNotificationView.alpha = 0
                itemNotificationView.transform = .identity
                    .translatedBy(x: translateX, y: 0)
                    .scaledBy(x: scale, y: scale)
            } completion: { [unowned itemNotificationView] _ in
                itemNotificationView.removeFromSuperview()
            }
        }
        
    }
    
    // MARK: die delegate
    
    func die(_ die: Die, didStopOn value: Int, at point: CGPoint) {
        game.money += value

        DispatchQueue.main.async { [weak self] in
            guard
                let self,
                !point.x.isNaN,
                !point.y.isNaN
            else { return }
            FadingDieScoreView.create(score: value, at: point, in: self.view)
        }
    }
    
    // MARK: button actions
    
    @objc private func inventoryAction(sender: UIButton) {
        let controller = InventoryViewController()
        controller.traitOverrides.userInterfaceStyle = .dark
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.sourceItem = sender
        present(controller, animated: true)
    }
    
    @objc private func shopAction(sender: UIButton) {
        let controller = ShopViewController()
        controller.traitOverrides.userInterfaceStyle = .dark
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.sourceItem = sender
        present(controller, animated: true)
    }
    
    @objc private func spinAction(sender: UIButton) {
        if game.canPerformSpin {
            let _ = game.performSpin()
        }
    }
}
