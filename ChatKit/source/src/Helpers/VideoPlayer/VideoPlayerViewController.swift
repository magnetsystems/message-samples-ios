//
//  VideoPlayerViewController.swift
//  MMChat
//
//  Created by Kostya Grishchenko on 1/26/16.
//  Copyright © 2016 Kostya Grishchenko. All rights reserved.
//

import DZVideoPlayerViewController
import MagnetMax

class VideoPlayerViewController: UIViewController, DZVideoPlayerViewControllerDelegate {
    
    @IBOutlet weak var videoContainerView: DZVideoPlayerViewControllerContainerView!
    var videoPlayerViewController: DZVideoPlayerViewController!
    var attachment: MMAttachment!
    var fileURL: NSURL!
    private var hideStatusBar = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Show player
        self.videoPlayerViewController = self.videoContainerView.videoPlayerViewController
        self.videoPlayerViewController.delegate = self
        self.videoPlayerViewController.configuration.isShowFullscreenExpandAndShrinkButtonsEnabled = false
        self.videoPlayerViewController.activityIndicatorView?.startAnimating()
        
        // Download file
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let documentsUrl = NSURL(fileURLWithPath: documentsPath, isDirectory: true)
        fileURL = documentsUrl.URLByAppendingPathComponent(attachment!.name!)
        print(fileURL!)
        
        attachment.downloadToFile(fileURL, success: { [weak self] () in
            self?.startPlay()
        }) { [weak self] error in
            print(error)
            self?.videoPlayerViewController.activityIndicatorView?.stopAnimating()
            self?.playerFailedToLoadAssetWithError(error)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // Show Status Bar
        hideStatusBar = false
        setNeedsStatusBarAppearanceUpdate()
        
        if NSFileManager.defaultManager().fileExistsAtPath(fileURL!.path!) {
            try! NSFileManager.defaultManager().removeItemAtURL(fileURL!)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return hideStatusBar
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .None
    }
    
    func startPlay() {

        //    self.videoPlayerViewController.configuration.isBackgroundPlaybackEnabled = NO;
        //    self.videoPlayerViewController.configuration.isHideControlsOnIdleEnabled = NO;
        
        self.videoPlayerViewController.activityIndicatorView?.stopAnimating()
        self.videoPlayerViewController.videoURL = fileURL
        self.videoPlayerViewController.prepareAndPlayAutomatically(true)
    }
    
    //MARK: - DZVideoPlayerViewControllerDelegate
    
    func playerDoneButtonTouched() {
        self.videoContainerView.videoPlayerViewController.stop()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func playerFailedToLoadAssetWithError(error: NSError!) {
        
    }
    
}
