import UIKit

class VibrancyButton: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    var button: UIButton!
    
    var title: String {
        get {
            button.title(for: .normal) ?? ""
        }
        set {
            button.setTitle(newValue, for: .normal)
        }
    }
    
    var isEnabled: Bool {
        get {
            button.isEnabled
        }
        set {
            button.isEnabled = newValue
        }
    }
    
    private func sharedInit() {
        layer.masksToBounds = true
        clipsToBounds = true
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialLight))
        blur.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blur)
        
        button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.contentEdgeInsets = .init(top: 10, left: 20, bottom: 10, right: 20)
        button.setTitleColor(.black, for: .normal)
        blur.contentView.addSubview(button)
        
        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: topAnchor),
            blur.bottomAnchor.constraint(equalTo: bottomAnchor),
            blur.leftAnchor.constraint(equalTo: leftAnchor),
            blur.rightAnchor.constraint(equalTo: rightAnchor),

            button.topAnchor.constraint(equalTo: blur.contentView.topAnchor),
            button.leftAnchor.constraint(equalTo: blur.contentView.leftAnchor),
            button.rightAnchor.constraint(equalTo: blur.contentView.rightAnchor),
            button.bottomAnchor.constraint(equalTo: blur.contentView.bottomAnchor),
        ])
    }
    
    func setup(title: String, target: Any?, action: Selector) {
        button.setTitle(title, for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        layoutSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius =  frame.height / 2
    }
    
}
