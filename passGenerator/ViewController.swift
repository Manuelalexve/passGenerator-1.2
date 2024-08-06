//
//  ViewController.swift
//  passGenerator
//
//  Created by manuel on 8/4/24.
//

import UIKit
import CoreData
class ViewController: UIViewController {
    
    // Instancia del generador de contraseñas
    let passwordGenerator = PasswordGenerator()
    var lastSwitchDisabled: UISwitch?
    
    // Componentes de la interfaz gráfica
    @IBOutlet weak var uppercaseSwitch: UISwitch!
    @IBOutlet weak var lowercaseSwitch: UISwitch!
    @IBOutlet weak var numbersSwitch: UISwitch!
    @IBOutlet weak var specialCharactersSwitch: UISwitch!
    @IBOutlet weak var lengthSlider: UISlider!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var saveButton: UIButton! // Nuevo botón para guardar contraseña
    @IBOutlet weak var viewSavedButton: UIButton! // Nuevo botón para ver contraseñas guardadas
    
    // Contexto de Core Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configura la interfaz gráfica
        uppercaseSwitch.isOn = true
        lowercaseSwitch.isOn = true
        numbersSwitch.isOn = true
        specialCharactersSwitch.isOn = true
        lengthSlider.minimumValue = 6
        lengthSlider.maximumValue = 32
        lengthSlider.value = 12
        lengthLabel.text = "Longitud: 12 Caracteres"
        passwordLabel.text = ""
        
        // Agrega un evento de cambio de valor al slider
        lengthSlider.addTarget(self, action: #selector(updateLengthLabel), for: .valueChanged)
        
        // Agrega eventos de cambio de valor a los switches
        uppercaseSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        lowercaseSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        numbersSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        specialCharactersSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
    
    // Acción del botón generar contraseña
    @IBAction func generatePassword(_ sender: UIButton) {
        // Configura las opciones del generador de contraseñas
        passwordGenerator.useUppercase = uppercaseSwitch.isOn
        passwordGenerator.useLowercase = lowercaseSwitch.isOn
        passwordGenerator.useNumbers = numbersSwitch.isOn
        passwordGenerator.useSpecialCharacters = specialCharactersSwitch.isOn
        passwordGenerator.length = Int(lengthSlider.value)
        
        // Genera la contraseña aleatoria
        let password = passwordGenerator.generatePassword()
        passwordLabel.text = password
    }
    
    // Acción del botón copiar contraseña
    @IBAction func copyPassword(_ sender: UIButton) {
        UIPasteboard.general.string = passwordLabel.text
        let alertController = UIAlertController(title: "Contraseña copiada", message: "La contraseña ha sido copiada al portapapeles", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    
    // Acción del botón guardar contraseña
    @IBAction func savePassword(_ sender: UIButton) {
        // Crea un nuevo objeto de contraseña en Core Data
        let passwordEntity = NSEntityDescription.entity(forEntityName: "Password", in: context)!
        let passwordObject = NSManagedObject(entity: passwordEntity, insertInto: context)
        passwordObject.setValue(passwordLabel.text, forKey: "password")
        
        // Guarda el contexto de Core Data
        do {
            try context.save()
            print("Contraseña guardada con éxito")
            let alertController = UIAlertController(title: "Guardado!", message: "La contraseña ha sido guardada con éxito", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        } catch {
            print("Error al guardar contraseña: \(error)")
        }
    }
    
    // Acción del botón ver contraseñas guardadas
    @IBAction func viewSavedPasswords(_ sender: UIButton) {
        // Recupera las contraseñas guardadas de Core Data
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Password")
        do {
            let passwords = try context.fetch(fetchRequest) as! [NSManagedObject]
            var passwordList = ""
            for password in passwords {
                passwordList += "\(password.value(forKey: "password") ?? "")\n"
            }
            let alertController = UIAlertController(title: "Contraseñas guardadas", message: passwordList, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        } catch {
            print("Error al recuperar contraseñas: \(error)")
        }
    }
    
    // Actualiza el label de longitud en tiempo
    @objc func updateLengthLabel() {
        let length = Int(lengthSlider.value)
        lengthLabel.text = "Longitud: \(length) Caracteres"
    }
    
    // Asegura que al menos un switch esté seleccionado
    func ensureOneSwitchIsOn() {
        if !uppercaseSwitch.isOn && !lowercaseSwitch.isOn && !numbersSwitch.isOn && !specialCharactersSwitch.isOn {
            lastSwitchDisabled?.isOn = true
        }
    }
    
    // Evento de cambio de valor de los switches
    @objc func switchValueChanged(_ sender: UISwitch) {
        if !sender.isOn {
            lastSwitchDisabled = sender
        }
        ensureOneSwitchIsOn()
    }
}

// Clase para generar contraseñas aleatorias
class PasswordGenerator {
    // Opciones para la generación de contraseñas
    var useUppercase: Bool = true
    var useLowercase: Bool = true
    var useNumbers: Bool = true
    var useSpecialCharacters: Bool = true
    var length: Int = 12
    
    // Caracteres especiales
    let specialCharacters: String = "!@#$%^&*()_+-={}:<>?,./"
    
    // Genera una contraseña aleatoria
    func generatePassword() -> String {
        var password: String = ""
        
        // Verifica qué opciones están habilitadas
        var characters: String = ""
        if useUppercase {
            characters += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        }
        if useLowercase {
            characters += "abcdefghijklmnopqrstuvwxyz"
        }
        if useNumbers {
            characters += "0123456789"
        }
        if useSpecialCharacters {
            characters += specialCharacters
        }
        
        // Genera la contraseña aleatoria
        for _ in 1...length {
            let randomIndex = Int(arc4random_uniform(UInt32(characters.count)))
            password += String(characters[characters.index(characters.startIndex, offsetBy: randomIndex)])
        }
        
        return password
    }
}
