import UIKit

class ContentViewController: UIViewController, DiceController.Delegate {
    override func viewDidLoad() {
        
        title = "Dice Move"
        view.backgroundColor = .black
        
        navigationItem.rightBarButtonItem = .init(
            title: "Inventory",
            style: .plain,
            target: self,
            action: #selector(inventoryAction)
        )
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor = .clear
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        
        let diceController = DiceController()
        diceController.dieDelegate = self
        addChild(diceController)
        diceController.didMove(toParent: self)
        diceController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(diceController.view)
        
        NSLayoutConstraint.activate([
            diceController.view.topAnchor.constraint(equalTo: view.topAnchor),
            diceController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            diceController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            diceController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    }
    
    // MARK: dice delegate
    
    func dice(didChange dice: Set<Die>, maxDice: Int) {
        
    }
    
    func die(_ die: Die, didStopOnValue value: Int) {
        Game.shared.money += value
    }
    
    // MARK: button actions
    
    @objc private func inventoryAction(sender: UIBarButtonItem) {
        let controller = UINavigationController(rootViewController: InventoryViewController())
        controller.traitOverrides.userInterfaceStyle = .dark
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.sourceItem = sender
        present(controller, animated: true)
    }

}
