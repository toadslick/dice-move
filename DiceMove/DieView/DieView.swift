import SwiftUI
import SceneKit

struct DieView: UIViewControllerRepresentable, Die.Delegate {
 
    @AppStorage("money") private var money: Int = 0

    func makeUIViewController(context: Context) -> DieController {
        let dc = DieController()
        dc.dieDelegate = self
        return dc
    }
    
    func updateUIViewController(_ uiViewController: DieController, context: Context) {
        
    }
    
    func die(_ die: Die, didStopOnValue value: Int) {
        money += value
    }
}
