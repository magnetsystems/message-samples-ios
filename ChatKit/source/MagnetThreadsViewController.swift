//
//  MagnetThreadsViewController.swift
//  
//
//  Created by Lorenzo Stanton on 2/11/16.
//
//

import UIKit

public class MagnetThreadsViewController: UINavigationController {
private var underlyingThreadsViewController = HomeViewController.init()
    
  public override func viewDidLoad() {
        super.viewDidLoad()

        setViewControllers([underlyingThreadsViewController], animated: false)
        // Do any additional setup after loading the view.
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
