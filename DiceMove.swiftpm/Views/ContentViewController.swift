import UIKit

class ContentViewController: UIViewController, DiceController.Delegate {
    override func viewDidLoad() {
        
        title = "Dice Move"
        view.backgroundColor = .black
                
        let diceController = DiceController()
        diceController.delegate = self
        addChild(diceController)
        diceController.didMove(toParent: self)
        diceController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(diceController.view)
        
        let inventoryButtonContainer = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        inventoryButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        inventoryButtonContainer.layer.cornerRadius = 20
        inventoryButtonContainer.layer.masksToBounds = true
        inventoryButtonContainer.clipsToBounds = true
        view.addSubview(inventoryButtonContainer)
        
        let inventoryButton = UIButton(
            configuration: .borderless(),
            primaryAction: .init(title: "Inventory") { [weak self] action in
                guard let self else { return }
                let controller = UINavigationController(rootViewController: InventoryViewController())
                controller.traitOverrides.userInterfaceStyle = .dark
                controller.modalPresentationStyle = .popover
                controller.popoverPresentationController?.sourceItem = action.presentationSourceItem
                present(controller, animated: true)
            })
        inventoryButton.translatesAutoresizingMaskIntoConstraints = false
        inventoryButton.configuration?.contentInsets = .init(top: 10, leading: 20, bottom: 10, trailing: 20)
        inventoryButton.configuration?.buttonSize = .large
        inventoryButton.configuration?.baseForegroundColor = .white
        inventoryButton.backgroundColor = .clear
        inventoryButtonContainer.contentView.addSubview(inventoryButton)
        
        NSLayoutConstraint.activate([
            inventoryButtonContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30),
            inventoryButtonContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            inventoryButton.topAnchor.constraint(equalTo: inventoryButtonContainer.contentView.topAnchor),
            inventoryButton.leftAnchor.constraint(equalTo: inventoryButtonContainer.contentView.leftAnchor),
            inventoryButton.rightAnchor.constraint(equalTo: inventoryButtonContainer.contentView.rightAnchor),
            inventoryButton.bottomAnchor.constraint(equalTo: inventoryButtonContainer.contentView.bottomAnchor),
            
            diceController.view.topAnchor.constraint(equalTo: view.topAnchor),
            diceController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            diceController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            diceController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    }
    
    // MARK: dice delegate
    
    func dice(didChange dice: Set<Die>, maxDice: Int) {
        
    }
    
    func die(_ die: Die, didStopOn value: Int, at point: CGPoint) {
        Game.shared.money += value
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            FadingDieScoreView.create(score: value, at: point, in: self.view)
        }
    }
}
