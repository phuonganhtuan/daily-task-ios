//
//  DBHelper.swift
//  Daily Tasks
//
//  Created by Phương Anh Tuấn on 24/06/2021.
//

import Foundation
import CoreData
import UIKit

public class DBHelper {
    
    func fetch(name: String, predicate: NSPredicate?) -> [NSManagedObject]? {
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: name)
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        do {
            let objects = try managedContext.fetch(fetchRequest)
            return objects
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
}
