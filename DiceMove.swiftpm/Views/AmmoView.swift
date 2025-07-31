import SwiftUI

struct AmmoView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> AmmoViewController {
        AmmoViewController()
    }
    
    func updateUIViewController(_ uiViewController: AmmoViewController, context: Context) {
        
    }
    
//    func sizeThatFits(_ proposal: ProposedViewSize, uiViewController: AmmoViewController, context: Context) -> CGSize? {
//        let width = proposal.width ?? 0
//        uiViewController.layout.prepare()
//        return .init(
//            width: width,
//            height: uiViewController.layout.collectionViewContentSize.height)
//    }
}
