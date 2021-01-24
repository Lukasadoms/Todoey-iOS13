//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    var items: Results<Item>?
    
    var selectedCategory: Category? {
        didSet {
            loadData()
        }
    }

    @IBOutlet weak var SearchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        if let barColor = selectedCategory?.color {
            guard let navBar = navigationController?.navigationBar else {fatalError()}
            
            if let navBarColor = UIColor(hexString: barColor) {
                navBar.backgroundColor = navBarColor
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
                SearchBar.searchTextField.textColor = ContrastColorOf(navBarColor, returnFlat: true)
            }
            SearchBar.barTintColor = UIColor(hexString: barColor)
            SearchBar.layer.cornerRadius = 25
            SearchBar.clipsToBounds = true
            SearchBar.layer.maskedCorners = [.layerMinXMinYCorner,.layerMinXMaxYCorner]
        }
    }
    
    // MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = items?[indexPath.row] {
            cell.textLabel!.text = item.title
            let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: (CGFloat(indexPath.row) / CGFloat(items!.count))+0.1)
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color!, returnFlat: true)
            cell.accessoryType = item.done ? .checkmark : .none
            cell.layer.cornerRadius = 25
            cell.layer.maskedCorners = [.layerMinXMinYCorner,.layerMinXMaxYCorner]
        } else {
            cell.textLabel!.text = "No item Added"
            cell.accessoryType = .none
        }
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
              
        if let item = items?[indexPath.row] {
            
            do {
                try realm.write{
                    item.done = !item.done
                }
            }catch {
                print("error saving done status \(error)")
            }
            self.tableView.reloadData()
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    // MARK: - Add new Items functionality
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var todoey = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = todoey.text!
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print(error)
                }
            }
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            todoey = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            
            do {
                try realm.write{
                    realm.delete(item)
                }
            }catch {
                print("error deleting item \(error)")
            }
        }
    }
}

// MARK: - Model Manipulation methods

extension ToDoListViewController {
    
    func loadData() {
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
}

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        items = items?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.count == 0 {
            loadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }
}




