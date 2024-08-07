//
//  PasswordListViewController.swift
//  passGenerator
//
//  Created by manuel on 8/7/24.
//

import UIKit
import CoreData

class PasswordListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    // Contexto de Core Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var passwords: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configura el Table View
        tableView.dataSource = self
        tableView.delegate = self
        loadPasswords()
    }
    
    func loadPasswords() {
        // Carga las contraseñas guardadas de Core Data
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Password")
        do {
            let passwords = try context.fetch(fetchRequest) as! [NSManagedObject]
            self.passwords = passwords
            tableView.reloadData()
        } catch {
            print("Error al cargar contraseñas: \(error)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passwords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "passwordCell", for: indexPath)
        let password = passwords[indexPath.row]
        cell.textLabel?.text = password.value(forKey: "password") as? String
        return cell
    }
    
    
    
}

