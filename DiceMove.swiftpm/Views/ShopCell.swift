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
        titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.textColor = .label
        contentView.addSubview(titleLabel)
        
        iconLabel = UILabel(frame: .zero)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.font = .preferredFont(forTextStyle: .title2)
        iconLabel.textColor = .label
        contentView.addSubview(iconLabel)
        
        let priceImage = UIImageView(image: .init(systemName: "dollarsign.circle.fill")!
            .withTintColor(.systemYellow)
            .applyingSymbolConfiguration(.init(scale: .large)))
        priceImage.translatesAutoresizingMaskIntoConstraints = false
        priceImage.alpha = 0.4
        contentView.addSubview(priceImage)
        
        priceLabel = UILabel(frame: .zero)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = .preferredFont(forTextStyle: .title2)
        priceLabel.textColor = .systemYellow
        contentView.addSubview(priceLabel)
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            iconLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            priceLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            priceLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: priceImage.trailingAnchor, multiplier: 1),
            
            priceImage.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: iconLabel.bottomAnchor, multiplier: 1),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,)
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
