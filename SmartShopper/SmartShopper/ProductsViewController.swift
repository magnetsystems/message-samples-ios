//
//  ProductsViewController.swift
//  SmartShopper
//
//  Created by Pritesh Shah on 9/16/15.
//  Copyright © 2015 Magnet Systems, Inc. All rights reserved.
//

import UIKit
import CoreLocation
import MMX
import AlamofireImage
import JGProgressHUD

class ProductsViewController: UIViewController {
    
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let userID = "smartshopperios"
    let imageCache = AutoPurgingImageCache()
    var products = [Product]()
    var wishList: MMXChannel!
    var wishListItems = Set<Product>() {
        didSet {
            if wishListItems.count > 0 {
                navigationItem.rightBarButtonItem?.enabled = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Smart Shopper"
        
        ensureUser()
        displayWeather()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Wish List", style: .Done, target: self, action: "viewWishList")
        navigationItem.rightBarButtonItem?.enabled = false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "shareSegue" {
            let destinationViewController: UsersViewController = segue.destinationViewController as! UsersViewController
            destinationViewController.product = products[(sender as! NSIndexPath).row]
        } else if segue.identifier == "viewWishList" {
            let destinationViewController: WishListViewController = segue.destinationViewController as! WishListViewController
            destinationViewController.products = Array(wishListItems)
        }
    }
    
    // MARK: Private implementation
    
    func viewWishList() {
        performSegueWithIdentifier("viewWishList", sender: self)
    }
    
    func displayWeather() {
        let pier70InSF = CLLocation(latitude: 37.759851, longitude: -122.383611)
        WeatherService().conditions(pier70InSF, success: { (weatherConditions) -> Void in
            self.weatherLabel.text = "It is currently \(weatherConditions.temperatureInFahrenheit)\u{00B0} F"
            
            // look for an appropriate product
            self.lookForAnAppropriateProduct(weatherConditions)
            
        }) { (error) -> Void in
            print("Could not fetch weather: \(error)")
        }
    }
    
    func lookForAnAppropriateProduct(conditions: WeatherConditions) {
        let query: String
        // Look for sunglasses if the weather is warm
        // Warm is subjective :)
        if conditions.temperatureInFahrenheit >= 75 {
            query = "sunglasses"
        } else {
            // One can always use a jacket in SF
            query = "jacket"
        }
        
        ProductService().products(query, success: { (products) -> Void in
            self.products = products
            self.tableView.reloadData()
        }) { (error) -> Void in
            print("Could not fetch products: \(error)")
        }
    }
    
    func ensureUser() {
        let user = MMXUser()
        user.username = userID
        user.displayName = userID
        let credential = NSURLCredential(user: user.username, password: userID, persistence: .None)
        user.registerWithCredential(credential, success: { () -> Void in
            self.login(credential)
        }) { (error) -> Void in
                //If error is for user already exists login
                if error.code == 409 {
                    self.login(credential)
                } else {
                    print("Could not register: \(error)")
                }
        }
    }
    
    func login(credential: NSURLCredential) {
        MMXUser.logInWithCredential(credential, success: { (user) -> Void in
            self.showLoginSuccess()
            // Indicate that you are ready to receive messages now!
            MMX.start()
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveMessage:", name: MMXDidReceiveMessageNotification, object: nil)
            self.ensureWishList()
        }, failure: { (error) -> Void in
            print("Could not login: \(error)")
        })
    }
    
    func showLoginSuccess() {
        JGProgressHUD.showText("Hi \(userID)!", view: navigationController?.view)
    }
    
    func didReceiveMessage(notification: NSNotification) {
        let userInfo : [NSObject : AnyObject] = notification.userInfo!
        let message = userInfo[MMXMessageKey] as! MMXMessage
        let product = Product(dictionary: message.messageContent as! [String: String])
        
        print("\(message.sender.username) has shared the product: \(product.name)")
        
        // Schedule local notification
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 5)
        notification.alertBody = "Check this product: \(product.name)"
        notification.userInfo = message.messageContent
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func ensureWishList() {
        let channelName = "WishList"
        MMXChannel.createWithName(channelName, summary: "Wish Lists are the perfect way to save all of your favorite products while you shop", isPublic: false, success: { (channel) -> Void in
                self.wishList = channel
                print("WishList created successfully!")
            }) { (error) -> Void in
                if error.code != 409 {
                    print("Could not create WishList: \(error)")
                } else {
                    print("WishList already exists!")
                    MMXChannel.channelForName(channelName, isPublic: false, success: { (channel) -> Void in
                        self.wishList = channel
                        self.fetchWishListItems()
                    }, failure: { (error) -> Void in
                        print(error)
                    })
                }
        }
    }
    
    func fetchWishListItems() {
        let dateComponents = NSDateComponents()
        dateComponents.year = -1
        
        let theCalendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let aYearAgo = theCalendar.dateByAddingComponents(dateComponents, toDate: now, options: NSCalendarOptions(rawValue: 0))
        
        wishList.messagesBetweenStartDate(aYearAgo, endDate: now, limit: 100, offset: 0, ascending: false, success: { (totalCount, messages) -> Void in
            for message in messages as! [MMXMessage] {
                self.wishListItems.insert(Product(dictionary: message.messageContent as! [String: String]))
            }
        }) { (error) -> Void in
            print("Could not fetch WishList items: \(error)")
        }
    }

}

extension ProductsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        let product = products[indexPath.row]
        
        // Configure the cell
        cell.textLabel!.text = product.name
        
        if let thumbnailImage = product.thumbnailImage {
            // Fetch
            let cachedThumbnailImage = imageCache.imageWithIdentifier(thumbnailImage.absoluteString)
            if let _ = cachedThumbnailImage {
                cell.imageView?.image = cachedThumbnailImage
            } else {
                cell.imageView?.af_setImageWithURLRequest(NSURLRequest(URL: thumbnailImage), placeholderImage: nil, filter: nil, imageTransition: .None) { (_, _, result) -> Void in
                    cell.imageView?.image = result.value
                    self.imageCache.addImage(result.value!, withIdentifier: thumbnailImage.absoluteString)
                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                }
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        // Share
        let shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Share") { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            self.performSegueWithIdentifier("shareSegue", sender: indexPath)
            
            tableView.setEditing(false, animated: true)
        }
        shareAction.backgroundColor = UIColor(rgb: 0xFF9400, alpha: 1)

        // Add to Wishlist
        let addToWishlistAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Add to \nWish List") { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            let product = self.products[indexPath.row]
            if self.wishListItems.contains(product) {
                JGProgressHUD.showText("Success!", view: self.navigationController?.view)
                print("Product already exists in the WishList!")
            } else {
                self.wishList.publish(product.toDictionary(), success: { (message) -> Void in
                    self.wishListItems.insert(product)
                    JGProgressHUD.showText("Success!", view: self.navigationController?.view)
                    print("Product added to WishList successfully!")
                }, failure: { (error) -> Void in
                    print("Could not add to WishList: \(error)")
                })
            }
            
            tableView.setEditing(false, animated: true)
        }
        addToWishlistAction.backgroundColor = UIColor(rgb: 0x3D70A7, alpha: 1)
        
        return [addToWishlistAction, shareAction]
    }
}

