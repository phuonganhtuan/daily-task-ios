//
//  DetailViewController.swift
//  Daily Tasks
//
//  Created by Phương Anh Tuấn on 23/06/2021.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var textTitle: UITextField!
    @IBOutlet weak var textDesc: UITextView!
    
    var isEdit = false
    var task = TaskEntity()
    
    var index = 0
    
    private var date = Date()
    private let dbHelper = DBHelper()
    
    private var btnDone: UIBarButtonItem = {
        let doneButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(btnDoneClicked(_:)))
        doneButton.title = "Done"
        return doneButton
    }()
    
    private var isDone = false
    
    private var piority: Int16 = 1 {
        didSet {
            createToolbarIcons()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        if isEdit {
            displayTask()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    private func createToolbarIcons() {
        print("Create toolbar icons")
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 64))
        var items = [UIBarButtonItem]()
        let btnStatus = UIBarButtonItem(image: UIImage(), style: .done, target: self, action: #selector(btnStatusClicked(_:)))
        btnStatus.setBackgroundImage(UIImage(named: "ic_uncheck"), for: .normal, barMetrics: .default)
        if isDone {
            btnStatus.setBackgroundImage(UIImage(named: "ic_check"), for: .normal, barMetrics: .default)
        }
        let btnDate = UIBarButtonItem(image: UIImage(named: "ic_calendar"), style: .done, target: self, action: #selector(btnDateClicked(_:)))
        let btnP1 = UIButton()
        btnP1.setImage(UIImage(named: "ic_p_1"), for: .normal)
        btnP1.addTarget(self, action: #selector(p1Clicked(_:)), for: .touchUpInside)
        let btnP2 = UIButton()
        btnP2.setImage(UIImage(named: "ic_p_2"), for: .normal)
        btnP2.addTarget(self, action: #selector(p2Clicked(_:)), for: .touchUpInside)
        let btnP3 = UIButton()
        btnP3.setImage(UIImage(named: "ic_p_3"), for: .normal)
        btnP3.addTarget(self, action: #selector(p3Clicked(_:)), for: .touchUpInside)
        
        switch piority {
        case 1:
            btnP1.setBackgroundImage(UIImage(named: "ic_p_outline"), for: .normal)
            break
        case 2:
            btnP2.setBackgroundImage(UIImage(named: "ic_p_outline"), for: .normal)
            break
        case 3:
            btnP3.setBackgroundImage(UIImage(named: "ic_p_outline"), for: .normal)
            break
        default:
            btnP1.setBackgroundImage(UIImage(named: "ic_p_outline"), for: .normal)
        }
        let btbBarP1 = UIBarButtonItem(customView: btnP1)
        let btbBarP2 = UIBarButtonItem(customView: btnP2)
        let btbBarP3 = UIBarButtonItem(customView: btnP3)
        items.append(
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        )
        items.append(btnStatus)
        items.append(
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        )
        items.append(
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        )
        items.append(btnDate)
        items.append(
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        )
        items.append(
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        )
        items.append(btbBarP1)
        items.append(
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        )
        items.append(btbBarP2)
        items.append(
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        )
        items.append(btbBarP3)
        items.append(
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        )
        toolbar.items = items
        textDesc.inputAccessoryView = toolbar
        textTitle.inputAccessoryView = toolbar
        textDesc.reloadInputViews()
        textTitle.reloadInputViews()
    }
    
    private func displayTask() {
        date = convertStringToDate(dateStr: task.value(forKey: "createDate") as! String, format: "dd/MM/yyyy")
        labelDate.text = getDateFromMilliseconds(millis: Int64(date.timeIntervalSince1970))
        textTitle.text = task.value(forKey: "title") as? String
        textDesc.text = task.value(forKey: "taskDesc") as? String
        isDone = ((task.value(forKey: "status") as? Int16 ?? 0) != 0)
        navigationItem.rightBarButtonItem?.isEnabled = true
        piority = task.value(forKey: "priority") as? Int16 ?? 1
        createToolbarIcons()
    }
    
    private func setupViews() {
        title = ""
        labelDate.text = getDateFromMilliseconds(millis: Int64(date.timeIntervalSince1970))
        navigationItem.rightBarButtonItem  = btnDone
        textDesc.contentInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        isDone = false
        createToolbarIcons()
        textTitle.delegate = self
        textTitle.addTarget(self, action: #selector(textTitleChanged), for: .editingChanged)
        navigationItem.rightBarButtonItem?.isEnabled = false
        textTitle.becomeFirstResponder()
    }
    
    private func convertStringToDate(dateStr:String, format:String) -> Date{
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = format
        return dateFormat.date(from: dateStr)!
    }
    
    @objc private func btnDateClicked(_ sender: Any) {
        let datePickerVC = DatePickerViewController.init()
        datePickerVC.modalPresentationStyle = .overFullScreen
        datePickerVC.date = date
        datePickerVC.dateSelectListener = { selectedDate in
            self.date = selectedDate
            self.labelDate.text = getDateFromMilliseconds(millis: Int64(self.date.timeIntervalSince1970))
        }
        self.present(datePickerVC, animated: true, completion: nil)
    }
    
    @objc func textTitleChanged() {
        if (textTitle.text?.count ?? 0) == 0 {
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    @objc func btnDoneClicked(_ sender: Any) {
        let title = textTitle.text! as String
        let desc = textDesc.text! as String
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        if isEdit {
            let fetchRequest =
                NSFetchRequest<NSManagedObject>(entityName: "TaskEntity")
            do {
                let objects = try managedContext.fetch(fetchRequest)
                objects[index].setValue(title, forKey: "title")
                objects[index].setValue(desc, forKey: "taskDesc")
                objects[index].setValue(piority, forKey: "priority")
                objects[index].setValue(getDateFromMilliseconds(millis:Int64(date.timeIntervalSince1970)), forKey: "createDate")
                if isDone {
                    objects[index].setValue(1, forKey: "status")
                } else {
                    objects[index].setValue(0, forKey: "status")
                }
                try managedContext.save()
                navigationController?.popViewController(animated: true)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
                return
            }
        } else {
            let entity =
                NSEntityDescription.entity(forEntityName: "TaskEntity",
                                           in: managedContext)!
            let taskEntity = NSManagedObject(entity: entity,
                                             insertInto: managedContext)
            taskEntity.setValue(title, forKey: "title")
            taskEntity.setValue(desc, forKey: "taskDesc")
            taskEntity.setValue(piority, forKey: "priority")
            taskEntity.setValue(Int64(Date().timeIntervalSince1970), forKey: "id")
            taskEntity.setValue(getDateFromMilliseconds(millis:Int64(date.timeIntervalSince1970)), forKey: "createDate")
            if isDone {
                taskEntity.setValue(1, forKey: "status")
            } else {
                taskEntity.setValue(0, forKey: "status")
            }
            do {
                try managedContext.save()
                navigationController?.popViewController(animated: true)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    @objc func btnStatusClicked(_ sender: UIBarButtonItem) {
        navigationItem.rightBarButtonItem?.isEnabled = true
        isDone = !isDone
        print("clicked")
        if isDone {
            sender.setBackgroundImage(UIImage(named: "ic_check"), for: .normal, barMetrics: .default)
        } else {
            sender.setBackgroundImage(UIImage(named: "ic_uncheck"), for: .normal, barMetrics: .default)
        }
    }
    
    @objc func p1Clicked(_ sender: UIBarButtonItem) {
        piority = 1
    }
    
    @objc func p2Clicked(_ sender: UIBarButtonItem) {
        piority = 2
    }
    
    @objc func p3Clicked(_ sender: UIBarButtonItem) {
        piority = 3
    }
}
