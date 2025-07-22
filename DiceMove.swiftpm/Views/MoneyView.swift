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
    
    private let maxScaleDelta = 1.0
    private let maxMoneyDelta = 50.0
    private let translateFactor = 15.0
    private let maxAngle = 0.03 * .pi

    private var animator: UIViewPropertyAnimator?
    private var targetScale = 1.0

    func moneyDidChange(from previousAmount: Int, to newAmount: Int) {
        let moneyDelta = min(Double(newAmount - previousAmount), maxMoneyDelta)
        let scaleDelta = moneyDelta / maxMoneyDelta * maxScaleDelta
        targetScale += scaleDelta

        DispatchQueue.main.async { [unowned self] in
            setText()
            
            animator?.stopAnimation(true)
            animator = .init(duration: 0.05, curve: .easeInOut)
            animator!.addAnimations { [weak self] in
                guard let self else { return }
                moneyLabel.transform = .identity
                    .scaledBy(x: targetScale, y: targetScale)
                    .translatedBy(x: 0, y: -1 * targetScale * translateFactor)
                    .rotated(by: .random(in: -maxAngle...maxAngle))
                
            }
            animator!.addCompletion { [weak self] _ in
                guard let self else { return }

                animator = .init(duration: 0.3 * targetScale, curve: .easeIn)
                targetScale = 1
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
