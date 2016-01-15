//
//  HidesHairLineUnderNavBarViewController.swift
//  SwiftDaily-ZhiHu
//
//  Created by Nicholas Tian on 22/06/2015.
//  Copyright © 2015 nickTD. All rights reserved.
//

import UIKit

class HidesHairLineUnderNavBarViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // source: http://stackoverflow.com/questions/19226965/how-to-hide-ios7-uinavigationbar-1px-bottom-line

        if let bar = navigationController?.navigationBar {
            findHairLineImageViewUnder(bar)?.hidden = true
        }

    }

    private func findHairLineImageViewUnder(view: UIView) -> UIImageView? {
        if view.isKindOfClass(UIImageView.self) && view.bounds.size.height <= 1.0 {
            return view as? UIImageView
        }

        for subView in view.subviews {
            if let imageView = findHairLineImageViewUnder(subView ) {
                return imageView
            } else { continue }
        }
        return nil
    }

}
