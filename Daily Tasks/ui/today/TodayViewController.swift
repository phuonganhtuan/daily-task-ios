//
//  MainViewController.swift
//  Daily Tasks
//
//  Created by Phương Anh Tuấn on 23/06/2021.
//

import UIKit
import CoreData

class TodayViewController: UIViewController {
    
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var labelEmpty: UILabel!
    
    private var tasks = [TaskEntity]()
    private var dbHelper = DBHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setToolbarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
        fetchTasks()
    }
    
    private func fetchTasks() {
        let filter = getDateFromMilliseconds(millis: Int64(Date().timeIntervalSince1970))
        let predicate = NSPredicate(format: "createDate = %@", filter)
        tasks = dbHelper.fetch(name: "TaskEntity", predicate: predicate) as? [TaskEntity] ?? []
        tasks.reverse()
        setupViews()
        taskTableView.reloadData()
        showOrHideEmptyView()
    }
    
    private func showOrHideEmptyView() {
        if (tasks.isEmpty) {
            labelEmpty.show()
        } else {
            labelEmpty.hide()
        }
    }
    
    private func setupViews() {
        title = "Today tasks"
        taskTableView.dataSource = self
        taskTableView.delegate = self
        taskTableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: "taskCell")
        var items = [UIBarButtonItem]()
        let label = UILabel()
        label.text = "\(tasks.count) task(s)"
        label.textAlignment = .center
        label.font = label.font.withSize(12)
        items.append(
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        )
        items.append(UIBarButtonItem(customView: label))
        items.append(
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        )
        let btnAdd = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addBtnClicked(_:)))
        items.append(btnAdd)
        toolbarItems = items
    }
    
    private func handleDeleteTask(index: Int) {
        let deleteAlert = UIAlertController(title: "Delete this task?", message: "This action cannot be undone", preferredStyle: UIAlertController.Style.alert)
        deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
            guard let appDelegate =
                    UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext =
                appDelegate.persistentContainer.viewContext
            managedContext.delete(self.tasks[index])
            self.fetchTasks()
        }))
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
        }))
        present(deleteAlert, animated: true, completion: nil)
    }
    
    private func handleUpdateTaskStatus(index: Int) {
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "TaskEntity")
        let filter = getDateFromMilliseconds(millis: Int64(Date().timeIntervalSince1970))
        let predicate = NSPredicate(format: "createDate = %@", filter)
        fetchRequest.predicate = predicate
        do {
            let objects = try managedContext.fetch(fetchRequest)
            var isDone = 0
            if objects[tasks.count - 1 - index].value(forKey: "status") as! Int16 == 0 {
                isDone = 1
            }
            objects[tasks.count - 1 - index].setValue(isDone, forKey: "status")
            try managedContext.save()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return
        }
        taskTableView.reloadData()
        showOrHideEmptyView()
    }
    
    private func handleCloneTask(index: Int) {
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let cloneTask = tasks[index]
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let entity =
            NSEntityDescription.entity(forEntityName: "TaskEntity",
                                       in: managedContext)!
        let taskEntity = NSManagedObject(entity: entity,
                                         insertInto: managedContext)
        taskEntity.setValue(cloneTask.title, forKey: "title")
        taskEntity.setValue(cloneTask.taskDesc, forKey: "taskDesc")
        taskEntity.setValue(cloneTask.priority, forKey: "priority")
        taskEntity.setValue(Int64(Date().timeIntervalSince1970), forKey: "id")
        taskEntity.setValue(cloneTask.createDate, forKey: "createDate")
        taskEntity.setValue(cloneTask.status, forKey: "status")
        
        do {
            try managedContext.save()
            fetchTasks()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    @objc func addBtnClicked(_ sender: Any) {
        let detailVC = DetailViewController()
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension TodayViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actionClone = UIContextualAction(style: .normal,
                                             title: "Clone") { [weak self] (action, view, completionHandler) in
            self?.handleCloneTask(index: indexPath.row)
            completionHandler(true)
        }
        let action = UIContextualAction(style: .normal,
                                        title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.handleDeleteTask(index: indexPath.row)
            completionHandler(true)
        }
        action.backgroundColor = .systemRed
        actionClone.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [action, actionClone])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        detailVC.isEdit = true
        detailVC.task = tasks[indexPath.row]
        detailVC.index = tasks.count - 1 - indexPath.row
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension TodayViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let doneTasks = tasks.filter({task in task.value(forKey: "status") as? Int16 ?? 0 == 1})
        return "Done: \(doneTasks.count)/\(tasks.count)"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        cell.itemIndex = indexPath.row
        cell.renderData(task: tasks[indexPath.row])
        cell.statusChangeListener = { index in
            self.handleUpdateTaskStatus(index: index)
        }
        return cell
    }
}
