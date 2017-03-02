//
//  UserProfileViewController.swift
//  Pwitter
//
//  Created by Peter Le on 2/26/17.
//  Copyright © 2017 CodePath. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController,
    UITableViewDelegate, UITableViewDataSource{

    var tweets: [Tweet]!
    var user: User?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var headerPicture: UIImageView!
    @IBOutlet weak var bio: UILabel!
    @IBOutlet weak var tweetcountLabel: UILabel!
    @IBOutlet weak var followingcountLabel: UILabel!
    @IBOutlet weak var followerscountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        //Set up profile picture
        profilePicture.layer.cornerRadius = 3
        profilePicture.clipsToBounds = true
        
        //Set up UI
        self.profilePicture.layer.borderColor = UIColor.white.cgColor
        self.profilePicture.layer.borderWidth = 3
        if let profilePictureUrl = user?.profileUrl
        {
           self.profilePicture.setImageWith(profilePictureUrl as URL)
        }
        if let headerImageUrl = user?.headerImageUrl
        {
            self.headerPicture.setImageWith(headerImageUrl as URL)
        }
        self.handleLabel.text = "@\(user!.screenname!)"
        self.nameLabel.text = user!.name! as? String
        self.bio.text = user?.bio! as? String
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        self.tweetcountLabel.text = numberFormatter.string(from: NSNumber(value: user!.tweetsCount!))
        self.followerscountLabel.text = numberFormatter.string(from: NSNumber(value: user!.followersCount!))
        self.followingcountLabel.text = numberFormatter.string(from: NSNumber(value: user!.followingCount!))
        
        //Get user tweets
        TwitterClient.sharedInstance?.userTimeline(myUser: user!.screenname as! String, success: { (tweets: [Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
        }, failure: { (error: NSError) in
            print(error.localizedDescription)
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tweets != nil {
            return tweets.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserProfileTweetTableViewCell", for: indexPath) as! TweetTableViewCell
        
        cell.tweet = tweets[indexPath.row]
        cell.selectionStyle = .none
        cell.accessoryType = .none
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "UserProfileReply")
        {
            if let button = sender as? UIButton {
                if let superview = button.superview {
                    if let cell = superview.superview as? TweetTableViewCell {
                        let indexPath = tableView.indexPath(for: cell)
                        let tweet = tweets[indexPath!.item]
                        //print(tweet)
                        let navdestinationViewController = segue.destination as! UINavigationController
                        let destinationViewController = navdestinationViewController.viewControllers.first as! ComposeTweetViewController
                        destinationViewController.tweet = tweet
                    }
                }
            }
        }
    }

}
