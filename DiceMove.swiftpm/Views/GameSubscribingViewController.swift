import UIKit
import Combine

class GameSubscribingViewController: UIViewController {
    
    var gameSubscriber: AnyCancellable?
    
    override func viewWillAppear(_ animated: Bool) {
        gameSubscriber = Game.shared.objectWillChange.sink(receiveValue: gameDidChange)
        gameDidChange()
    }

    override func viewWillDisappear(_ animated: Bool) {
        gameSubscriber?.cancel()
        gameSubscriber = nil
    }

    func gameDidChange() {
        
    }
}
