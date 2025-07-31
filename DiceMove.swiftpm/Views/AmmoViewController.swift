import UIKit
import SwiftUI

class AmmoViewController:
    GameSubscribingViewController,
    UICollectionViewDelegate,
    UICollectionViewDataSource
{
    let game = Game.shared
    var previousTotalAmmo: Int = 0
    var collectionView: UICollectionView!
    var layout: UICollectionViewFlowLayout!

    override func viewDidLoad() {
        view.backgroundColor = .clear
        
        let spacing = 2.0
        
        layout = .init()
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.scrollDirection = .vertical
        layout.itemSize = .init(width: 30, height: 30)
        
        collectionView = .init(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(AmmoCell.self, forCellWithReuseIdentifier: AmmoCell.reuseID)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        
        previousTotalAmmo = game.ammo
        collectionView.reloadData()
    }
    
    // MARK: collection view delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        game.ammo
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AmmoCell.reuseID, for: indexPath) as! AmmoCell
        cell.isUsed = indexPath.item < game.ammoUsed - 1
        return cell
    }
    
    // MARK: game pub/sub
    
    override func gameDidChange() {
        collectionView.visibleCells.forEach { cell in
            collectionView.indexPathsForVisibleItems.forEach { indexPath in
                let cell = collectionView.cellForItem(at: indexPath) as! AmmoCell
                cell.isUsed = indexPath.item < game.ammoUsed - 1
            }
        }
        
        collectionView.performBatchUpdates({
            for index in previousTotalAmmo..<game.ammo {
                collectionView.insertItems(at: [.init(item: index - 1, section: 0)])
            }
        })
        
        previousTotalAmmo = game.ammo
    }
}
