//
//  MovieDetailViewController.swift
//  movieApp
//
//  Created by Mumthasir mohammed on 31/03/24.
//

import UIKit
import SDWebImage
import MapKit

class MovieDetailViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var lblMainTitle: UILabel!
    @IBOutlet weak var ivBannerImage: UIImageView!
    @IBOutlet weak var lblMovieDetails: UILabel!
    @IBOutlet weak var lblGenres: UILabel!
    
    private var movieDetails = [MovieElement]()
    private var delegate = CustomAppDelegate.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    func setUpView() {
        self.ivBannerImage.setCorner(radius: 8)
        self.ivBannerImage.contentMode = .scaleAspectFit
        self.lblMovieDetails.textAlignment  = .justified
        
        self.movieDetails = delegate.getMovieDetails()
        let details = movieDetails[0]
        self.lblMainTitle.text = details.title
        self.lblMovieDetails.text = details.overview
        self.lblGenres.text = details.genres.joined(separator:", ")
        self.ivBannerImage.sd_setImage(with: URL(string: details.posterPath), completed: nil)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

