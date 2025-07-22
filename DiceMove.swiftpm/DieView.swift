import SwiftUI
import SceneKit

struct DieView: UIViewControllerRepresentable, DiceController.Delegate {
    
    @AppStorage("money") private var money: Int = 0
    @AppStorage("currentSkin") private var currentSkin: String = "Default"

    func makeUIViewController(context: Context) -> DiceController {
        let dc = DiceController()
        dc.dieDelegate = self
        return dc
    }
    
    func updateUIViewController(_ uiViewController: DiceController, context: Context) {
        
    }
    
    func die(_ die: Die, didStopOnValue value: Int) {
        money += value
    }
    
    func dice(didChange dice: Set<Die>, maxDice: Int) {
        
    }
}
