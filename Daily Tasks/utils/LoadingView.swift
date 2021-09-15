//
//  LoadingView.swift
//  Daily Tasks
//
//  Created by Phương Anh Tuấn on 09/07/2021.
//

import Foundation
import UIKit

class LoadingView: NSObject {
    
    override init() {
        super.init()
        if let window = UIApplication.shared.keyWindow {
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.3)
            blackView.translatesAutoresizingMaskIntoConstraints = false
            window.addSubview(blackView)
            blackView.frame = window.frame
            window.addSubview(activityIndicatorView)
            activityIndicatorView.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
            activityIndicatorView.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
        }
        self.hide()
    }
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.sizeThatFits(CGSize(width: 48, height: 48))
        aiv.startAnimating()
        return aiv
    }()
    
    let blackView = UIView()
    
    func show() {
        blackView.isHidden = false
        activityIndicatorView.isHidden = false
    }
    
    func hide() {
        blackView.isHidden = true
        activityIndicatorView.isHidden = true
    }
    deinit {
        self.hide()
    }
}
