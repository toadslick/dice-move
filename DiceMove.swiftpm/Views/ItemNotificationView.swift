import UIKit

class ItemNotificationView: UIView {
    
    var blurView: UIVisualEffectView!
    var itemLabel: UILabel!
    var lootLabel: UILabel!
    var rarityLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    private func sharedInit() {
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        blurView.layer.cornerRadius = 20
        blurView.layer.masksToBounds = true
        blurView.layer.borderColor = UIColor.label.withAlphaComponent(0.5).cgColor
        blurView.layer.borderWidth = 2.0
        blurView.clipsToBounds = true
        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)
        
        let emojiLabel = UILabel(frame: .zero)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.textAlignment = .center
        emojiLabel.font = .preferredFont(forTextStyle: .extraLargeTitle)
        emojiLabel.textColor = .label
        emojiLabel.text = "🎁"
        addSubview(emojiLabel)

        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.textColor = .label
        titleLabel.text = "You got an item!"
        blurView.contentView.addSubview(titleLabel)
        
        itemLabel = UILabel(frame: .zero)
        itemLabel.translatesAutoresizingMaskIntoConstraints = false
        itemLabel.textAlignment = .center
        itemLabel.font = .systemFont(ofSize: titleLabel.font.pointSize, weight: .bold)
        itemLabel.textColor = .label
        blurView.contentView.addSubview(itemLabel)
        
        lootLabel = UILabel(frame: .zero)
        lootLabel.translatesAutoresizingMaskIntoConstraints = false
        lootLabel.textAlignment = .center
        lootLabel.font = .preferredFont(forTextStyle: .body)
        lootLabel.textColor = .secondaryLabel
        blurView.contentView.addSubview(lootLabel)
        
        rarityLabel = UILabel(frame: .zero)
        rarityLabel.translatesAutoresizingMaskIntoConstraints = false
        rarityLabel.textAlignment = .center
        rarityLabel.font = .preferredFont(forTextStyle: .body)
        rarityLabel.textColor = .label
        blurView.contentView.addSubview(rarityLabel)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leftAnchor.constraint(equalTo: leftAnchor),
            blurView.rightAnchor.constraint(equalTo: rightAnchor),
            
            emojiLabel.centerYAnchor.constraint(equalTo: topAnchor),
            emojiLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: blurView.contentView.topAnchor, multiplier: 3),
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: blurView.contentView.leadingAnchor, multiplier: 5),

            lootLabel.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 3),
            lootLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: blurView.contentView.leadingAnchor, multiplier: 5),

            itemLabel.topAnchor.constraint(equalTo: lootLabel.bottomAnchor),
            itemLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: blurView.contentView.leadingAnchor, multiplier: 5),

            rarityLabel.topAnchor.constraint(equalTo: itemLabel.bottomAnchor),
            rarityLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: blurView.contentView.leadingAnchor, multiplier: 5),

            blurView.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 5),
            blurView.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: itemLabel.trailingAnchor, multiplier: 5),
            blurView.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: lootLabel.trailingAnchor, multiplier: 5),
            blurView.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: rarityLabel.trailingAnchor, multiplier: 5),
            blurView.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: rarityLabel.bottomAnchor, multiplier: 3),
        ])
    }
    
    func setup(itemName: String, lootName: String, rarity: Rarity) {
        itemLabel.text = itemName
        lootLabel.text = lootName
        rarityLabel.text = rarity.rawValue
        rarityLabel.textColor = rarity.color
    }
}
