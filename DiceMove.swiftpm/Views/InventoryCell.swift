import UIKit

class InventoryCell: UITableViewCell {
    
    var itemLabel: UILabel!
    var rarityLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    private func sharedInit() {
        itemLabel = UILabel(frame: .zero)
        itemLabel.translatesAutoresizingMaskIntoConstraints = false
        itemLabel.font = .preferredFont(forTextStyle: .body)
        itemLabel.numberOfLines = 1
        contentView.addSubview(itemLabel)

        rarityLabel = UILabel(frame: .zero)
        rarityLabel.translatesAutoresizingMaskIntoConstraints = false
        rarityLabel.font = .preferredFont(forTextStyle: .body)
        rarityLabel.numberOfLines = 1
        contentView.addSubview(rarityLabel)
        
        let verticalSpacingFactor = 1.5
        let horizontalSpacingFactor = 2.0
        
        NSLayoutConstraint.activate([
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: itemLabel.bottomAnchor, multiplier: verticalSpacingFactor),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: rarityLabel.bottomAnchor, multiplier: verticalSpacingFactor),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: rarityLabel.trailingAnchor, multiplier: horizontalSpacingFactor),
            
            itemLabel.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: verticalSpacingFactor),
            itemLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: horizontalSpacingFactor),

            rarityLabel.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: verticalSpacingFactor),
            rarityLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: itemLabel.trailingAnchor, multiplier: horizontalSpacingFactor),
        ])
    }
    
    func setup(item: String, rarity: Rarity) {
        itemLabel.text = item
        rarityLabel.text = rarity.rawValue
        rarityLabel.textColor = rarity.color
    }
    
}
