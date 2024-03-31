//
//  APIService.swift
//  movieApp
//
//  Created by Mumthasir mohammed on 30/03/24.
//

import UIKit

class APIService: NSObject {

    enum HttpMethod {
        case get
        case post
    }
    var movieResponse : Movie?
    fileprivate let delegate = CustomAppDelegate.shared
    static let shared = APIService()
  
    func getMovieList(lawUrl: String , callback: @escaping (Movie?) -> Void) {
        self.movieResponse = nil
        
        if (!Reachability.isConnectedToNetwork()) {
            NotificationCenter.default.post(name: Constants.AppNotification.NetworkIsOffline, object: self)
            return callback(self.movieResponse)
        }
        let headers = [
            "X-RapidAPI-Key": "b88f2755a1msh7de8f973629fdacp164257jsn2a1e8dec51fd",
            "X-RapidAPI-Host": "movies-api14.p.rapidapi.com"
        ]

        var request = URLRequest(url: NSURL(string: lawUrl)! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Response code check if response is not success
            if response != nil {
                let httpResponse = response as? HTTPURLResponse
                let statusCode = httpResponse?.statusCode
                if statusCode != Constants.response.success {
                    self.checkResponseCodes(response: httpResponse!)
                    return callback(self.movieResponse)
                }
            }
            
            if (error != nil) {
                return callback(self.movieResponse)
            }
            if let aData = data {
                do {
                    let response = try JSONDecoder().decode(Movie.self, from: aData)
                    callback(response)
                } catch let err {
                    print("JSON parse error", err)
                    callback(self.movieResponse)
                }
            }
        }
        task.resume()
    }

    func checkResponseCodes(response: HTTPURLResponse) {
        if response.statusCode == Constants.response.tokenExpired {
           DispatchQueue.main.async {
            if let topVC = UIApplication.getTopViewController() {
                self.delegate.displayToast(vc: topVC, message: "\(Constants.Messages.someErrorOccurred) - Response Code:\(response.statusCode)")
            }
           }
        } else if response.statusCode == Constants.response.internalServerError {
           DispatchQueue.main.async {
            if let topVC = UIApplication.getTopViewController() {
                self.delegate.displayToast(vc: topVC, message: Constants.Messages.internalServerError)
            }
          }
       } else {
          DispatchQueue.main.async {
            if let topVC = UIApplication.getTopViewController() {
                self.delegate.displayToast(vc: topVC, message: "\(Constants.Messages.someErrorOccurred) - Response Code:\(response.statusCode)")
            }
          }
       }
    }
}
