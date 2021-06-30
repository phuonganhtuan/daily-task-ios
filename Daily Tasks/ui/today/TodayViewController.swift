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
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        managedContext.delete(tasks[index])
        fetchTasks()
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
    }
    
    @objc func addBtnClicked(_ sender: Any) {
        let detailVC = DetailViewController()
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension TodayViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal,
                                        title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.handleDeleteTask(index: indexPath.row)
            completionHandler(true)
        }
        action.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [action])
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
