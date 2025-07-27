import UIKit

class InventoryViewController:
    UIViewController,
    UITableViewDataSource,
    UITableViewDelegate
{
    var tableView: UITableView!
    
    override func viewDidLoad() {
        sheetPresentationController?.prefersGrabberVisible = true
        
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(InventoryCell.self, forCellReuseIdentifier: InventoryCell.reuseID)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        Loot.all.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Loot.all[section].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Loot.all[section].ownedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InventoryCell.reuseID) as! InventoryCell
        let (_, item, rarity) = itemForRow(at: indexPath)
        let isSelected = isSelected(at: indexPath)
        
        cell.setup(item: item, rarity: rarity)
        cell.accessoryType = isSelected ? .checkmark : .none        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (category, item, _) = itemForRow(at: indexPath)
        category.currentItem = item
        
        let keys = Array(category.items.keys)
        keys.indices.forEach { index in
            let indexPath = IndexPath(row: index, section: indexPath.section)
            let isSelected = isSelected(at: indexPath)
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = isSelected ? .checkmark : .none
                cell.setSelected(false, animated: true) // Remove the highlight but not the checkmark
            }
        }
    }
    
    private func itemForRow(at indexPath: IndexPath) -> (category: Loot, item: String, rarity: Rarity) {
        let category = Loot.all[indexPath.section]
        let item = category.ownedItems[indexPath.row]
        let rarity = category.items[item] ?? .basic
        return (category: category, item: item, rarity: rarity)
    }
    
    private func isSelected(at indexPath: IndexPath) -> Bool {
        let (category, item, _) = itemForRow(at: indexPath)
        return category.currentItem == item
    }
}
