//
//  DetailViewController.swift
//  Flicks
//
//  Created by Alexandra Munoz on 1/18/16.
//  Copyright © 2016 Alexandra Munoz. All rights reserved.
//

import UIKit
import Cosmos

class DetailViewController: UIViewController {

    
    @IBOutlet weak var posterimageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var ratingView: CosmosView!
    
    @IBOutlet weak var infoView: UIView!
    var movie = NSDictionary!()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        
        let title = movie["title"] as? String
        titleLabel.text = title
        
        let rating = movie["vote_average"] as! Double
        
        ratingView.rating = rating/2
        
        ratingView.settings.fillMode = .Precise
        
        
        let overview = movie["overview"]
        overviewLabel.text = overview as? String
        
        overviewLabel.sizeToFit()
    
        
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] as? String{
            
            let imageUrl = NSURL(string: baseUrl + posterPath)
            
            let smallbaseUrl = "https://image.tmdb.org/t/p/w45"
            
            let largebaseUrl = "https://image.tmdb.org/t/p/original"
            
           let smallImageUrl = smallbaseUrl + posterPath
            let largeImageUrl = largebaseUrl + posterPath
            
            let largeimageUrl = NSURL(string: largebaseUrl + posterPath)
            
            let smallImageRequest = NSURLRequest(URL: NSURL(string: smallImageUrl)!)
            let largeImageRequest = NSURLRequest(URL: NSURL(string: largeImageUrl)!)
            
            posterimageView.setImageWithURLRequest(
                smallImageRequest,
                placeholderImage: nil,
                success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                    
                    // smallImageResponse will be nil if the smallImage is already available
                    // in cache (might want to do something smarter in that case).
                    self.posterimageView.alpha = 0.0
                    self.posterimageView.image = smallImage;
                    
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        
                        self.posterimageView.alpha = 1.0
                        
                        }, completion: { (success) -> Void in
                            
                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                            // per ImageView. This code must be in the completion block.
                            self.posterimageView.setImageWithURLRequest(
                                largeImageRequest,
                                placeholderImage: smallImage,
                                success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                    
                                    self.posterimageView.image = largeImage;
                                    
                                },
                                failure: { (request, response, error) -> Void in
                                        self.posterimageView.setImageWithURL(imageUrl!)
                                    // do something for the failure condition of the large image request
                                    // possibly setting the ImageView's image to a default image
                            })
                    })
                },
                failure: { (request, response, error) -> Void in
                        self.posterimageView.setImageWithURL(largeimageUrl!)
                    // do something for the failure condition
                    // possibly try to get the large image

            })
        }
        
        
        print(movie)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
