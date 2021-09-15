//
//  MainViewController.swift
//  Daily Tasks
//
//  Created by Phương Anh Tuấn on 24/06/2021.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var menuTableView: UITableView!
    
    var cellTitles = ["Today tasks", "All tasks", "Statistics", "Import & Export", "About Daily Tasks"]
    var imageNames = ["clock", "list.bullet", "chart.bar.xaxis", "gobackward", "person"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        openTodayTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setToolbarHidden(true, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
        menuTableView.reloadData()
    }
    
    private func setupViews() {
        title = "Folders"
        menuTableView.dataSource = self
        menuTableView.delegate = self
        menuTableView.register(UINib(nibName: "MenuTableViewCell", bundle: nil), forCellReuseIdentifier: "menuCell")
        menuTableView.rowHeight = 48
    }
    
    private func openTodayTasks() {
        let todayVC = TodayViewController()
        navigationController?.pushViewController(todayVC, animated: true)
    }
    
    private func openListTasks() {
        let listVC = TaskListViewController()
        navigationController?.pushViewController(listVC, animated: true)
    }
    
    private func openBackupPage() {
        let backupVC = BackupViewController()
        navigationController?.pushViewController(backupVC, animated: true)
    }
    
    private func openStatisticsPage() {
        let statisticsVC = StatisticsViewController()
        navigationController?.pushViewController(statisticsVC, animated: true)
    }
    
    private func openAboutPage() {
        let aboutVC = AboutViewController()
        navigationController?.pushViewController(aboutVC, animated: true)
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            openTodayTasks()
        case 1:
            openListTasks()
        case 2:
            openStatisticsPage()
        case 3:
            openBackupPage()
        case 4:
            openAboutPage()
        default:
            return
        }
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as? MenuTableViewCell else {
            return UITableViewCell()
        }
        cell.accessoryType = .disclosureIndicator
        let imageName = imageNames[indexPath.row]
        cell.cellImageView.image = UIImage(systemName: imageName)
        let title = cellTitles[indexPath.row]
        cell.cellLabel.text = title
        return cell
    }
}
