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
    @IBOutlet weak var retweet: UIButton!
    @IBOutlet weak var favorite: UIButton!
    @IBOutlet weak var retweeted: UIButton!
    @IBOutlet weak var favorited: UIButton!
    
    var tweetID: String = ""
    var favorites: Int?
    var retweets: Int?
    
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
            favorites = tweet.favoritesCount
            retweets = tweet.retweetCount
            
            tweetID = tweet.id as! String
            
            retweetcountLabel.text! == "0" ? (retweetcountLabel.isHidden = true) : (retweetcountLabel.isHidden = false)
            favoritecountLabel.text! == "0" ? (favoritecountLabel.isHidden = true) : (favoritecountLabel.isHidden = false)
            
            if(tweet.favorited!)
            {
                favorite.isHidden = true
                favorited.isHidden = false
                favoritecountLabel.textColor = UIColor(red: 229/255, green: 34/255, blue: 74/255, alpha: 1)
            }
            else
            {
                favorite.isHidden = false
                favorited.isHidden = true
                self.favoritecountLabel.textColor = UIColor(red: 170/255, green: 184/255, blue: 194/255, alpha: 1)
            }
            if(tweet.retweeted!)
            {
                retweet.isHidden = true
                retweeted.isHidden = false
                self.retweetcountLabel.textColor = UIColor(red: 1/255, green: 217/255, blue: 137/255, alpha: 1)
            }
            else
            {
                retweet.isHidden = false
                retweeted.isHidden = true
                self.retweetcountLabel.textColor = UIColor(red: 170/255, green: 184/255, blue: 194/255, alpha: 1)

            }
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
            self.retweets = self.retweets! + 1
            self.retweetcountLabel.text = "\(self.retweets!)"
            
            if self.retweetcountLabel.text! > "0" {
                self.retweetcountLabel.isHidden = false
            }
            
            self.retweet.isHidden = true
            self.retweeted.isHidden = false
            self.retweetcountLabel.textColor = UIColor(red: 1/255, green: 217/255, blue: 137/255, alpha: 1)
            
        })
    }
    
    
    @IBAction func unretweet(_ sender: Any) {
        TwitterClient.sharedInstance?.unretweet(tweet: tweet, params: nil, completion: { (error) -> () in
            
            self.retweets = self.retweets! - 1
            self.retweetcountLabel.text = "\(self.retweets!)"
            
            if self.retweetcountLabel.text! < "0" {
                self.retweetcountLabel.isHidden = true
            }
            
            self.retweet.isHidden = false
            self.retweeted.isHidden = true
            self.retweetcountLabel.textColor = UIColor(red: 170/255, green: 184/255, blue: 194/255, alpha: 1)
        })
    }
    
    
    @IBAction func favorite(_ sender: Any) {
        TwitterClient.sharedInstance?.like(id: Int(tweetID)!, params: nil, completion: {(error) -> () in
            
            self.favorites = self.favorites! + 1
            self.favoritecountLabel.text = "\(self.favorites!)"
            
            if self.favoritecountLabel.text! > "0" {
                self.favoritecountLabel.isHidden = false
            }
            
            
            self.favorite.isHidden = true
            self.favorited.isHidden = false
            self.favoritecountLabel.textColor = UIColor(red: 229/255, green: 34/255, blue: 74/255, alpha: 1)
            
        })
    }
    
    @IBAction func unfavorite(_ sender: Any) {
        TwitterClient.sharedInstance?.unlike(id: Int(tweetID)!, params: nil, completion: {(error) -> () in
            
            self.favorites = self.favorites! - 1
            self.favoritecountLabel.text = "\(self.favorites!)"
            
            if self.favoritecountLabel.text! < "0" {
                self.favoritecountLabel.isHidden = true
            }
            
           
            self.favorite.isHidden = false
            self.favorited.isHidden = true
            
            self.favoritecountLabel.textColor = UIColor(red: 170/255, green: 184/255, blue: 194/255, alpha: 1)
        })
    }
    

}
