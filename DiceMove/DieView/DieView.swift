import SwiftUI
import SceneKit

struct DieView: UIViewControllerRepresentable, Die.Delegate {

    func makeUIViewController(context: Context) -> DieController {
        let dc = DieController()
        dc.dieDelegate = self
        return dc
    }
    
    func updateUIViewController(_ uiViewController: DieController, context: Context) {
        
    }
    
    func die(_ die: Die, didStopOnValue value: Int) {
        print("You rolled a \(value)")
    }
}
