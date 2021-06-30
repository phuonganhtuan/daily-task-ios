//
//  DatePickerViewController.swift
//  Daily Tasks
//
//  Created by Phương Anh Tuấn on 30/06/2021.
//

import UIKit

class DatePickerViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var bgView: UIVisualEffectView!
    
    var date = Date()
    var dateSelectListener: ((Date) -> ())? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }

    private func initViews() {
        if #available(iOS 14, *) {
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = UIDatePickerStyle.wheels
        }
        datePicker.setDate(date, animated: true)
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(saveDate(_:))))
    }
    
    @objc private func saveDate(_ sender: Any) {
        date = datePicker.date
        dateSelectListener?(date)
        self.dismiss(animated: true, completion: nil)
    }
}
