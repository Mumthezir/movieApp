//
//  MovieListViewController.swift
//  movieApp
//
//  Created by Mumthasir mohammed on 31/03/24.
//


import UIKit
import SDWebImage

//MARK: - Custom movie cell
class MovieCell: UITableViewCell {
    @IBOutlet weak var lblMovieName: UILabel!
    @IBOutlet weak var lblMovieDecription: UILabel!
    @IBOutlet weak var lblMovieReleaseDate: UILabel!
    @IBOutlet weak var ivMovieIcon: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var btnFavorite: UIButton!
    
    override func awakeFromNib() {
        self.ivMovieIcon.contentMode = .scaleAspectFill
        self.ivMovieIcon.setCorner(radius: 6)
    }
}

class MovieListViewController: UIViewController, UITableViewDelegate {
    
    // MARK: - IBOutlets & Vars
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var movieListTableView: UITableView!
    private let api = APIService.shared
    private var movieList = [MovieElement]()
    private var movieListBeforeSearch = [MovieElement]()
    private var delegate = CustomAppDelegate.shared
    var searchActive : Bool = false
    var favoritedMovieNamesArray = [String]()
    
    // MARK: - viewDidLoad & viewDidAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        movieListTableView.register(UINib(nibName: "movieCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        movieListTableView.estimatedRowHeight = 140
        movieListTableView.rowHeight = UITableView.automaticDimension
        movieListTableView.separatorStyle = .none
        
        movieListCall()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(forName: Constants.AppNotification.NetworkIsOffline, object: nil, queue: nil, using: networkIsOffline)
        NotificationCenter.default.addObserver(forName: Constants.AppNotification.ViewToast, object: nil, queue: nil, using: displayToast)
        
        if (!Reachability.isConnectedToNetwork()) {
            NotificationCenter.default.post(name: Constants.AppNotification.NetworkIsOffline, object: self)
        }
    }
    
    // MARK: - TableView delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieCell
        cell.containerView.setCorner(radius: 10)
        cell.containerView.layer.borderWidth = 0
        
        cell.lblMovieName.text = movieList[indexPath.row].title
        cell.lblMovieDecription.text = movieList[indexPath.row].overview
        cell.ivMovieIcon.sd_setImage(with: URL(string: movieList[indexPath.row].posterPath), completed: nil)
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        
        let releaseDate = movieList[indexPath.row].firstAired
        let date = dateFormatterGet.date(from: releaseDate)
        
        cell.lblMovieReleaseDate.text = "Released on: \(dateFormatterPrint.string(from: date ??  Date(timeIntervalSince1970: 0)))"
        cell.btnFavorite.tag = indexPath.row
        cell.btnFavorite.addTarget(self, action:#selector(favoriteTap), for: .touchUpInside)
        
        let tag = indexPath.row
        let defaults = UserDefaults.standard
        cell.btnFavorite.setImage(#imageLiteral(resourceName: "unfavorited"), for: .normal)
        
        if let favoriteVal = defaults.string(forKey: movieList[tag].title) {
            Log.debug(favoriteVal)
            if favoriteVal == "0" {
                cell.btnFavorite.setImage(#imageLiteral(resourceName: "unfavorited"), for: .normal)
            } else {
                cell.btnFavorite.setImage(#imageLiteral(resourceName: "favorited"), for: .normal)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movieDetailVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.movieDetailVC) as! MovieDetailViewController
        self.delegate.setMovieDetails(movieDetails: [movieList[indexPath.row]])
        self.navigationController?.pushViewController(movieDetailVC, animated: true)
    }
    
    //MARK: - Methods
    @objc func favoriteTap(sender:UIButton) {
        let tag = sender.tag
        let indexPath = IndexPath(row: tag, section: 0)
        let cell = movieListTableView.cellForRow(at: indexPath) as! MovieCell
        
        let defaults = UserDefaults.standard
        
        if let favoriteVal = defaults.string(forKey: movieList[tag].title) {
            Log.debug(favoriteVal)
            
            if favoriteVal == "0" {
                var defaultsArray: [String] = defaults.object(forKey: Constants.UserDefaults.favoritesList) as? [String] ?? []
                defaultsArray.append(movieList[tag].title)
                defaults.set(defaultsArray, forKey: Constants.UserDefaults.favoritesList)
                
                defaults.set(1, forKey: movieList[tag].title)
                cell.btnFavorite.setImage(#imageLiteral(resourceName: "favorited"), for: .normal)
                movieListTableView.reloadRows(at: [indexPath], with: .top)
            } else {
                var defaultsArray: [String] = defaults.object(forKey: Constants.UserDefaults.favoritesList) as? [String] ?? []
                if let index = defaultsArray.firstIndex(of: movieList[tag].title) {
                    defaultsArray.remove(at: index)
                }
                defaults.set(defaultsArray, forKey: Constants.UserDefaults.favoritesList)
                
                defaults.set(0, forKey: movieList[tag].title)
                cell.btnFavorite.setImage(#imageLiteral(resourceName: "unfavorited"), for: .normal)
                movieListTableView.reloadRows(at: [indexPath], with: .top)
            }
        } else {
            var defaultsArray: [String] = defaults.object(forKey: Constants.UserDefaults.favoritesList) as? [String] ?? []
            defaultsArray.append(movieList[tag].title)
            defaults.set(defaultsArray, forKey: Constants.UserDefaults.favoritesList)
            
            defaults.set(1, forKey: movieList[tag].title)
            cell.btnFavorite.setImage(#imageLiteral(resourceName: "favorited"), for: .normal)
            movieListTableView.reloadRows(at: [indexPath], with: .top)
        }
    }
    
    func movieListCall() {
        Indicator.sharedInstance.showIndicator()
        
        let url = Constants.URL.movieListUrl
        api.getMovieList(lawUrl: url) { response in
            self.movieList = response?.movies ?? []
            DispatchQueue.main.async {
                self.movieListBeforeSearch = self.movieList
                self.movieListTableView.reloadData()
                Indicator.sharedInstance.hideIndicator()
            }
        }
    }
}
    
// MARK: - Searchbar delegates
extension MovieListViewController: UITableViewDataSource, UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        
        searchBar.text = nil
        searchBar.resignFirstResponder()
        movieListTableView.resignFirstResponder()
        self.searchBar.showsCancelButton = false
        self.movieList = movieListBeforeSearch
        movieListTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchActive = true;
        self.searchBar.showsCancelButton = true
        
        var filteredData = movieList
        if searchText.isEmpty == false {
            filteredData = movieList.filter({ $0.title.lowercased().contains(searchText.lowercased()) })
            movieList = filteredData
            movieListTableView.reloadData()
        } else {
            movieList = movieListBeforeSearch
            movieListTableView.reloadData()
        }
    }
    
    @IBAction func bookBtnAction(_ sender: Any) {
        let myFavVc = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.myFavVC) as! MyFavoritesViewController
        self.delegate.setMovieList(list: movieList)
        self.navigationController?.pushViewController(myFavVc, animated: true)
    }
    
    @objc func displayToast(notif: Notification) {
        if let info = notif.userInfo {
            if let msg = info["msg"] as? String {
                viewToast(msg)
            }
        }
    }
    @objc func networkIsOffline(notif: Notification) {
        viewToast(Constants.Messages.noNetworkAvailable)
    }
    
    func viewToast(_ msg: String) {
        let screen = self.storyboard!.instantiateViewController(withIdentifier: Constants.Storyboard.toastVC) as! ToastViewController
        screen.setMessage(msg)
        self.present(screen, animated: false, completion: nil)
    }
}

