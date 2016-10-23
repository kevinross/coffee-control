//
//  CoffeeConfigViewController.swift
//  CoffeeController
//
//  Created by Kevin Ross on 2016-10-20.
//  Copyright © 2016 Kevin Ross. All rights reserved.
//

import UIKit

class CoffeeConfigViewController: UIViewController {
    // MARK: Properties
    
    @IBOutlet weak var brewDurationSlider: UISlider!
    @IBOutlet weak var brewDurationLabel: UILabel!
    @IBOutlet weak var dutyOnSlider: UISlider!
    @IBOutlet weak var dutyOnLabel: UILabel!
    @IBOutlet weak var dutyOffSlider: UISlider!
    @IBOutlet weak var dutyOffLabel: UILabel!
    // block publishing values when updating the slider
    var noPublish: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        let name = NSNotification.Name(rawValue: "MQTTMessageNotification")
        NotificationCenter.default.addObserver(forName: name, object: MqttDelegate.instance(), queue: OperationQueue.main) { (notification: Notification) in
            let userdata = notification.userInfo as! [String:String]
            self.noPublish = true
            switch userdata["topic"]! {
            case AppDelegate.delegate().getSetting("dutyOnTopic"):
                self.dutyOnSlider.setValue(Float(userdata["message"]!)!, animated: true)
                self.sliderValueChanged(self.dutyOnSlider)
            case AppDelegate.delegate().getSetting("dutyOffTopic"):
                self.dutyOffSlider.setValue(Float(userdata["message"]!)!, animated: true)
                self.sliderValueChanged(self.dutyOffSlider)
            case AppDelegate.delegate().getSetting("brewDurationTopic"):
                self.brewDurationSlider.setValue(Float(userdata["message"]!)!, animated: true)
                self.sliderValueChanged(self.brewDurationSlider)
            default: break
            }
        }
        // set the saved values
        self.dutyOnSlider.setValue(Float(AppDelegate.delegate().getSetting("dutyOn"))!, animated: true)
        self.sliderValueChanged(self.dutyOnSlider)
        self.dutyOffSlider.setValue(Float(AppDelegate.delegate().getSetting("dutyOff"))!, animated: true)
        self.sliderValueChanged(self.dutyOffSlider)
        self.brewDurationSlider.setValue(Float(AppDelegate.delegate().getSetting("brewDuration"))!, animated: true)
        self.sliderValueChanged(self.brewDurationSlider)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    /*
     Convenience method for publishing integers with the topic taken from settings
    */
    func publishInt(_ setting: String, value: Int) {
        if noPublish {
           return
        }
        MqttDelegate.instance().client().publish(AppDelegate.delegate().getSetting(setting), withString: value.description)
    }
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        switch sender {
        case brewDurationSlider:
            publishInt("brewDurationTopic", value: Int(sender.value))
            self.brewDurationLabel.text = "\(Int(sender.value)) min(s)"
        case dutyOnSlider:
            publishInt("dutyOnTopic", value: Int(sender.value))
            self.dutyOnLabel.text = "\(Int(sender.value)) sec(s)"
        case dutyOffSlider:
            publishInt("dutyOffTopic", value: Int(sender.value))
            self.dutyOffLabel.text = "\(Int(sender.value)) sec(s)"
        default:
            break
        }
        noPublish = false
    }

    // MARK: Actions
}

