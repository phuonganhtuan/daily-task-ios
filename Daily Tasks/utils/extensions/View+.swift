//
//  ViewExtensions.swift
//  SafeOne
//
//  Created by Phương Anh Tuấn on 07/04/2021.
//  Copyright © 2021 Diendh1_laptop_01. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    static let defaultAnimTime = 0.2
    
    func show() {
        isHidden = false
    }
    
    func hide() {
        isHidden = true
    }
    
    func showWithAnimation(duration: Double = defaultAnimTime) {
        self.alpha = 0
        self.show()
        UIView.animate(withDuration: duration) {
            self.alpha = 1
        }
    }
    
    func hideWithAnimation(duration: Double = defaultAnimTime) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
        }) { (finished) in
            self.isHidden = finished
        }
    }
    
    func showWithAnimationLinear(duration: Double = defaultAnimTime){
        self.center.y += self.bounds.height
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseIn],
                       animations: {
                        self.center.y -= self.bounds.height
                        self.layoutIfNeeded()
                       }, completion: nil)
        self.show()
    }
    
    func hideWithAnimationLinear(duration: Double = defaultAnimTime, completion: (() -> ())?){
        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear],
                       animations: {
                        self.center.y += self.bounds.height
                        self.layoutIfNeeded()
                       },  completion: {(_ completed: Bool) -> Void in
                        self.hide()
                        if completion != nil {
                            completion!()
                        }
                       })
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    enum ViewSide {
        case left, right, top, bottom
    }
    
    func addBorder(toSide side: ViewSide, withColor color: UIColor, andThickness thickness: CGFloat) {
        
        let border = CALayer()
        border.backgroundColor = color.cgColor
        
        switch side {
        case .left: border.frame = CGRect(x:bounds.minX, y: bounds.minY, width: thickness, height: bounds.height)
        case .right: border.frame = CGRect(x: bounds.maxX - thickness, y: bounds.minY, width: thickness, height: bounds.height)
        case .top: border.frame = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: thickness)
        case .bottom: border.frame = CGRect(x: bounds.minX, y: bounds.maxY - thickness, width: bounds.width, height: thickness)
        }
        
        layer.addSublayer(border)
    }
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        if layer.shadowPath == nil {
            layer.masksToBounds = false
            clipsToBounds = false
            layer.shadowColor = color.cgColor
            layer.shadowOpacity = opacity
            layer.shadowOffset = offSet
            layer.shadowRadius = radius
            
            layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
            layer.shouldRasterize = true
            layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        }
    }
    
    func roundCorners(corners: CACornerMask, radius: CGFloat) {
        clipsToBounds = true
        layer.cornerRadius = radius
        layer.maskedCorners = corners
    }
}

extension UITextField {
    
    func clearText() {
        self.text = ""
    }
}

extension UIButton {
    
    func disable() {
        self.isEnabled = false
    }
    
    func enable() {
        self.isEnabled = true
    }
    
    func flipVerticalWithAnimation(duration: Double = defaultAnimTime) {
        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform(rotationAngle: -CGFloat.pi)
        }
    }
    
    func toDefaultRotationWithDuration(duration: Double = defaultAnimTime) {
        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform.identity
        }
    }
}

extension UITextField {
    
    func disable() {
        self.isEnabled = false
    }
    
    func enable() {
        self.isEnabled = true
    }
    
    //    fileprivate func setPasswordToggleImage(_ button: UIButton) {
    //        if isSecureTextEntry {
    //            button.setImage(UIImage(named: "ic_show_password")!.imageWithColor(color: #colorLiteral(red: 0.7338053584, green: 0.7525397539, blue: 0.7776536345, alpha: 1)), for: .normal)
    //        } else {
    //            button.setImage(UIImage(named: "ic_hide_password")!.imageWithColor(color: #colorLiteral(red: 0.7338053584, green: 0.7525397539, blue: 0.7776536345, alpha: 1)), for: .normal)
    //        }
    //    }
    //
    //    func enablePasswordToggle() {
    //        let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.frame.size.height, height: self.frame.size.height))
    //        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.height, height: self.frame.size.height))
    //        setPasswordToggleImage(button)
    //        button.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    //        button.imageView?.contentMode = .scaleAspectFit
    //        button.addTarget(self, action: #selector(self.togglePasswordView), for: .touchUpInside)
    //        containerView.addSubview(button)
    //        self.rightView = containerView
    //        self.rightViewMode = .always
    //    }
    //
    //    @IBAction func togglePasswordView(_ sender: Any) {
    //        self.isSecureTextEntry = !self.isSecureTextEntry
    //        setPasswordToggleImage(sender as! UIButton)
    //    }
}

extension UIScrollView {
    func updateContentView(extraHeight: Int = 0) {
        contentSize.height = subviews.sorted(by: { $0.frame.maxY < $1.frame.maxY }).last?.frame.maxY ?? contentSize.height + CGFloat(extraHeight)
    }
}

extension UITableView{
    
    func indicatorView() -> UIActivityIndicatorView{
        var activityIndicatorView = UIActivityIndicatorView()
        if self.tableFooterView == nil{
            let indicatorFrame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 40)
            activityIndicatorView = UIActivityIndicatorView(frame: indicatorFrame)
            activityIndicatorView.isHidden = false
            activityIndicatorView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
            activityIndicatorView.isHidden = true
            self.tableFooterView = activityIndicatorView
            return activityIndicatorView
        } else {
            return activityIndicatorView
        }
    }
    
    func addLoading(_ indexPath:IndexPath, closure: @escaping (() -> Void)){
        indicatorView().startAnimating()
        if let lastVisibleIndexPath = self.indexPathsForVisibleRows?.last {
            if indexPath == lastVisibleIndexPath && indexPath.row == self.numberOfRows(inSection: 0) - 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    closure()
                }
            }
        }
        indicatorView().isHidden = false
    }
    
    func stopLoading(){
        indicatorView().stopAnimating()
        indicatorView().isHidden = true
    }
}
