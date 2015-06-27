//
//  DailyNewsTableViewController.swift
//  SwiftDaily-ZhiHu
//
//  Created by Nicholas Tian on 29/05/2015.
//  Copyright (c) 2015 nickTD. All rights reserved.
//

import UIKit
import AMScrollingNavbar
import SwiftDailyAPI

// TODO: think about all the `self`s in closures

class DailyInMemoryTableViewController: DailyTableViewController {
    // MARK: Store
    private let store = DailyInMemoryStore(completionQueue: dispatch_get_main_queue())

    private func dailyAtSection(section: Int) -> Daily? {
        return store.dailies[section]
    }

    private func newsMetaAtIndexPath(indexPath: NSIndexPath) -> NewsMeta? {
        guard let daily = dailyAtSection(indexPath.section) else { return nil }

        return daily.news[indexPath.row]
    }
}

// MARK: Concrete methods
extension DailyInMemoryTableViewController {
    override func hasNewsMetaAtIndexPath(indexPath: NSIndexPath) -> Bool {
        return newsMetaAtIndexPath(indexPath) != nil
    }

    override func dateStringAtSection(section: Int) -> String {
        let date = store.dailies.dateIndexAtIndex(section).date
        return dateFormatter.stringFromDate(date)
    }

    override func loadDailyAtIndexPath(indexPath: NSIndexPath) {
        let date = store.dailies.dateIndexAtIndex(indexPath.section).date

        store.daily(forDate: date) { self.loadDailyIntoTableView($0) }
    }

    override func loadLatestDaily() {
        store.latestDaily { latestDaily in
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            self.showNavBarAnimated(true)
        }
    }

    override func loadNewsAtIndexPath(indexPath: NSIndexPath) {
        guard let newsMeta = self.newsMetaAtIndexPath(indexPath) else { return }

        // TODO: should notify user successful fetching and decoding
        self.store.news(newsMeta.newsId) { (news) in
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }

    override func cellAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        let newsMeta = newsMetaAtIndexPath(indexPath)!
        let cell = tableView.dequeueReusableCellWithIdentifier("NewsMetaCell", forIndexPath: indexPath)

        cell.textLabel?.text = newsMeta.title

        if let _ = store.news[newsMeta.newsId] {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }

        return cell
    }
}

// MARK: UI methods
extension DailyInMemoryTableViewController {
    private func loadDailyIntoTableView(daily: Daily) {
        let tableView = self.tableView
        let sectionIndex = store.dailies.indexAtDate(daily.date)
        tableView.beginUpdates()
        tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation:
            UITableViewRowAnimation.Automatic)
        tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Automatic)
        tableView.endUpdates()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard segue.identifier == "showNews" else { return }
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let newsMeta = newsMetaAtIndexPath(indexPath) else { return }

        let newsVC = segue.destinationViewController as! NewsInMemoryViewController
        newsVC.store = store
        newsVC.newsId = newsMeta.newsId
    }
}

// MARK: Data Source
extension DailyInMemoryTableViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return store.dailies.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyAtSection(section)?.news.count ?? 1
    }
}
