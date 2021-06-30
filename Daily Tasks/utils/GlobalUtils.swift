//
//  GlobalUtils.swift
//  Daily Tasks
//
//  Created by Phương Anh Tuấn on 24/06/2021.
//

import Foundation

func getDateFromMilliseconds(millis: Int64) -> String {
    let date = NSDate(timeIntervalSince1970: TimeInterval(millis))
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.dateFormat = "dd/MM/yyyy"
    formatter.locale = NSLocale(localeIdentifier: "en_US") as Locale?
    return formatter.string(from: date as Date)
}
