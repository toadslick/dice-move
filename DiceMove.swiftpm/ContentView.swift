import SwiftUI
import SceneKit

struct ContentView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = UINavigationController(rootViewController: ContentViewController())
        controller.traitOverrides.userInterfaceStyle = .dark
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        
    }
}
