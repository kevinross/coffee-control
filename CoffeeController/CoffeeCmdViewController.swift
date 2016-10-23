//
//  CoffeeCmdViewController.swift
//  CoffeeController
//
//  Created by Kevin Ross on 2016-10-20.
//  Copyright © 2016 Kevin Ross. All rights reserved.
//

import UIKit

class CoffeeCmdViewController: UIViewController {
    // MARK: Properties
    
    @IBOutlet weak var coffeePowerStateToggle: UISwitch!
    var noPublish: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        let name = NSNotification.Name(rawValue: "MQTTMessageNotification")
        NotificationCenter.default.addObserver(forName: name, object: MqttDelegate.instance(), queue: OperationQueue.main) { (notification: Notification) in
            noPublish = true
            let userdata = notification.userInfo as! [String:String]
            if userdata["topic"] == AppDelegate.delegate().getSetting("powerStateTopic") {
                self.coffeePowerStateToggle.isOn = userdata["message"] == "ON"
            }
        }
        // set the saved value
        self.coffeePowerStateToggle.isOn = Int(AppDelegate.delegate().getSetting("brewPower"))! > 0
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Actions
    
    @IBAction func setCoffeePowerState(_ sender: UISwitch) {
        if noPublish {
            return
        }
        MqttDelegate.instance().client().publish(AppDelegate.delegate().getSetting("powerCommandTopic"), withString: sender.isOn ? "ON": "OFF")
        noPublish = false
    }
}

