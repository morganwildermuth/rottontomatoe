//
//  FilmsViewController.swift
//  rottonTomatoe
//
//  Created by Morgan Wildermuth on 9/17/15.
//  Copyright © 2015 WEF6. All rights reserved.
//

import UIKit
import AFNetworking

class FilmsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var filmsTableView: UITableView!
    var movies: NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filmsTableView.dataSource = self;
        filmsTableView.delegate = self;
        filmsTableView.rowHeight = 320
        
        let url = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")!

        let request = NSURLRequest(URL: url)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            
            if let data = data {
                dispatch_async(dispatch_get_main_queue()) {
                    var responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                    self.movies = responseDictionary["movies"] as? NSArray
                    self.filmsTableView.reloadData()
                }
            } else {
                puts("task error: \(error)")
            }
        });
        
        task.resume()

        // Do any additional setup after loading the view.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = filmsTableView.dequeueReusableCellWithIdentifier("filmCell", forIndexPath: indexPath) as! FilmTableViewCell
        cell.selectionStyle = .None

        let currentFilm = movies![indexPath.row] as! NSDictionary
        var filmPosterUrl = (currentFilm["posters"] as! NSDictionary)["thumbnail"] as! String
        let range = filmPosterUrl.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            filmPosterUrl = filmPosterUrl.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
        cell.filmTitle.text = currentFilm["title"] as! String

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

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movieCount = movies?.count {
            return movieCount
        } else {
            return 0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var vc = segue.destinationViewController as! FilmsViewDetailController
        var indexPath = filmsTableView.indexPathForCell(sender as! FilmTableViewCell)!.row
        var cell = self.movies![indexPath]


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
