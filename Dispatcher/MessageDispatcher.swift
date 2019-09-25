//
//  MessageDispatcher.swift
//  POS
//
//  Created by Gal Blank on 1/15/16.
//

import UIKit

class MessageDispatcher: NSObject {
    
   @objc  static let sharedDispacherInstance = MessageDispatcher()
    
    var dispsatchTimer:Timer?
    var messageBus:[Message] = [Message]()
    var dispatchedMessages:[Message] = [Message]()
    private let _onceToken = NSUUID().uuidString
    
    @objc func consumeMessage(notif:NSNotification){
        let msg:Message = notif.userInfo!["message"] as! Message
        switch(msg.routingKey){
        case "msg.selfdestruct":
            let Index = messageBus.index(of: msg)
            if(Index! >= 0){
                messageBus.remove(at: Index!)
            }
            break
        default:
            break
        }
    }
    
    @objc(addMessageToBus:) public func addMessageToBus(newmessage: Message) {
       if(newmessage.routingKey.caseInsensitiveCompare("msg.selfdestruct") == ComparisonResult.orderedSame)
              {
                  let index:Int = messageBus.index(of: newmessage)!
                  if(index >= 0 ){
                      messageBus.remove(at: index)
                  }
              }
              
              messageBus.append(newmessage)
              
          
              
              DispatchQueue.once(token: _onceToken) {
                  
                  DispatchQueue.main.async {
                      if self.dispsatchTimer == nil {
                          self.startDispatching()
                      }
                  }
              }
   }
    
//    func addMessageToBus(newmessage: Message) {
//        if(newmessage.routingKey.caseInsensitiveCompare("msg.selfdestruct") == ComparisonResult.orderedSame)
//        {
//            let index:Int = messageBus.index(of: newmessage)!
//            if(index >= 0 ){
//                messageBus.remove(at: index)
//            }
//        }
//
//        messageBus.append(newmessage)
//
//
//
//        DispatchQueue.once(token: _onceToken) {
//
//            DispatchQueue.main.async {
//                if self.dispsatchTimer == nil {
//                    self.startDispatching()
//                }
//            }
//        }
//        dispatch_once(&Static.token) { () -> Void in
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                if self.dispsatchTimer == nil {
//                    self.startDispatching()
//                }
//            })
//
//        }
        
//    }
    
   @objc  func clearDispastchedMessages() {
        for msg:Message in dispatchedMessages {
            let Index = messageBus.index(of: msg)
            if(Index! >= 0){
                messageBus.remove(at: Index!)
            }
        }
        dispatchedMessages.removeAll()
    }
    
    
    @objc func startDispatching() {
        NotificationCenter.default.addObserver(self, selector: #selector(consumeMessage(notif:)), name: NSNotification.Name(rawValue: "msg.selfdestruct"), object: nil)
        dispsatchTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(leave), userInfo: nil, repeats: true)
    }
    
   @objc  func stopDispathing() {
        if dispsatchTimer != nil {
            dispsatchTimer!.invalidate()
            dispsatchTimer = nil
        }
    }
    
  @objc func leave() {
        let goingAwayBus:[Message] = NSArray(array: messageBus) as! [Message]
        for msg: Message in goingAwayBus {
            if(msg.shouldselfdestruct == false){
                self.dispatchMessage(message: msg)
                msg.shouldselfdestruct = true
                let index:Int = messageBus.index(of: msg)!
                if(index != NSNotFound){
                    messageBus.remove(at: index)
                }
            }
            
        }
    }
    
   @objc  func dispatchMessage(message: Message) {
        var messageDic: [NSObject : AnyObject] = [NSObject : AnyObject]()
        if message.routeFromRoutingKey().caseInsensitiveCompare("api") == ComparisonResult.orderedSame {
            MessageApiConverter.sharedInstance.messageTypeToApiCall(msg: message)
        }
        messageDic = ["message" : message ] as [NSObject : AnyObject]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: message.routingKey), object: nil, userInfo: messageDic)
    }
    
   @objc  func routeMessageToServerWithType(message: Message) {
        if message.params == nil {
            message.params? = [NSObject : AnyObject]() as AnyObject
        }
        let sectoken: String? = UserDefaults.standard.object(forKey: "securitytoken") as? String
        if sectoken != nil && (sectoken?.lengthOfBytes(using: String.Encoding.utf8))! > 0 {
            message.params?.set(sectoken, forKey: "securitytoken")
        }
    }
    
   @objc  func canSendMessage(message: Message) -> Bool {
        return true
    }
}
public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    class func once(token: String, block:()->Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}

