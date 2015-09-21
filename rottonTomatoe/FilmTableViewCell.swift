//
//  FilmTableViewCell.swift
//  rottonTomatoe
//
//  Created by Morgan Wildermuth on 9/17/15.
//  Copyright © 2015 WEF6. All rights reserved.
//

import UIKit

class FilmTableViewCell: UITableViewCell {

    var audienceRating: Int?
    var criticsRating: Int?

    @IBOutlet weak var synopsis: UILabel!
    @IBOutlet weak var filmTitle: UILabel!
    @IBOutlet weak var filmPoster: UIImageView!
    @IBOutlet weak var criticRatingIcon: UIImageView!
    @IBOutlet weak var mpaaRating: UILabel!
    
    @IBOutlet weak var audienceRatingIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    func retrieveRatingIcon(rating: Int) -> UIImage{
        switch rating {
        case 0...59:
            return UIImage(named: "splat")!
        case 60...74:
            return UIImage(named: "fresh")!
        case 75...100:
            return UIImage(named: "certified_fresh")!
        default:
            return UIImage(named: "spalt")!
        }
    }

    override func prepareForReuse() {
        self.filmPoster.image = nil;
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
