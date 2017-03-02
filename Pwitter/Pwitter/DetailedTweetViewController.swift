//
//  DetailedTweetViewController.swift
//  Pwitter
//
//  Created by Peter Le on 2/26/17.
//  Copyright © 2017 CodePath. All rights reserved.
//

import UIKit

class DetailedTweetViewController: UIViewController {
    
    var tweet: Tweet?
    var tweetID: String = ""
    var favorites: Int?
    var retweets: Int?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var favoritecountLabel: UILabel!
    @IBOutlet weak var retweetcountLabel: UILabel!
    @IBOutlet weak var retweet: UIButton!
    @IBOutlet weak var favorite: UIButton!
    @IBOutlet weak var retweeted: UIButton!
    @IBOutlet weak var favorited: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let logo = UIImage(named: "black-twitter-logo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        nameLabel.text = tweet?.user?.name! as String?
        handleLabel.text = "@\(tweet!.user!.screenname!)"
        if let profileImageUrl = tweet?.user?.profileUrl!
        {
            profileImage.setImageWith(profileImageUrl as URL)
        }
        contentLabel.text = tweet?.text as String?
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy, h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        dateLabel.text = formatter.string(from: (tweet?.timestamp)! as Date)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        retweetcountLabel.text = numberFormatter.string(from: NSNumber(value: (tweet?.retweetCount)!))
        favoritecountLabel.text = numberFormatter.string(from: NSNumber(value: (tweet?.favoritesCount)!))
        
        if(tweet?.favorited!)!
        {
            favorite.isHidden = true
            favorited.isHidden = false
        }
        else
        {
            favorite.isHidden = false
            favorited.isHidden = true
        }
        if(tweet?.retweeted!)!
        {
            retweet.isHidden = true
            retweeted.isHidden = false
        }
        else
        {
            retweet.isHidden = false
            retweeted.isHidden = true
        }
        
        favorites = tweet?.favoritesCount
        retweets = tweet?.retweetCount
        tweetID = tweet?.id as! String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func back(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func retweet(_ sender: Any) {
        TwitterClient.sharedInstance?.retweet(id: Int(tweetID)!, params: nil, completion: {(error) -> () in
            //self.retweetButton.setImage(UIImage(named: "retweet-icon"), forState: UIControlState.Selected)
            self.retweets = self.retweets! + 1
            self.retweetcountLabel.text = "\(self.retweets!)"
            
            self.retweet.isHidden = true
            self.retweeted.isHidden = false
        })
    }
    
    @IBAction func unretweet(_ sender: Any) {
        TwitterClient.sharedInstance?.unretweet(tweet: tweet!, params: nil, completion: { (error) -> () in
            //print(self.retweets)
            self.retweets = self.retweets! - 1
            self.retweetcountLabel.text = "\(self.retweets!)"
            //print(self.retweets)
    
            self.retweet.isHidden = false
            self.retweeted.isHidden = true
            
        })
    }
    
    @IBAction func favorite(_ sender: Any) {
        TwitterClient.sharedInstance?.like(id: Int(tweetID)!, params: nil, completion: {(error) -> () in
            
            self.favorites = self.favorites! + 1
            self.favoritecountLabel.text = "\(self.favorites!)"
            
            self.favorite.isHidden = true
            self.favorited.isHidden = false
            
        })
    }
    
    @IBAction func unfavorite(_ sender: Any) {
        TwitterClient.sharedInstance?.unlike(id: Int(tweetID)!, params: nil, completion: {(error) -> () in
            
            self.favorites = self.favorites! - 1
            self.favoritecountLabel.text = "\(self.favorites!)"
            
            
            self.favorite.isHidden = false
            self.favorited.isHidden = true
            
            
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "TweetUserProfile")
        {
            let destinationViewController = segue.destination as! UserProfileViewController
            destinationViewController.user = tweet?.user!
        }
        else if(segue.identifier == "DetailTweetReply")
        {
            let navdestinationViewController = segue.destination as! UINavigationController
            let destinationViewController = navdestinationViewController.viewControllers.first as! ComposeTweetViewController
            destinationViewController.tweet = self.tweet
        }
    }
    
}
