import UIKit
import Combine

class ShopViewController:
    GameSubscribingViewController,
    UITableViewDataSource,
    UITableViewDelegate
{
    var tableView: UITableView!
    
    override func viewDidLoad() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ShopCell.self, forCellReuseIdentifier: ShopCell.reuseID)
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        
        tableView.reloadData()
    }
    
    // MARK: table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ShopItem.all.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ShopCell.reuseID) as! ShopCell
        cell.setup(item: ShopItem.all[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = ShopItem.all[indexPath.row]
        if item.isEnabled {
            item.purchaseHandler()
        }
    }
    
    override func gameDidChange() {
        tableView.reloadData()
    }
    
    // MARK: button actions
    
    @objc private func purchaseAmmoAction(sender: UIButton) {
        Game.shared.purchaseAmmo()
    }
}
