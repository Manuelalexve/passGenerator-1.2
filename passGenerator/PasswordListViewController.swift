import UIKit
import CoreData

class PasswordListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var atras: UIButton!
    
    // Contexto de Core Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var passwords: [Password] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configura el Table View
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "passwordCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPasswords()
    }
    
    func loadPasswords() {
        // Carga las contraseñas guardadas de Core Data
        let fetchRequest: NSFetchRequest<Password> = Password.fetchRequest()
        do {
            let passwords = try context.fetch(fetchRequest)
            self.passwords = passwords
            tableView.reloadData()
        } catch {
            print("Error al cargar contraseñas: \(error)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passwords.isEmpty ? 1 : passwords.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "passwordCell", for: indexPath)
        
        if passwords.isEmpty {
            cell.textLabel?.text = "No hay contraseñas guardadas."
            cell.textLabel?.textAlignment = .center
        } else {
            let password = passwords[indexPath.row]
            let passwordString = password.value(forKey: "password") as? String
            
               let creationDate = password.value(forKey: "creationDate") as? Date
            
                cell.textLabel?.text = "\(passwordString ?? "" ) - \(formatDate(creationDate ))"
            
            // Agrega un gesto de long press a la celda
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            cell.addGestureRecognizer(longPressGesture)
        }
        
        // cell.backgroundColor = .blue // Cambia el fondo de la celda a azul
        
        return cell
    }
    
    func formatDate(_ date: Date?) -> String {
        
        guard let date = date else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd   HH:mm:ss"
        return formatter.string(from: date)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: tableView)
            if let indexPath = tableView?.indexPathForRow(at: touchPoint), !passwords.isEmpty {
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
    
    @IBAction func goBack(_ sender: UIButton?) {
        // Cierra la vista modal y regresa a la vista anterior
        self.dismiss(animated: true, completion: nil)
    }
}
