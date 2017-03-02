//
//  User.swift
//  Pwitter
//
//  Created by Peter Le on 2/14/17.
//  Copyright © 2017 CodePath. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: NSString?
    var screenname: NSString?
    var profileUrl: NSURL?
    var tagline: NSString?
    var dictionary: NSDictionary?
    var bio: NSString?
    
    var headerImageUrl: NSURL?
    var followersCount: Int?
    var followingCount: Int?
    var tweetsCount: Int?
    
    static let UserDidLogoutNotification = "UserDidLogout"
    
    init(dictionary: NSDictionary){
        self.dictionary = dictionary
        
        name = dictionary["name"] as? NSString
        screenname = dictionary["screen_name"] as? NSString
        bio = dictionary["description"] as? NSString
        
        let profileUrlString = dictionary["profile_image_url_https"] as? String
        if let profileUrlString = profileUrlString {
            profileUrl = NSURL(string: profileUrlString)
        }
        
        let headerImageUrlString = dictionary["profile_banner_url"] as? String
        if let headerImageUrlString = headerImageUrlString {
            headerImageUrl = NSURL(string: headerImageUrlString)
        }
        
        tagline = dictionary["description"] as? NSString
        
        followersCount = (dictionary["followers_count"] as? Int)!
        followingCount = (dictionary["friends_count"] as? Int)!
        tweetsCount = (dictionary["statuses_count"] as? Int)!
    }
    
    static var _currentUser: User?
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let defaults = UserDefaults.standard
                
                let userData = defaults.object(forKey: "currentUserData") as? NSData
                
                if let userData = userData{
                    //print(userData)
                    let dictionary = try! JSONSerialization.jsonObject(with: userData as Data, options: [.allowFragments]) as! NSDictionary
                    
                    _currentUser = User(dictionary: dictionary)
                }
            }
        
            return _currentUser
        }
        set(user) {
            _currentUser = user
            
            let defaults = UserDefaults.standard
            
            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
                defaults.set(data, forKey: "currentUserData")
            }
            else{
                defaults.removeObject(forKey: "currentUserData")
            }
            defaults.synchronize()
        }
    }
}
