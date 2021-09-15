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
    @IBOutlet weak var labelEmpty: UILabel!
    
    private var searchController = UISearchController()
    
    private var tasks = [TaskEntity]()
    private let dbHelper = DBHelper()
    
    private var days = [String?]()
    private var tasksByDays = [[TaskEntity]]()
    private var currentFilter = ""
    
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
        setupData(keyword: currentFilter)
        setupViews()
        taskListTableView.reloadData()
        showOrHideEmptyView()
    }
    
    private func showOrHideEmptyView() {
        if (tasksByDays.isEmpty) {
            labelEmpty.show()
        } else {
            labelEmpty.hide()
        }
    }
    
    private func convertStringToDate(dateStr:String, format:String = "dd/MM/yyyy") -> Date{
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = format
        return dateFormat.date(from: dateStr)!
    }
    
    private func setupData(keyword: String) {
        tasksByDays = []
        let daysFull = tasks.map({task in
            task.createDate
        })
        days = daysFull.uniqued()
        days.sort(by: {day1, day2 in
            let date1 = convertStringToDate(dateStr: day1 ?? "")
            let date2 = convertStringToDate(dateStr: day2 ?? "")
            return date1.timeIntervalSince1970 > date2.timeIntervalSince1970
        })
        var daysRemove = [Int]()
        for i in 0..<days.count {
            var tasksByDay = tasks.filter({task in
                task.createDate == days[i]
            })
            if (!keyword.isEmpty) {
                tasksByDay = tasks.filter({task in
                    task.createDate == days[i] && (task.title?.lowercased().contains(keyword.lowercased()) ?? false || task.taskDesc?.lowercased().contains(keyword.lowercased()) ?? false)
                })
            }
            if days[i] == getDateFromMilliseconds(millis: Int64(Date().timeIntervalSince1970)) {
                days[i] = "Today"
            }
            if (tasksByDay.isEmpty) {
                daysRemove.append(i)
            } else {
                tasksByDays.append(tasksByDay)
            }
        }
        for j in 0..<daysRemove.count {
            days.remove(at: daysRemove.reversed()[j])
        }
    }
    
    private func setupViews() {
        setupFilterView()
        taskListTableView.dataSource = self
        taskListTableView.delegate = self
        taskListTableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: "taskCell")
        setupToolbar()
        searchController.delegate = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    private func setupToolbar() {
        var items = [UIBarButtonItem]()
        let label = UILabel()
        var filterTasks = tasks
        if (!currentFilter.isEmpty) {
            filterTasks = tasks.filter({task in
                task.title?.lowercased().contains(currentFilter.lowercased()) ?? false || task.taskDesc?.lowercased().contains(currentFilter.lowercased()) ?? false
            })
        }
        label.text = "\(filterTasks.count) task(s)"
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
    
    private func handleDeleteTask(section: Int, index: Int) {
        let deleteAlert = UIAlertController(title: "Delete this task?", message: "This action cannot be undone", preferredStyle: UIAlertController.Style.alert)
        deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
            guard let appDelegate =
                    UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext =
                appDelegate.persistentContainer.viewContext
            managedContext.delete(self.tasksByDays[section][index])
            self.fetchTasks()
        }))
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
        }))
        present(deleteAlert, animated: true, completion: nil)
    }
    
    private func handleCloneTask(section: Int, index: Int) {
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let cloneTask = tasksByDays[section][index]
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
        showOrHideEmptyView()
    }
    
    private func filterTasks() {
        setupData(keyword: currentFilter)
        taskListTableView.reloadData()
        showOrHideEmptyView()
        setupToolbar()
    }
    
    private func setupFilterView() {
        if (currentFilter.isEmpty) {
            title = "All tasks"
            self.navigationItem.rightBarButtonItem = nil
        } else {
            title = "Filtering: \(currentFilter)"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Reset filter", style: .done, target: self, action: #selector(self.clearFilter(_:)))

        }
    }
    
    @objc func clearFilter(_ sender: Any) {
        currentFilter = ""
        searchController.searchBar.text = ""
        filterTasks()
        setupFilterView()
    }
    
    @objc func addBtnClicked(_ sender: Any) {
        let detailVC = DetailViewController()
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actionClone = UIContextualAction(style: .normal,
                                             title: "Clone") { [weak self] (action, view, completionHandler) in
            self?.handleCloneTask(section: indexPath.section, index: indexPath.row)
            completionHandler(true)
        }
        let action = UIContextualAction(style: .normal,
                                        title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.handleDeleteTask(section: indexPath.section, index: indexPath.row)
            completionHandler(true)
        }
        action.backgroundColor = .systemRed
        actionClone.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [action, actionClone])
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
        currentFilter = searchBar.text ?? ""
        searchController.searchBar.text = currentFilter
        filterTasks()
        setupFilterView()
    }
}
