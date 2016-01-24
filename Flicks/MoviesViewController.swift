//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Alexandra Munoz on 1/9/16.
//  Copyright © 2016 Alexandra Munoz. All rights reserved.
//

import UIKit
import AFNetworking
import EZLoadingActivity

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var refreshControl: UIRefreshControl!

    @IBOutlet weak var tableView: UITableView!
    
    var movies : [NSDictionary]?
    
    var endpoint: String!

    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.tintColor = UIColor(red: 0.25, green: 0.25, blue: 1.00, alpha: 0.8)
            
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.blueColor().colorWithAlphaComponent(0.5)
            shadow.shadowOffset = CGSizeMake(2, 2);
            shadow.shadowBlurRadius = 4;
            navigationBar.titleTextAttributes = [
                NSFontAttributeName : UIFont(name: "CopperPlate", size: 50.0)!,                NSForegroundColorAttributeName : UIColor(red: 0.05, green: 0.05, blue: 0.5, alpha: 0.8),
                NSShadowAttributeName : shadow
            ]
        }
        EZLoadingActivity.show("Loading...", disableUI: true)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.tableView.reloadData()
                            EZLoadingActivity.hide(success: true, animated: true)
                    }
                }
                else {
                    EZLoadingActivity.hide(success: false, animated: true)
                }
        });
        task.resume()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        
        if let movies = movies {
            return movies.count
        } else{
            return 0
        }
        
    }
       func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as? String
        let overview = movie["overview"] as? String
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String{
            
        
        
        let imageUrl = NSURL(string: baseUrl + posterPath)
        
        let imageStringUrl = baseUrl + posterPath
        let imageUrlRequest = NSURLRequest(URL: NSURL(string: imageStringUrl)!)
        
        let imageRequest = NSURLRequest(URL: NSURL(string: imageStringUrl)!)
        cell.posterView.setImageWithURLRequest(
            imageUrlRequest,
            placeholderImage: nil,
            success: { (imageUrl, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    print("Image was NOT cached, fade in image")
                    cell.posterView.alpha = 0.0
                    cell.posterView.image = image
                    UIView.animateWithDuration(0.4, animations: { () -> Void in
                        cell.posterView.alpha = 1.0
                    
                    })
                } else {
                    print("Image was cached so just update the image")
                    cell.posterView.image = image
                }
            },
            
            failure: { (imageRequest, imageResponse, error) ->
                Void in
                // do something for the failure condition
                
        })

        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterView.setImageWithURL(imageUrl!)
        }
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.whiteColor()
        cell.selectedBackgroundView = backgroundView

        
        print("row \(indexPath.row)")
        
        return cell
        
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
        
        print("prepare for segue called")
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }


}
