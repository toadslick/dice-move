import SwiftUI
import SceneKit

struct ContentView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> ContentViewController {
        let controller = ContentViewController()
        controller.traitOverrides.userInterfaceStyle = .dark
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ContentViewController, context: Context) {
        
    }
}
