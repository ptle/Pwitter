//
//  ComposeTweetViewController.swift
//  Pwitter
//
//  Created by Peter Le on 2/21/17.
//  Copyright © 2017 CodePath. All rights reserved.
//

import UIKit

class ComposeTweetViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var replyLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var profilePicture: UIImageView!
    var tweet: Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if tweet == nil {
            replyLabel.isHidden = true
        }
        else
        {
            replyLabel.text = "In reply to \(tweet!.user!.name!)"
        }
        
        textView.delegate = self
        textView.text = "What's Happening?"
        textView.textColor = UIColor(red: 170/255, green: 184/255, blue: 194/255, alpha: 1)
        textView.alwaysBounceHorizontal = false
        textView.alwaysBounceVertical = true
        textView.textContainerInset = UIEdgeInsetsMake(16, 10, 16, 10)
        
        profilePicture.layer.cornerRadius = 3
        profilePicture.clipsToBounds = true
        
        TwitterClient.sharedInstance?.currentAccount(success: { (user: User) in
            self.profilePicture.setImageWith(user.profileUrl as! URL)
            self.handleLabel.text = "@\(user.screenname!)"
            self.nameLabel.text = user.name! as String
        }, failure: { (error: NSError) in
            print("error")
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(red: 170/255, green: 184/255, blue: 194/255, alpha: 1) {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "What's Happening?"
            textView.textColor = UIColor(red: 170/255, green: 184/255, blue: 194/255, alpha: 1)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func Tweet(_ sender: Any) {
        if(textView.text.isEmpty || textView.textColor == UIColor(red: 170/255, green: 184/255, blue: 194/255, alpha: 1))
        {
            let alertController = UIAlertController(title: "Error", message: "Make sure Tweet has content", preferredStyle: .alert)
        
            // create an OK action
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                // handle response here.
            }
            // add the OK action to the alert controller
            alertController.addAction(OKAction)
        
            present(alertController, animated: true) {
                // optional code for what happens after the alert controller has finished presenting
            }
        }
        else{
            if tweet == nil {
                TwitterClient.sharedInstance?.tweet(status: textView.text!, success: {
                    print("Tweet was posted")
                    self.dismiss(animated: true, completion: nil)
                }, failure: { (error: NSError) in
                    let alertController = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    
                    // create an OK action
                    let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                        // handle response here.
                    }
                    // add the OK action to the alert controller
                    alertController.addAction(OKAction)
                    
                    self.present(alertController, animated: true) {
                        // optional code for what happens after the alert controller has finished presenting
                    }
                })
            }
            else{
                TwitterClient.sharedInstance?.reply(text: textView.text!, id: Int(tweet!.id! as String)! , success: {
                    print("Tweet was posted")
                    self.dismiss(animated: true, completion: nil)
                }, failure: { (error: NSError) in
                    let alertController = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    
                    // create an OK action
                    let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                        // handle response here.
                    }
                    // add the OK action to the alert controller
                    alertController.addAction(OKAction)
                    
                    self.present(alertController, animated: true) {
                        // optional code for what happens after the alert controller has finished presenting
                    }
                })
                
            }
        }
    }
}
