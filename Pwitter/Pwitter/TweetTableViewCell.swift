//
//  TweetTableViewCell.swift
//  Pwitter
//
//  Created by Peter Le on 2/16/17.
//  Copyright © 2017 CodePath. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var favoritecountLabel: UILabel!
    @IBOutlet weak var retweetcountLabel: UILabel!
    
    var tweetID: String = ""
    
    var tweet: Tweet! {
        didSet{
            nameLabel.text = tweet.user?.name! as String?
            handleLabel.text = ("@\(tweet.user!.screenname!)")
            if let imageURL = tweet.user?.profileUrl
            {
                profileImage.setImageWith(imageURL as URL)
            }
            timestampLabel.text = calculateTimeStamp(timeTweetPostedAgo: tweet.timestamp!.timeIntervalSinceNow)
            contentLabel.text = tweet.text! as String?
            retweetcountLabel.text = "\(tweet.retweetCount)"
            favoritecountLabel.text = "\(tweet.favoritesCount)"
            tweetID = tweet.id as! String
            
            retweetcountLabel.text! == "0" ? (retweetcountLabel.isHidden = true) : (retweetcountLabel.isHidden = false)
            favoritecountLabel.text! == "0" ? (favoritecountLabel.isHidden = true) : (favoritecountLabel.isHidden = false)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImage.layer.cornerRadius = 3
        profileImage.clipsToBounds = true
 
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //This function is courtsey of @r3dcrosse
    func calculateTimeStamp(timeTweetPostedAgo: TimeInterval) -> String {
        // Turn timeTweetPostedAgo into seconds, minutes, hours, days, or years
        var rawTime = Int(timeTweetPostedAgo)
        var timeAgo: Int = 0
        var timeChar = ""
        
        rawTime = rawTime * (-1)
        
        // Figure out time ago
        if (rawTime <= 60) { // SECONDS
            timeAgo = rawTime
            timeChar = "s"
        } else if ((rawTime/60) <= 60) { // MINUTES
            timeAgo = rawTime/60
            timeChar = "m"
        } else if (rawTime/60/60 <= 24) { // HOURS
            timeAgo = rawTime/60/60
            timeChar = "h"
        } else if (rawTime/60/60/24 <= 365) { // DAYS
            timeAgo = rawTime/60/60/24
            timeChar = "d"
        } else if (rawTime/(3153600) <= 1) { // YEARS
            timeAgo = rawTime/60/60/24/365
            timeChar = "y"
        }
        
        return "\(timeAgo)\(timeChar)"
    }
    @IBAction func retweetButton(_ sender: Any) {
        TwitterClient.sharedInstance?.retweet(id: Int(tweetID)!, params: nil, completion: {(error) -> () in
            //self.retweetButton.setImage(UIImage(named: "retweet-icon"), forState: UIControlState.Selected)
            
            if self.retweetcountLabel.text! > "0" {
                //show label if greater than 0
                self.retweetcountLabel.text = String(self.tweet.retweetCount + 1)
            } else {
                //show and increment count when retweeted
                self.retweetcountLabel.isHidden = false
                self.retweetcountLabel.text = String(self.tweet.retweetCount + 1)
            }
        })
    }
    
    
    
    @IBAction func favorite(_ sender: Any) {
        TwitterClient.sharedInstance?.likeTweet(id: Int(tweetID)!, params: nil, completion: {(error) -> () in
            
            
            if self.favoritecountLabel.text! > "0" {
                self.favoritecountLabel.text = String(self.tweet.favoritesCount + 1)
            } else {
                self.favoritecountLabel.isHidden = false
                self.favoritecountLabel.text = String(self.tweet.favoritesCount + 1)
            }
        })
    }
    
    

}
