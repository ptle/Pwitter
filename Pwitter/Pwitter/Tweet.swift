//
//  Tweet.swift
//  Pwitter
//
//  Created by Peter Le on 2/14/17.
//  Copyright © 2017 CodePath. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var text: NSString?
    var timestamp: NSDate?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var user: User?
    var id: NSString?
    var retweetId: NSString?
    var retweeted: Bool?
    var favorited: Bool?
    
    init(dictionary: NSDictionary){
        text = dictionary["text"] as? NSString
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favorite_count"] as? Int) ?? 0
        if let retweet = dictionary["retweeted_status"] as? NSDictionary
        {
            favoritesCount = (retweet["favorite_count"] as? Int) ?? 0
            retweetId = retweet["id_str"] as? NSString
        }
        user = User(dictionary: (dictionary["user"] as? NSDictionary)!)
        
        let timestampString = dictionary["created_at"] as? String
        
        if let timestampString = timestampString
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.date(from: timestampString) as NSDate?
        }
        id = dictionary["id_str"] as? NSString
        retweeted = dictionary["retweeted"] as? Bool
        favorited = dictionary["favorited"] as? Bool
    }
    
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet]
    {
        var tweets = [Tweet]()
        
        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
        }
        
        return tweets
    }
}
