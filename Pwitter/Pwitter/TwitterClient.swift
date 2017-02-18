//
//  TwitterClient.swift
//  Pwitter
//
//  Created by Peter Le on 2/14/17.
//  Copyright © 2017 CodePath. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(baseURL: NSURL(string: "https://api.twitter.com")! as URL!, consumerKey: "G0tVXTXphKb0q5tUlu5a1qQim", consumerSecret: "ngvGPLbE3tqVzXf2unnbenBjEhfDSnrnMInzdHmEm6w5bbcOjN")
    
    var loginSuccess: (()->())?
    var loginFailure: ((NSError) -> ())?
    
    func homeTimeline(count:Int, success: @escaping ([Tweet])->(), failure: @escaping (NSError)->()){
        get("1.1/statuses/home_timeline.json?count=\(count)", parameters: nil, progress: nil, success: { (task: URLSessionDataTask,response: Any?) in
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
            
            success(tweets)
            
        }, failure: { (task: URLSessionDataTask?,error: Error) in
            failure(error as NSError)
        })
    }
    
    func currentAccount(success: @escaping (User)->(), failure: @escaping (NSError)->()){
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            //print("account: \(response)")
            let userDictionary = response as? NSDictionary
            let user = User(dictionary: userDictionary!)
            
            success(user)
            
            print("name: \(user.name)")
            print("screenname: \(user.screenname)")
            print("profile image: \(user.profileUrl)")
            print("description: \(user.tagline)")
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error as NSError)
        })
    }
    
    func login(success: @escaping ()->(), failure: @escaping (NSError)->())
    {
        loginSuccess = success
        loginFailure = failure
        
        TwitterClient.sharedInstance?.deauthorize()
        TwitterClient.sharedInstance?.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: NSURL(string: "pwitter://oauth") as URL!, scope: nil, success: { (requestToken:BDBOAuth1Credential?) in
            print("I got a token!")
            let url = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken!.token!)")!
            UIApplication.shared.openURL(url as URL)
        }, failure: { (error: Error?) in
            print("error: \(error?.localizedDescription)")
            self.loginFailure?(error as! NSError)
        })
    }
    
    func logout()
    {
        User.currentUser = nil
        deauthorize()
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "currentUserData")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: User.UserDidLogoutNotification), object: nil)
    }
    
    func handleOpenUrl(url: NSURL)
    {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessToken(withPath: "https://api.twitter.com/oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential?) in
            print("I got the access token")
            
            self.currentAccount(success: { (user: User) in
                User.currentUser = user
                self.loginSuccess?()
            }, failure: { (error: NSError) in
                self.loginFailure?(error)
            })
            
            
        }, failure: { (error: Error?) in
            print("Error: \(error?.localizedDescription)")
            self.loginFailure?(error as! NSError)
        })
        
    }
    
    //retweet and like
    func retweet(id: Int, params: NSDictionary?, completion: @escaping (_ error: NSError?) -> () ){
        post("1.1/statuses/retweet/\(id).json", parameters: params, success: { (task: URLSessionDataTask,response: Any?) in
            print("Retweeted tweet with id: \(id)")
            completion(nil)
        }, failure: { (task: URLSessionDataTask?,error: Error) in
            print("Couldn't retweet")
            completion(error as NSError?)
        }
        )
    }
    
    func likeTweet(id: Int, params: NSDictionary?, completion: @escaping (_ error: NSError?) -> () ){
        post("1.1/favorites/create.json?id=\(id)", parameters: params, success: { (task: URLSessionDataTask,response: Any?) in
            print("Liked tweet with id: \(id)")
            completion(nil)
        }, failure: { (task: URLSessionDataTask?,error: Error) in
            print("Couldn't like tweet")
            completion(error as NSError?)
        }
    )}
}