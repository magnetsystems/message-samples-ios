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

let MMFooterHeightZero : CGFloat = 0.0001

/**
 This class is the base class chatkit uses to Implement TableViews 
 */
public class MMTableViewController: MMViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    
    //Mark: Public Methods
    
    
    ///UIRefreshControl for refreshing the tableview
    public var refreshControl : UIRefreshControl? = UIRefreshControl()
    ///Infinite loading handler: this objects triggers events when more data is needed to be loaded (i.e. onUpdate({}), onDoneUpdating({}) )
    public private(set) var infiniteLoading : InfiniteLoading = InfiniteLoading()
    /// The number of pages to load ahead (i.e. numberOfPagesToLoadAhead = 3, if there are less than three screens worth of data load more)
    public var numberOfPagesToLoadAhead = 3
    /// Footers for the tableview
    public internal(set) var footers : [String] = []
    /// Background color for cells
    public var cellBackgroundColor : UIColor = UIColor.clearColor()
    
    
    //MARK: Outlets
    
    
    /// Underlying TableView
    @IBOutlet public var tableView : UITableView!
    
    
    //MARK: Overrides
    
    
    /// viewDidLoad
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if let refreshControl = self.refreshControl {
            refreshControl.backgroundColor = UIColor.clearColor()
            tableView.addSubview(refreshControl)
        }
    }
    
    internal func isLastSection(section : Int) -> Bool {
        return self.tableView.numberOfSections - 1 == section
    }
    
    internal func isFooterSection(section : Int) -> Bool {
        let numberOfSections = self.tableView.numberOfSections
        guard footers.count > 0 && section < numberOfSections  else {
            return false
        }
        return  numberOfSections - footers.count <= section
    }
    
    internal func identifierForFooterSection(section : Int) -> String? {
        guard isFooterSection(section)  else {
            return nil
        }
        
        let numberOfSections = self.tableView.numberOfSections
        let index = section - (numberOfSections - footers.count)
        
        return footers[index]
    }
    
    internal func footerSectionIndex(section : Int) -> Int? {
        guard isFooterSection(section)  else {
            return nil
        }
        
        let numberOfSections = self.tableView.numberOfSections
        let index = section - (numberOfSections - footers.count)
        
        return index
    }
    
    internal func isWithinLoadingBoundary() -> Bool {
        return tableView.contentOffset.y > (tableView.contentSize.height - (tableView.frame.size.height * CGFloat(numberOfPagesToLoadAhead)))
    }
    
    /// ViewController setup called after viewDidLoad
    public override func setupViewController() {
        super.setupViewController()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    //MARK: UITableViewDatasource
    
    
    ///UITableViewDatasource
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    ///UITableViewDatasource
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
