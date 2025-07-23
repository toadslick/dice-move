import UIKit

class FadingDieScoreView: UIView {
    
    var label: UILabel!
    
    static func create(score: Int, at origin: CGPoint, in superview: UIView) {
        let size = 100.0
        
        let view = FadingDieScoreView(frame: .zero)
        view.label.text = score.formatted(.number)
        view.frame = .init(
            x: origin.x - (size / 2),
            y: origin.y - (size / 2),
            width: size,
            height: size,
        )
        superview.addSubview(view)
        
        UIView.animate(withDuration: 1) {
            view.transform = .identity.translatedBy(x: 0, y: -100)
        } completion: { [weak view] _ in
            view?.removeFromSuperview()
        }
        
        UIView.animate(withDuration: 0.25, delay: 0.7) {
            view.alpha = 0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    private func sharedInit() {
        isUserInteractionEnabled = false
        
        label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 26, weight: .semibold)
        label.textColor = .systemYellow
        label.textAlignment = .center
        label.numberOfLines = 1
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 1
        label.layer.shadowRadius = 10
        label.clipsToBounds = false
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.leftAnchor.constraint(equalTo: leftAnchor),
            label.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }
}
