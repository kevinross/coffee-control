//
//  CoffeeConfigViewController.swift
//  CoffeeController
//
//  Created by Kevin Ross on 2016-10-20.
//  Copyright © 2016 Kevin Ross. All rights reserved.
//

import UIKit

class MqttSettingsViewController: UIViewController {
    // MARK: Properties
    var properties: [UITextField:String]!
    @IBOutlet weak var brokerHostnameInput: UITextField!
    @IBOutlet weak var powerCommandTopicInput: UITextField!
    @IBOutlet weak var powerStateTopicInput: UITextField!
    @IBOutlet weak var dutyOnStateTopic: UITextField!
    @IBOutlet weak var dutyOffStateTopic: UITextField!
    @IBOutlet weak var brewDurationStateTopic: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        properties = [
            brokerHostnameInput: "hostname",
            powerCommandTopicInput: "powerCommandTopic",
            powerStateTopicInput: "powerStateTopic",
            dutyOnStateTopic: "dutyOnTopic",
            dutyOffStateTopic: "dutyOffTopic",
            brewDurationStateTopic: "brewDurationTopic",
        ]
        for (control, k) in properties {
            control.text = AppDelegate.delegate().getSetting(k)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    @IBAction func mqttSettingChanged(_ sender: UITextField) {
        if let setting = properties[sender] {
            AppDelegate.delegate().setSetting(sender.text!, forKey: setting)
        }
    }
}

