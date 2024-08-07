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
    @IBOutlet weak var atras: UIButton!
    
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
        
        // Agrega un gesto de long press a la celda
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        cell.addGestureRecognizer(longPressGesture)
        
        return cell
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let password = passwords[indexPath.row]
                let alertController = UIAlertController(title: "Acciones", message: nil, preferredStyle: .actionSheet)
                alertController.addAction(UIAlertAction(title: "Copiar", style: .default, handler: { _ in
                    // Copia la contraseña al portapapeles
                    UIPasteboard.general.string = password.value(forKey: "password") as? String
                }))
                alertController.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func goBack(_ sender: UIButton) {
        // Cierra la vista modal y regresa a la vista anterior
        self.dismiss(animated: true, completion: nil)
    }
    
}
