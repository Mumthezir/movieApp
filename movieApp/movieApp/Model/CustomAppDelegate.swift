//
//  CustomAppDelegate.swift
//  movieApp
//
//  Created by Mumthasir mohammed on 30/03/24.
//


import Foundation
import UIKit
import SafariServices
import MessageUI

class CustomAppDelegate {
    static let shared = CustomAppDelegate()
    private var movieDetails = [MovieElement]()
    private var list = [MovieElement]()
    
    func setMovieList(list: [MovieElement]) {
        self.list = list
    }
    
    func getMovieList() -> [MovieElement] {
        let list = self.list
        return list
    }
    
    func setMovieDetails(movieDetails: [MovieElement]) {
        self.movieDetails = movieDetails
    }
    
    func getMovieDetails() -> [MovieElement] {
        let movieDetails = self.movieDetails
        return movieDetails
    }
    
    //MARK: - Network check
    func networkCheckAndAlert() {
        NotificationCenter.default.addObserver(forName: Constants.AppNotification.NetworkIsOffline, object: nil, queue: nil, using: networkIsOffline)
        NotificationCenter.default.addObserver(forName: Constants.AppNotification.ViewToast, object: nil, queue: nil, using: displayToast)
         
         if (!Reachability.isConnectedToNetwork()) {
             NotificationCenter.default.post(name: Constants.AppNotification.NetworkIsOffline, object: self)
         }
    }
    func viewToast(_ msg: String, isLoginType: Bool) {
         if let vc = UIApplication.shared.keyWindow?.rootViewController {
             let screen = vc.storyboard!.instantiateViewController(withIdentifier: Constants.Storyboard.toastVC) as! ToastViewController
             screen.setMessage(msg)
            
             var type = String()
             if isLoginType {
                type = Constants.alertType.logInType.rawValue
             } else {
                type = Constants.alertType.other.rawValue
             }
            
             screen.setAlertType(Constants.alertType(rawValue: type)!)
             vc.modalPresentationStyle = .fullScreen
             vc.present(screen, animated: false, completion: nil)
         }
     }

     @objc func networkIsOffline(notif: Notification) {
        viewToast(Constants.Messages.noNetworkAvailable, isLoginType: false)
     }

    @objc func displayToast(notif: Notification) {
         if let info = notif.userInfo {
             if let msg = info["msg"] as? String {
                viewToast(msg, isLoginType: false)
             }
         }
     }
    
    func displayToast(vc: UIViewController, message: String, seconds: Double = 3.0, completion: (() -> Void)? = nil) {
        NotificationCenter.default.post(name: Constants.AppNotification.ViewToast, object: self, userInfo: ["msg": message])
    }
    
    //MARK: - Activity Indicactor
    func setTimeout(_ delay: TimeInterval, block: @escaping () -> Void) -> Timer {
           return Timer.scheduledTimer(timeInterval: delay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: false)
    }
}

