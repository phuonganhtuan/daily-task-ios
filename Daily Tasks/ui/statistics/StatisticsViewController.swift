//
//  StatisticsViewController.swift
//  Daily Tasks
//
//  Created by Phương Anh Tuấn on 15/09/2021.
//

import UIKit

class StatisticsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setToolbarHidden(true, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
