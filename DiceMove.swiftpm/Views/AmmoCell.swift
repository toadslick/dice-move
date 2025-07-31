import UIKit

class AmmoCell: UICollectionViewCell {
    static let reuseID = "ammo"
        
    var onImageView: UIImageView!
    var offImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    var isUsed: Bool = false {
        didSet {
            if isUsed {
                
                UIView.animate(.easeOut(duration: 0.2)) {
                    onImageView.transform = .identity
                }

            } else {
                
                UIView.animate(.easeOut(duration: 0.2)) {
                    onImageView.transform = .identity.scaledBy(x: 0, y: 0)
                }

            }
        }
    }

    
    func sharedInit() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        offImageView = UIImageView(image: .init(systemName: "square"))
        offImageView.translatesAutoresizingMaskIntoConstraints = false
        offImageView.preferredSymbolConfiguration = .init(font: .preferredFont(forTextStyle: .title1), scale: .large)
        offImageView.contentMode = .scaleAspectFit
        offImageView.tintColor = .white
        offImageView.alpha = 0.5
        contentView.addSubview(offImageView)

        onImageView = UIImageView(image: .init(systemName: "die.face.3.fill"))
        onImageView.translatesAutoresizingMaskIntoConstraints = false
        onImageView.preferredSymbolConfiguration = .init(font: .preferredFont(forTextStyle: .title1), scale: .large)
        onImageView.contentMode = .scaleAspectFit
        onImageView.tintColor = .systemYellow
        contentView.addSubview(onImageView)

        NSLayoutConstraint.activate([
            offImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            offImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            offImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            offImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),

            onImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            onImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            onImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            onImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            
            contentView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1),
        ])
    }
}
