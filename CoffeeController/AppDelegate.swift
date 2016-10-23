//
//  AppDelegate.swift
//  CoffeeController
//
//  Created by Kevin Ross on 2016-10-20.
//  Copyright © 2016 Kevin Ross. All rights reserved.
//

import UIKit
import CocoaMQTT

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // the default settings
    public static let mqttSettingDefaults = [
        "powerCommandTopic": "/coffee/brew/cmd",
        "powerStateTopic": "/coffee/brew",
        "dutyOnTopic": "/coffee/brew/duty/on",
        "dutyOffTopic": "/coffee/brew/duty/off",
        "brewDurationTopic": "/coffee/brew/time"
    ]
    public static let coffeeSettingDefaults = [
        "brewPower": 0,
        "dutyOn": 15,
        "dutyOff": 5,
        "brewDuration": 15
    ] as [String : Int]

    // make myself available to others
    public static func delegate() -> AppDelegate {
        return (UIApplication.shared.delegate as! AppDelegate)
    }
    
    var window: UIWindow?
    // settings
    private let defaults = UserDefaults.standard
    // current list of topics
    private var topics: [String] = []
    // main mqtt client
    private var client: CocoaMQTT!
    
    /*
        Get a setting, creating it using defaults if it doesn't exist
     */
    public func getSetting(_ setting: String) -> String {
        if defaults.object(forKey: setting) == nil {
            if let def = AppDelegate.mqttSettingDefaults[setting] {
                defaults.set(def, forKey: setting)
            } else if let def = AppDelegate.coffeeSettingDefaults[setting] {
                defaults.set(def, forKey: setting)
            } else {
                defaults.set("", forKey: setting)
            }
        }
        return defaults.string(forKey: setting)!
    }
    
    /*
        Set a setting. Special cases for hostname and topics will cause
        connection and topic subscription when they are changed.
    */
    public func setSetting(_ value: String, forKey key: String) {
        defaults.set(value, forKey: key)
        if AppDelegate.mqttSettingDefaults.keys.contains(key) {
            resetTopics()
            MqttDelegate.instance().subscribeTopics()
        }
        if key == "hostname" {
            if value == "" {
                forceUserToSetHostname()
            } else {
                if client != nil {
                    client.disconnect()
                }
                connectMqtt()
            }
        }
    }
    // convenience function to connect
    private func connectMqtt() {
        let clientId = "CocoaMQTT-coffee-" + String(ProcessInfo().processIdentifier)
        client = CocoaMQTT(clientId: clientId, host: getSetting("hostname"), port: 1883)
        if let mqtt = client {
            MqttDelegate.instance().setClient(mqtt)
            mqtt.delegate = MqttDelegate.instance()
            mqtt.connect()
        }
    }
    
    // remove and re-add all topics, resubscribing too
    public func resetTopics() {
        topics.removeAll()
        for (key, _) in AppDelegate.mqttSettingDefaults {
            topics.append(getSetting(key))
        }
        MqttDelegate.instance().setTopics(topics)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if getSetting("hostname") == "" {
            forceUserToSetHostname()
        }
        if getSetting("hostname") != "" {
            connectMqtt()
        }
        resetTopics()
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    // helper that switches to settings page and asks user for hostname of broker
    func forceUserToSetHostname() {
        let refreshAlert = UIAlertController(title: "Broker Hostname", message: "We need a broker hostname to work, please enter one in the settings.", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            if self.window!.rootViewController as? UITabBarController != nil {
                let tababarController = self.window!.rootViewController as! UITabBarController
                tababarController.selectedIndex = 2
                
            }
        }))
        
        self.window!.rootViewController?.present(refreshAlert, animated: true, completion: nil)
    }
}

