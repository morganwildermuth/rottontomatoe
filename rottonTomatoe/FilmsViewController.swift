//
//  FilmsViewController.swift
//  rottonTomatoe
//
//  Created by Morgan Wildermuth on 9/17/15.
//  Copyright © 2015 WEF6. All rights reserved.
//

import UIKit
import AFNetworking
import KVNProgress

class FilmsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var networkAlertView: UIView!
    @IBOutlet weak var networkAlertLabel: UILabel!
    @IBOutlet weak var filmsTableView: UITableView!
    var searchActive : Bool = false
    var movies: NSArray?
    var filteredMovies: NSArray?
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        KVNProgress.showWithStatus("Finding movies...")
        
        filmsTableView.dataSource = self;
        filmsTableView.delegate = self;
        searchBar.delegate = self
        filmsTableView.rowHeight = 320
        networkAlertView.hidden = true
        
        setupRefreshController()
        loadData()

        KVNProgress.dismiss()
        
        // Do any additional setup after loading the view.
    }
  
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText != "" {
            filteredMovies = movies!.filter({
                var currentFilm = $0 as! NSDictionary
                var currentFilmTitle = currentFilm["title"] as! String
                return currentFilmTitle.rangeOfString(searchText) != nil
            })
        }

        if(filteredMovies!.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.filmsTableView.reloadData()
    }

    func refresh(sender: AnyObject){
        loadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Remove seperator inset
        if cell.respondsToSelector("setSeparatorInset:") {
            cell.separatorInset = UIEdgeInsetsZero
        }
        
        // Prevent the cell from inheriting the Table View's margin settings
        if cell.respondsToSelector("setPreservesSuperviewLayoutMargins:") {
            cell.preservesSuperviewLayoutMargins = false
        }
        
        // Explictly set your cell's layout margins
        if cell.respondsToSelector("setLayoutMargins:") {
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = filmsTableView.dequeueReusableCellWithIdentifier("filmCell", forIndexPath: indexPath) as! FilmTableViewCell
        cell.selectionStyle = .None
        var currentFilm: NSDictionary
        if searchActive {
            currentFilm = filteredMovies![indexPath.row] as! NSDictionary
        } else {
            currentFilm = movies![indexPath.row] as! NSDictionary
        }
        
        cell.filmTitle.text = currentFilm["title"] as! String
        cell.synopsis.text = currentFilm["synopsis"] as! String
        cell.mpaaRating.text = currentFilm["mpaa_rating"] as! String
        
        setCellImage(cell, currentFilm: currentFilm)
        setCellRatings(cell, currentFilm: currentFilm)

        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            if let movieCount = filteredMovies?.count {
                return movieCount
            }
        }
        if let movieCount = movies?.count {
            return movieCount
        } else {
            return 0
        }
    }
    
    private func setCellRatings(cell: FilmTableViewCell, currentFilm: NSDictionary){
        let ratings = currentFilm["ratings"] as! NSDictionary
        let criticsScore = ratings["critics_score"] as! Int
        let audienceScore = ratings["audience_score"] as! Int
        
        cell.criticRatingIcon.image = cell.retrieveRatingIcon(criticsScore)
        cell.criticsRating = criticsScore
        cell.audienceRatingIcon.image = cell.retrieveRatingIcon(audienceScore)
        cell.audienceRating = audienceScore
    }

    private func setCellImage(cell: FilmTableViewCell, currentFilm: NSDictionary){
        var filmPosterUrl = (currentFilm["posters"] as! NSDictionary)["thumbnail"] as! String
        let range = filmPosterUrl.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            filmPosterUrl = filmPosterUrl.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
        let image_url = NSURL(string: filmPosterUrl)
        let url_request = NSURLRequest(URL: image_url!)
        let placeholder = UIImage(named: "no_photo")
        cell.filmPoster.setImageWithURLRequest(url_request, placeholderImage: placeholder, success: { [weak cell] (request:NSURLRequest!,response:NSHTTPURLResponse!, image:UIImage!) -> Void in
            if let cell_for_image = cell {
                cell_for_image.filmPoster.image = image
            }
            }, failure: { [weak cell]
                (request:NSURLRequest!,response:NSHTTPURLResponse!, error:NSError!) -> Void in
                if let cell_for_image = cell {
                    cell_for_image.filmPoster.image = nil
                }
            })
    }

    private func showNetworkError(){
        self.view.sendSubviewToBack(self.filmsTableView)
        self.networkAlertView.hidden = false
        self.networkAlertLabel.text = "⚠️ Network Error"
    }

    private func setupRefreshController(){
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        filmsTableView.addSubview(refreshControl)
    }

    private func loadData(){
        let url = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")!
        
        let request = NSURLRequest(URL: url)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            
            if let error = error {
                if error == -1009 {
                    self.showNetworkError()
                }
            }

            if let data = data {
                dispatch_async(dispatch_get_main_queue()) {
                    do {
                        var responseDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                        self.movies = responseDictionary["movies"] as? NSArray
                        self.filmsTableView.reloadData()
                        self.refreshControl.endRefreshing()
                    } catch {
                        self.view.sendSubviewToBack(self.filmsTableView)
                        self.networkAlertView.hidden = false
                        self.networkAlertLabel.text = "⚠️ Invalid Film Data"
                    }

                }
            } else {
                self.view.sendSubviewToBack(self.filmsTableView)
                self.networkAlertView.hidden = false
                self.networkAlertLabel.text = "⚠️ No Films Retrieved"
            }
        });
        
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var vc = segue.destinationViewController as! FilmsViewDetailController
        var indexPath = filmsTableView.indexPathForCell(sender as! FilmTableViewCell)
        var currentFilm: NSDictionary
        if searchActive {
            currentFilm = self.filteredMovies![indexPath!.row] as! NSDictionary
        } else {
            currentFilm = self.movies![indexPath!.row] as! NSDictionary
        }
        vc.selectedFilm = currentFilm
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
