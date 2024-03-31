//
//  MyFavoritesViewController.swift
//  movieApp
//
//  Created by Mumthasir mohammed on 31/03/24.
//

import UIKit

//MARK: - Custom cell
class FavCell: UITableViewCell {
    @IBOutlet weak var lblMovieName: UILabel!
    @IBOutlet weak var lblMovieDecription: UILabel!
    @IBOutlet weak var lblMovieReleaseDate: UILabel!
    @IBOutlet weak var ivMovieIcon: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        self.ivMovieIcon.contentMode = .scaleAspectFill
        self.ivMovieIcon.setCorner(radius: 6)
    }
}

class MyFavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var favoritesTableView: UITableView!
    private var recievedMovieList = [MovieElement]()
    private var favoritedMovieList = [MovieElement]()
    private var delegate = CustomAppDelegate.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        favoritesTableView.register(UINib(nibName: "favCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        favoritesTableView.estimatedRowHeight = 140
        favoritesTableView.rowHeight = UITableView.automaticDimension
        favoritesTableView.separatorStyle = .none
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        recievedMovieList = delegate.getMovieList()
        getFavorites()
    }

    //MARK: - TableView delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritedMovieList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favCell", for: indexPath) as! FavCell
        cell.containerView.setCorner(radius: 10)
        cell.containerView.layer.borderWidth = 0
        
        cell.lblMovieName.text = favoritedMovieList[indexPath.row].title
        cell.lblMovieDecription.text = favoritedMovieList[indexPath.row].overview
        cell.ivMovieIcon.sd_setImage(with: URL(string: favoritedMovieList[indexPath.row].posterPath), completed: nil)
        
        // Releasing Date formatting
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        
        let releaseDate = favoritedMovieList[indexPath.row].firstAired
        let date = dateFormatterGet.date(from: releaseDate)

        cell.lblMovieReleaseDate.text = "Released on: \(dateFormatterPrint.string(from: date ??  Date(timeIntervalSince1970: 0)))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movieDetailVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.movieDetailVC) as! MovieDetailViewController
        self.delegate.setMovieDetails(movieDetails: [favoritedMovieList[indexPath.row]])
        self.navigationController?.pushViewController(movieDetailVC, animated: true)
    }
    
    //MARK: - Methods
    func getFavorites() {
        let defaults = UserDefaults.standard
        if let favorites = defaults.stringArray(forKey: Constants.UserDefaults.favoritesList) {
            for i in 0..<favorites.count {
                for j in 0..<recievedMovieList.count {
                    if favorites[i] == recievedMovieList[j].title {
                        favoritedMovieList.append(recievedMovieList[j])
                    }
                }
            }
        }
        favoritesTableView.reloadData()
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
