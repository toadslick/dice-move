import SwiftUI
import SceneKit

struct DieView: UIViewControllerRepresentable, DieController.Delegate {
    
    func makeUIViewController(context: Context) -> DieController {
        let dc = DieController()
        dc.delegate = self
        return dc
    }
    
    func updateUIViewController(_ uiViewController: DieController, context: Context) {
        
    }
    
    func dieDidBeginRoll() {
        
    }
    
    func dieDidBeginHold() {
        
    }
    
    func dieDidStopAtValue(_ value: Int) {
        
    }
}
