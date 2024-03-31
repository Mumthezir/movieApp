//
//  Constants.swift
//  movieApp
//
//  Created by Mumthasir mohammed on 27/03/24.
//

import Foundation

struct Log {
    static func debug(_ msg: Any) {
        #if DEBUG
        print("[DEBUG] \(msg)")
        #endif
    }
}

struct Constants {
   
    struct  response {
        static let tokenExpired = 419
        static let success = 200
        static let internalServerError = 500
        static let failure = 0
    }
    
    struct Storyboard {
        static let toastVC = "toastVC"
        static let movieDetailVC = "movieDetailViewController"
        static let myFavVC = "myFavoritesViewController"
    }
    
    struct URL {
        static let movieListUrl = "https://movies-api14.p.rapidapi.com/shows"
    }
    
    enum alertType: String {
           case logInType
           case registrationSuccessMessage
           case other
    }
    
    struct Messages {
        static let noNetworkAvailable = "No network available!"
        static let someErrorOccurred =  "Internal Server error!"
        static let internalServerError = "Some error occurred!"
     }
    
    struct AppNotification {
        static let ViewToast = Notification.Name("viewToast")
        static let NetworkIsOffline = Notification.Name("networkIsOfflineNotification")
    }
    
    struct UserDefaults {
        static let favoritesList =  "favoritesList"
    }
}
