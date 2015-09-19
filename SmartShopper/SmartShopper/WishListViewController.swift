//
//  WishListViewController.swift
//  SmartShopper
//
//  Created by Pritesh Shah on 9/17/15.
//  Copyright © 2015 Magnet Systems, Inc. All rights reserved.
//

import Foundation
import UIKit
import MMX
import AlamofireImage

class WishListViewController: UITableViewController {
    
    let imageCache = AutoPurgingImageCache()
    var products: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Wish List"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "shareWishListItemSegue" {
            let destinationViewController: UsersViewController = segue.destinationViewController as! UsersViewController
            destinationViewController.product = products[(sender as! NSIndexPath).row]
        }
    }
    
    // MARK: Private implementation
}

extension WishListViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("WishListItemCell", forIndexPath: indexPath) as UITableViewCell
        
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
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        // Share
        let shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Share") { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            self.performSegueWithIdentifier("shareWishListItemSegue", sender: indexPath)
            
            tableView.setEditing(false, animated: true)
        }
        shareAction.backgroundColor = UIColor(rgb: 0xFF9400, alpha: 1)
        
        return [shareAction]
    }
}
