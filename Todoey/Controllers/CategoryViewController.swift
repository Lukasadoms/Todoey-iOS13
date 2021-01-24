//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Lukas Adomavicius on 1/19/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError()}
        if let firstCategoryColor = categories?.first {
            navBar.backgroundColor = UIColor(hexString: firstCategoryColor.color)
            navBar.layer.cornerRadius = 25
            navBar.clipsToBounds = true
            navBar.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner]
        }
    }
    
    // MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories addded yet"
        if let color = UIColor(hexString: (categories?[indexPath.row].color) ?? "#3f3f3f") {
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            cell.backgroundColor = color
        }
        cell.layer.cornerRadius = 25
        cell.layer.maskedCorners = [.layerMinXMinYCorner,.layerMinXMaxYCorner]
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row] ?? nil
        }
    }
    
    // MARK: - Add new Items functionality
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var todoey = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = todoey.text!
            newCategory.color = RandomFlatColorWithShade(.light).hexValue()
            self.saveData(category: newCategory)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Category"
            todoey = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let category = self.categories?[indexPath.row] {
            do {
                try self.realm.write{
                    self.realm.delete(category)
                }
            } catch {
                print(error)
            }
        }
    }
}

// MARK: - Model Manipulation methods

extension CategoryViewController {
    
    func saveData(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
        tableView.reloadData()
    }
    
    func loadData() {
        categories = realm.objects(Category.self)
    }
    
   
}
