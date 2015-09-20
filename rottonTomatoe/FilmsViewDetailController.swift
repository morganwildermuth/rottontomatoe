//
//  FilmsViewDetailController.swift
//  rottonTomatoe
//
//  Created by Morgan Wildermuth on 9/17/15.
//  Copyright © 2015 WEF6. All rights reserved.
//

import UIKit

class FilmsViewDetailController: UIViewController {
    var selectedFilm: NSDictionary?

    @IBOutlet weak var filmPoster: UIImageView!
    @IBOutlet weak var filmTitle: UILabel!
    @IBOutlet weak var filmDetailsView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let film = selectedFilm {

            filmTitle.text = film["title"] as! String

            var filmPosterUrl = (film["posters"] as! NSDictionary)["thumbnail"] as! String
            let range = filmPosterUrl.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
            if let range = range {
                filmPosterUrl = filmPosterUrl.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
            }
            let image_url = NSURL(string: filmPosterUrl)
            let url_request = NSURLRequest(URL: image_url!)
            let placeholder = UIImage(named: "no_photo")
            filmPoster.setImageWithURLRequest(url_request, placeholderImage: placeholder, success: { [weak filmPoster] (request:NSURLRequest!,response:NSHTTPURLResponse!, image:UIImage!) -> Void in
                if let retrievedPoster = image {
                    filmPoster!.image = retrievedPoster
                }
                }, failure: { [weak filmPoster]
                    (request:NSURLRequest!,response:NSHTTPURLResponse!, error:NSError!) -> Void in
                    filmPoster!.image = nil
                })


        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
