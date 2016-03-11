/*
* Copyright (c) 2016 Magnet Systems, Inc.
* All rights reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License"); you
* may not use this file except in compliance with the License. You
* may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
* implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

import UIKit

public class MMTableViewController: MMViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    
    //Mark: Public Methods
    
    
    public var refreshControl : UIRefreshControl? = UIRefreshControl()
    public private(set) var infiniteLoading : InfiniteLoading = InfiniteLoading()
    public var numberOfPagesToLoadAhead = 3
    public var footers : [String] = []
    public var cellBackgroundColor : UIColor = UIColor.clearColor()
    
    
    //MARK: Outlets
    
    
    @IBOutlet public var tableView : UITableView!
    
    
    //MARK: Overrides
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if let refreshControl = self.refreshControl {
            refreshControl.backgroundColor = UIColor.clearColor()
            tableView.addSubview(refreshControl)
        }
    }
    
    public func isLastSection(section : Int) -> Bool {
        return self.tableView.numberOfSections - 1 == section
    }
    
    public func isFooterSection(section : Int) -> Bool {
        let numberOfSections = self.tableView.numberOfSections
        guard footers.count > 0 && section < numberOfSections  else {
            return false
        }
        return  numberOfSections - footers.count <= section
    }
    
    public func identifierForFooterSection(section : Int) -> String? {
        guard isFooterSection(section)  else {
            return nil
        }
        
        let numberOfSections = self.tableView.numberOfSections
        let index = section - (numberOfSections - footers.count)
        
        return footers[index]
    }
    
    public func isWithinLoadingBoundary() -> Bool {
        return tableView.contentOffset.y > (tableView.contentSize.height - (tableView.frame.size.height * CGFloat(numberOfPagesToLoadAhead)))
    }
    
    public override func setupViewController() {
        super.setupViewController()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK: UITableViewDelegatye
    
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
