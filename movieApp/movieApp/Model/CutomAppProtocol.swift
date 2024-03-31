//
//  CustomAppProtocol.swift
//  movieApp
//
//  Created by Mumthasir mohammed on 30/03/24.
//


import Foundation
import UIKit

protocol CustomAppProtocol {
    func displayToast(vc: UIViewController, message: String, seconds: Double, completion: (() -> Void)?)
}
