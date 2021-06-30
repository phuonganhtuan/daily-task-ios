//
//  TaskListViewController.swift
//  Daily Tasks
//
//  Created by Phương Anh Tuấn on 24/06/2021.
//

import UIKit
import CoreData

class TaskListViewController: UIViewController {
    
    @IBOutlet weak var taskListTableView: UITableView!
    
    private var searchController = UISearchController()
    
    private var tasks = [TaskEntity]()
    private let dbHelper = DBHelper()
    
    private var days = [String?]()
    private var tasksByDays = [[TaskEntity]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setToolbarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
        fetchTasks()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    private func fetchTasks() {
        tasks = dbHelper.fetch(name: "TaskEntity", predicate: nil) as? [TaskEntity] ?? []
        tasks.reverse()
        setupData()
        setupViews()
        taskListTableView.reloadData()
    }
    
    private func setupData() {
        tasksByDays = []
        let daysFull = tasks.map({task in
            task.createDate
        })
        days = daysFull.uniqued()
        for i in 0..<days.count {
            let tasksByDay = tasks.filter({task in
                task.createDate == days[i]
            })
            tasksByDays.append(tasksByDay)
            if days[i] == getDateFromMilliseconds(millis: Int64(Date().timeIntervalSince1970)) {
                days[i] = "Today"
            }
        }
    }
    
    private func setupViews() {
        title = "All tasks"
        taskListTableView.dataSource = self
        taskListTableView.delegate = self
        taskListTableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: "taskCell")
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
//        searchController.delegate = self
//        searchController.searchBar.delegate = self
//        navigationItem.searchController = searchController
    }
    
    private func handleDeleteTask(section: Int, index: Int) {
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        managedContext.delete(tasksByDays[section][index])
        fetchTasks()
    }
    
    private func handleUpdateTaskStatus(section: Int, index: Int) {
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "TaskEntity")
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
        taskListTableView.reloadData()
    }
    
    @objc func addBtnClicked(_ sender: Any) {
        let detailVC = DetailViewController()
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal,
                                        title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.handleDeleteTask(section: indexPath.section, index: indexPath.row)
            completionHandler(true)
        }
        action.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        detailVC.isEdit = true
        detailVC.task = tasksByDays[indexPath.section][indexPath.row]
        detailVC.index = tasks.count - 1 - tasks.firstIndex(of: tasksByDays[indexPath.section][indexPath.row])!
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension TaskListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let doneTasks = tasksByDays[section].filter({task in task.value(forKey: "status") as? Int16 ?? 0 == 1})
        return "\(days[section] ?? "") (\(doneTasks.count)/\(tasksByDays[section].count))"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksByDays[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        cell.itemIndex = indexPath.row
        cell.itemSection = indexPath.section
        cell.statusChangeListenerInSection = {section, index in
            self.handleUpdateTaskStatus(section: section, index: index)
        }
        cell.renderData(task: tasksByDays[indexPath.section][indexPath.row])
        return cell
    }
}

extension TaskListViewController: UISearchControllerDelegate, UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print(searchBar.text)
    }
}
