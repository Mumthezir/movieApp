//
//  ToastViewController.swift
//  movieApp
//
//  Created by Mumthasir mohammed on 27/03/21.
//


import Foundation
import UIKit
import QuartzCore

class ToastViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var toastLabel: UILabel!
    @IBOutlet weak var toastView: UIView!
    
    private var text: String = ""
    private var isLoginType: Bool = false
    private var isRegistrationSuccesfullMessage: Bool = false
    
    //MARK: - ViewDidLoad & ViewDidDisappear
    override func viewDidLoad() {
        super.viewDidLoad()
        addLabelStyle()
        toastLabel.text = text
        if (toastLabel.effectiveUserInterfaceLayoutDirection == .rightToLeft) {
            toastLabel.textAlignment = NSTextAlignment.center
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecognizer.delegate = self
        self.view.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        isLoginType = false
        isRegistrationSuccesfullMessage = false
    }
    
    @objc func handleTap(gestureRecognizer: UIGestureRecognizer) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func yesButtonAction(_ sender: Any) {
         if isRegistrationSuccesfullMessage {
            self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
        } else {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func NoButtonAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func addLabelStyle() {
        toastLabel.numberOfLines = 0
        toastView.setCorner(radius: 6)
    }
    
    func setAlertType(_ isAlertType: Constants.alertType) {
        if isAlertType == Constants.alertType.logInType {
            isLoginType = true
        } else if isAlertType == Constants.alertType.registrationSuccessMessage {
            isRegistrationSuccesfullMessage = true
        } else {
            isLoginType = false
            isRegistrationSuccesfullMessage = false
        }
    }
    
    func setMessage(_ msg: String) {
        text = msg
    }
    
    func getMessage() -> String {
        return text
    }
}
