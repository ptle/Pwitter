//
//  TweetsViewController.swift
//  Pwitter
//
//  Created by Peter Le on 2/14/17.
//  Copyright © 2017 CodePath. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController,
    UITableViewDelegate, UITableViewDataSource,
    UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var tweets: [Tweet]!
    var count = 20
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        count = 20

        TwitterClient.sharedInstance?.homeTimeline(count: count, success: { (tweets: [Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
            refreshControl.endRefreshing()
            //print("refreshed")
            
        }, failure: { (error: NSError) in
            print(error.localizedDescription)
            refreshControl.endRefreshing()
        })
    }
        
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                //Loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // ... Code to load more results ...
                loadMoreData()
            }
        }
    }
    
    func loadMoreData() {
        count += 20

        TwitterClient.sharedInstance?.homeTimeline(count: count, success: { (tweets: [Tweet]) in
            self.tweets = tweets
            
            // Update flag
            self.isMoreDataLoading = false
            
            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
            
            //Reload table
            self.tableView.reloadData()
            
        }, failure: { (error: NSError) in
            print(error.localizedDescription)
            
            // Update flag
            self.isMoreDataLoading = false
            
            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        TwitterClient.sharedInstance?.homeTimeline(count: count, success: { (tweets: [Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
            
        }, failure: { (error: NSError) in
            print(error.localizedDescription)
        })
        
        //Get logo on top of navbar
        let logo = UIImage(named: "black-twitter-logo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        //Set up tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        //Refresh Actions
        let refreshControl = UIRefreshControl()
        var attr = [NSForegroundColorAttributeName:UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attr)
        refreshControl.addTarget(self, action: #selector(TweetsViewController.refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        //Add infinity loader
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogoutButtton(_ sender: Any) {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetTableViewCell", for: indexPath) as! TweetTableViewCell
        
        cell.tweet = tweets[indexPath.row]
        cell.selectionStyle = .none
        cell.accessoryType = .none
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "UserProfile")
        {
            if let button = sender as? UIButton {
                if let superview = button.superview {
                    if let cell = superview.superview as? TweetTableViewCell {
                        let indexPath = tableView.indexPath(for: cell)
                        let tweet = tweets[indexPath!.item]
                        //print(tweet)
                        let destinationViewController = segue.destination as! UserProfileViewController
                        destinationViewController.user = tweet.user
                    }
                }
            }
        }
        else if(segue.identifier == "TweetDetail")
        {
            let cell = sender as? TweetTableViewCell
            let indexPath = tableView.indexPath(for: cell!)
            let tweet = tweets[indexPath!.item]
            let destinationViewController = segue.destination as! DetailedTweetViewController
            destinationViewController.tweet = tweet
        }
        else if(segue.identifier == "TweetReply")
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
