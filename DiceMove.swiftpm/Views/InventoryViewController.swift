import UIKit

class InventoryViewController:
    UIViewController,
    UITableViewDataSource,
    UITableViewDelegate
{
    var tableView: UITableView!
    
    override func viewDidLoad() {
        title = "Inventory"
        
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "item")
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        InventoryCategory.all.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        InventoryCategory.all[section].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        InventoryCategory.all[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item")!
        let (_, item) = itemForRow(at: indexPath)
        let isSelected = isSelected(at: indexPath)
        
        cell.textLabel?.text = item
        cell.selectionStyle = .default
        cell.accessoryType = isSelected ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (category, item) = itemForRow(at: indexPath)
        category.currentItem = item

        category.items.indices.forEach { index in
            let indexPath = IndexPath(row: index, section: indexPath.section)
            let isSelected = isSelected(at: indexPath)
            let cell = tableView.cellForRow(at: indexPath)!
            cell.accessoryType = isSelected ? .checkmark : .none
            cell.setSelected(false, animated: true) // Remove the highlight but not the checkmark
        }
    }
    
    private func itemForRow(at indexPath: IndexPath) -> (category: InventoryCategory, item: String) {
        let category = InventoryCategory.all[indexPath.section]
        return (category: category, item: category.items[indexPath.row])
    }
    
    private func isSelected(at indexPath: IndexPath) -> Bool {
        let (category, item) = itemForRow(at: indexPath)
        return category.currentItem == item
    }
}
