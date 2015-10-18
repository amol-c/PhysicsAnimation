//
//  ViewController.swift
//  PhysicsAnimation
//
//  Created by amol-c on 10/17/2015.
//  Copyright (c) 2015 amol-c. All rights reserved.
//

import UIKit
import PhysicsAnimation

class ViewController: UIViewController {
    var context: PhysicsControllerContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.context = PhysicsControllerContext(navigationController: self.navigationController!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pushNextViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .None)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("AnotherViewController")
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}

