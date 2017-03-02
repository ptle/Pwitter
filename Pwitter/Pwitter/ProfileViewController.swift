//
//  ProfileViewController.swift
//  Pwitter
//
//  Created by Peter Le on 2/24/17.
//  Copyright © 2017 CodePath. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController,
    UITableViewDelegate, UITableViewDataSource{
    
    var tweets: [Tweet]!
    
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

        // Do any additional setup after loading the view.
        //Get logo on top of navbar
        let logo = UIImage(named: "black-twitter-logo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        //Set up profile picture
        profilePicture.layer.cornerRadius = 3
        profilePicture.clipsToBounds = true
        
        //Link tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        //Set up UI
        self.profilePicture.layer.borderColor = UIColor.white.cgColor
        self.profilePicture.layer.borderWidth = 3
        if let profilePictureUrl = User.currentUser!.profileUrl
        {
            self.profilePicture.setImageWith(profilePictureUrl as URL)
        }
        if let headerImageUrl = User.currentUser!.headerImageUrl
        {
            self.headerPicture.setImageWith(headerImageUrl as URL)
        }
        self.handleLabel.text = "@\(User.currentUser!.screenname!)"
        self.nameLabel.text = User.currentUser!.name! as? String
        self.bio.text = User.currentUser!.bio! as? String
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        self.tweetcountLabel.text = numberFormatter.string(from: NSNumber(value:User.currentUser!.tweetsCount!))
        self.followerscountLabel.text =  numberFormatter.string(from: NSNumber(value:User.currentUser!.followersCount!))
        self.followingcountLabel.text =  numberFormatter.string(from: NSNumber(value:User.currentUser!.followingCount!))
        
        //Get user tweets
        TwitterClient.sharedInstance?.userTimeline(myUser: User.currentUser!.screenname as! String, success: { (tweets: [Tweet]) in
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
    
    @IBAction func onLogoutButton(_ sender: Any) {
        TwitterClient.sharedInstance?.logout()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTweetTableViewCell", for: indexPath) as! TweetTableViewCell
        
        cell.tweet = tweets[indexPath.row]
        cell.selectionStyle = .none
        cell.accessoryType = .none
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ProfileReply")
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
