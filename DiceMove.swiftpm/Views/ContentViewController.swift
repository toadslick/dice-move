import UIKit

class ContentViewController: UIViewController, DiceController.Delegate {
    
    var titleLabel: UILabel!
    var game = Game.shared
    
    override func viewDidLoad() {
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
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.isUserInteractionEnabled = false
        titleLabel.numberOfLines = 1
        view.addSubview(titleLabel)
        
        let inventoryButton = VibrancyButton(frame: .zero)
        inventoryButton.translatesAutoresizingMaskIntoConstraints = false
        inventoryButton.setup(title: "Inventory", target: self, action: #selector(inventoryActtion))
        view.addSubview(inventoryButton)

        let shopButton = VibrancyButton(frame: .zero)
        shopButton.translatesAutoresizingMaskIntoConstraints = false
        shopButton.setup(title: "Shop", target: self, action: #selector(shopAction))
        view.addSubview(shopButton)
        
        let buttonTopSpacing = 30.0
        let buttonSideSpacing = 30.0
        
        NSLayoutConstraint.activate([
            shopButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: buttonTopSpacing),
            shopButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: buttonSideSpacing),

            inventoryButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: buttonTopSpacing),
            inventoryButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -buttonSideSpacing),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: inventoryButton.centerYAnchor),

            diceController.view.topAnchor.constraint(equalTo: view.topAnchor),
            diceController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            diceController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            diceController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    }
    
    override func viewDidLayoutSubviews() {
        titleLabel.isHidden = view.frame.width < 700
    }
    
    // MARK: dice delegate
    
    func dice(didChange dice: Set<Die>, maxDice: Int) {
        
    }
    
    func die(_ die: Die, didStopOn value: Int, at point: CGPoint) {
        Game.shared.money += value

        DispatchQueue.main.async { [weak self] in
            guard
                let self,
                !point.x.isNaN,
                !point.y.isNaN
            else { return }
            FadingDieScoreView.create(score: value, at: point, in: self.view)
        }
    }
    
    @objc private func inventoryActtion(sender: UIButton) {
        let controller = InventoryViewController()
        controller.traitOverrides.userInterfaceStyle = .dark
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.sourceItem = sender
        present(controller, animated: true)
    }
    
    @objc private func shopAction(sender: UIButton) {
        
    }
}
