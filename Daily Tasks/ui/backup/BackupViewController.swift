//
//  BackupViewController.swift
//  Daily Tasks
//
//  Created by Phương Anh Tuấn on 09/07/2021.
//

import UIKit
import CoreData

class BackupViewController: UIViewController {
    
    @IBOutlet weak var textImport: UITextView!
    @IBOutlet weak var btnExport: UIButton!
    @IBOutlet weak var btnImport: UIButton!
    
    private let loading = LoadingView()
    private let dbHelper = DBHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setToolbarHidden(true, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupViews() {
        title = "Import & Export"
        textImport.contentInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    
    @IBAction func btnExportClicked(_ sender: Any) {
        loading.show()
        let tasks = dbHelper.fetch(name: "TaskEntity", predicate: nil) as? [TaskEntity] ?? []
        var exportedString = ""
        for i in 0..<tasks.count {
            let title = tasks[i].value(forKey: "title") as? String ?? ""
            let desc = tasks[i].value(forKey: "taskDesc") as? String ?? ""
            let status = Int(tasks[i].value(forKey: "status") as? Int16 ?? 0)
            let priority = tasks[i].value(forKey: "priority") as? Int16 ?? 1
            let createDate = tasks[i].value(forKey: "createDate") as? String ?? ""
            if i == tasks.count - 1 {
                exportedString += "\(title)#\(desc)#\(status)#\(priority)#\(createDate)"
            } else {
                exportedString += "\(title)#\(desc)#\(status)#\(priority)#\(createDate)|"
            }
        }
        let pasteboard = UIPasteboard.general
        pasteboard.string = exportedString
        print(exportedString)
        textImport.text = exportedString
        loading.hide()
        btnExport.setTitle("Copied!", for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.btnExport.setTitle("Backup items as plain text", for: .normal)
        }
    }
    
    @IBAction func btnImportClicked(_ sender: Any) {
        loading.show()
        if !textImport.text.contains("#") || textImport.text.isEmpty{
            btnImport.setTitle("Wrong text!", for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.btnImport.setTitle("Import tasks", for: .normal)
            }
            loading.hide()
            return
        }
        let tasksAsString = textImport.text.split(separator: Character("|"))
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        for i in 0..<tasksAsString.count {
            do {
                let taskAsString = tasksAsString[i].split(separator: Character("#"))
                let title = try taskAsString[0]
                let desc = try taskAsString[1]
                let status = try taskAsString[2]
                let priority = try taskAsString[3]
                let createDate = try taskAsString[4]
                let entity =
                    NSEntityDescription.entity(forEntityName: "TaskEntity",
                                               in: managedContext)!
                let taskEntity = NSManagedObject(entity: entity,
                                                 insertInto: managedContext)
                taskEntity.setValue(title, forKey: "title")
                taskEntity.setValue(desc, forKey: "taskDesc")
                taskEntity.setValue(Int16(priority), forKey: "priority")
                taskEntity.setValue(Int64(Date().timeIntervalSince1970), forKey: "id")
                taskEntity.setValue(createDate, forKey: "createDate")
                taskEntity.setValue(Int16(status), forKey: "status")
                try managedContext.save()
            } catch {
                btnImport.setTitle("Cannot import!", for: .normal)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.btnImport.setTitle("Import tasks", for: .normal)
                }
                loading.hide()
                return
            }
        }
        btnImport.setTitle("Imported", for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.btnImport.setTitle("Import tasks", for: .normal)
        }
        loading.hide()
        return
    }
}
