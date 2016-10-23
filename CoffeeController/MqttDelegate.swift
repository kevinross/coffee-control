//
//  MqttController.swift
//  CoffeeController
//
//  Created by Kevin Ross on 2016-10-22.
//  Copyright © 2016 Kevin Ross. All rights reserved.
//

import Foundation
import CocoaMQTT

class MqttDelegate : CocoaMQTTDelegate {
    // singleton instance
    private static var _instance: MqttDelegate!
    public static func instance() -> MqttDelegate {
        if _instance == nil {
            _instance = MqttDelegate.init()
        }
        return _instance
    }
    private var _client: CocoaMQTT!
    private var connected: Bool = false

    public func client() -> CocoaMQTT {
        return _client
    }
    
    public func setClient(_ client: CocoaMQTT) {
        self._client = client
    }
    
    private var topics: [String] = [];
    /*
        when topics are set, unsubscribe from all old ones
    */
    func setTopics(_ topics: [String]?) {
        if let newTopics = topics {
            if connected {
                for topic in self.topics {
                    _client.unsubscribe(topic)
                }
            }
            self.topics = newTopics
        }
    }
    /*
        subscribe to all topics
     */
    func subscribeTopics() {
        if !connected {
            return
        }
        if _client != nil {
            for topic in self.topics {
                _client.subscribe(topic, qos: .qos0)
            }
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        if ack == .accept {
            connected = true
            setTopics(nil)
            subscribeTopics()
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        let name = NSNotification.Name(rawValue: "MQTTMessageNotification")
        NotificationCenter.default.post(name: name, object: self, userInfo: ["message": message.string!, "topic": message.topic])
    }
    // everything below is ignored and needed for the protocol
    func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        
    }
    
}
