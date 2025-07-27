import UIKit

class ShopCell: UITableViewCell {
    static let reuseID = "ShopItem"
    
    var item: ShopItem!
    
    var titleLabel: UILabel!
    var iconLabel: UILabel!
    var priceLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        sharedInit()
    }
    
    private func sharedInit() {
        backgroundColor = .black.withAlphaComponent(0.2)

        titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.textColor = .label
        contentView.addSubview(titleLabel)
        
        iconLabel = UILabel(frame: .zero)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.font = .preferredFont(forTextStyle: .title1)
        iconLabel.textColor = .label
        contentView.addSubview(iconLabel)
        
        let priceImage = UIImage(
            systemName: "dollarsign.circle.fill",
            withConfiguration: UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .title1))
                .applying(UIImage.SymbolConfiguration(paletteColors: [.systemYellow]))
        )!
        
        let priceImageView = UIImageView(image: priceImage)
        priceImageView.translatesAutoresizingMaskIntoConstraints = false
        priceImageView.alpha = 0.4
        contentView.addSubview(priceImageView)
        
        priceLabel = UILabel(frame: .zero)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = .preferredFont(forTextStyle: .title1)
        priceLabel.textColor = .systemYellow
        contentView.addSubview(priceLabel)
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 2),
            iconLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2),
            
            priceLabel.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 2),
            priceLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: priceImageView.trailingAnchor, multiplier: 0.5),
            
            priceImageView.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: iconLabel.bottomAnchor, multiplier: 1),
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2),
            
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: priceLabel.trailingAnchor, multiplier: 2),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 2),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 2),
        ])
    }
    
    func setup(item: ShopItem) {
        titleLabel.text = item.title
        iconLabel.text = item.icon
        priceLabel.text = item.price.formatted(.number)
        isUserInteractionEnabled = item.isEnabled
        contentView.alpha = item.isEnabled ? 1 : 0.5
    }
}
