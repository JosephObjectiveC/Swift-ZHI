//
//  DailyNewsTableViewController.swift
//  SwiftDaily-ZhiHu
//
//  Created by Nicholas Tian on 29/05/2015.
//  Copyright (c) 2015 nickTD. All rights reserved.
//

import UIKit
import SwiftDailyAPI

class DailyTableViewController: UITableViewController {
    private let store = DailyInMemoryStore()
    private var dailyNewsMeta: [NewsMeta] {
        get {
            return [Daily](store.dailies.values).flatMap { $0.news }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        beginRefreshing()
        loadLatestDaily()
    }

    private func beginRefreshing() {
        guard let refreshControl = refreshControl else { return }

        tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.size.height), animated: true)
        refreshControl.beginRefreshing()
    }

    @IBAction func refreshLatestDaily() {
        loadLatestDaily()
    }
}


extension DailyTableViewController {
    private func loadLatestDaily() {
        store.latestDaily { latestDaily in
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
}

// MARK: Data Source and Delegate
extension DailyTableViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyNewsMeta.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NewsMetaCell", forIndexPath: indexPath)

        let newsMeta = dailyNewsMeta[indexPath.row]
        cell.textLabel?.text = newsMeta.title

        return cell
    }


    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}
