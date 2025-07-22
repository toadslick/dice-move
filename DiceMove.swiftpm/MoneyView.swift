import UIKit

class MoneyView: UIView, Game.MoneyDelegate {
    
    private var moneyLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    private func sharedInit() {
        
        Game.shared.moneyDelegate = self

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        
        moneyLabel = UILabel(frame: .zero)
        moneyLabel.translatesAutoresizingMaskIntoConstraints = false
        moneyLabel.textColor = .systemYellow
        moneyLabel.font = .preferredFont(forTextStyle: .title1)
        moneyLabel.textAlignment = .center
        moneyLabel.numberOfLines = 1
        addSubview(moneyLabel)
        setText()
        
        NSLayoutConstraint.activate([
            moneyLabel.topAnchor.constraint(equalTo: topAnchor),
            moneyLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            moneyLabel.leftAnchor.constraint(equalTo: leftAnchor),
            moneyLabel.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }
    
    private func setText() {
        moneyLabel.text = "$\(Game.shared.money.formatted(.number))"
    }
    
    // MARK: animate money label
    
    private let maxTranslateDelta = 100.0
    private let translateFactor = 3.0
    private let rotateFactor = 0.01
    private let maxRotate = 0.05 * .pi

    private var animator: UIViewPropertyAnimator?
    private var translateY = 0.0

    func moneyDidChange(from previousAmount: Int, to newAmount: Int) {
        let delta = Double(newAmount - previousAmount)
        translateY = min(delta * translateFactor, maxTranslateDelta)
        let rotateRange = min(delta * rotateFactor * .pi, maxRotate)
        print(translateY)
        DispatchQueue.main.async { [unowned self] in
            setText()
            
            animator?.stopAnimation(true)
            animator = .init(duration: 0.1, curve: .easeOut)
            animator!.addAnimations { [weak self] in
                guard let self else { return }
                moneyLabel.transform = moneyLabel.transform
                    .translatedBy(x: 0, y: -translateY)
                    .rotated(by: .random(in: -rotateRange...rotateRange))
            }
            animator!.addCompletion { [weak self] _ in
                guard let self else { return }
                animator = .init(duration: 0.0, curve: .easeIn)
                translateY = 0
                animator!.addAnimations { [weak self] in
                    guard let self else { return }

                    moneyLabel.transform = .identity
                }
                animator!.startAnimation()
            }
            animator!.startAnimation()
        }
    }
}
