import UIKit
import Combine

class ShopViewController: UIViewController {

    var gameSubscriber: AnyCancellable!
    var ammoButton: UIButton!
    
    override func viewDidLoad() {
        ammoButton = UIButton(configuration: .filled())
        ammoButton.translatesAutoresizingMaskIntoConstraints = false
        ammoButton.addTarget(self, action: #selector(purchaseAmmoAction), for: .touchUpInside)
        view.addSubview(ammoButton)
        
        NSLayoutConstraint.activate([
            ammoButton.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            ammoButton.leftAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leftAnchor, multiplier: 1),
            
            view.safeAreaLayoutGuide.rightAnchor.constraint(equalToSystemSpacingAfter: ammoButton.rightAnchor, multiplier: 1),
        ])
    }
    
    // MARK: game subscription
    
    override func viewWillAppear(_ animated: Bool) {
        gameSubscriber = Game.shared.objectWillChange.sink(receiveValue: gameDidChange)
        gameDidChange()
    }

    override func viewWillDisappear(_ animated: Bool) {
        gameSubscriber.cancel()
    }

    private func gameDidChange() {
        let ammoPrice = Game.shared.ammoPrice.formatted(.number)
        ammoButton.setTitle("Add a die: \(ammoPrice)", for: .normal)
    }
    
    // MARK: button actions
    
    @objc private func purchaseAmmoAction(sender: UIButton) {
        Game.shared.purchaseAmmo()
    }
}
