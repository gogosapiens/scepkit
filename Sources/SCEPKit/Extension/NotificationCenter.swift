//
//  NotificationCenter.swift
//  AICombine
//
//  Created by Illia Harkavy on 23/04/2024.
//

import Foundation

extension NotificationCenter {
    
    func addOneTimeObserver(forName name: NSNotification.Name?, object obj: Any? = nil, queue: OperationQueue? = nil, using block: @escaping (Notification) -> Void) {
        let tokenContainer = TokenContainer()
        tokenContainer.token = addObserver(forName: name, object: obj, queue: queue) { notification in
            Self.default.removeObserver(tokenContainer.token!)
            block(notification)
        }
    }
    
    func post(_ notificationName: Foundation.Notification.Name) {
        post(name: notificationName, object: nil)
    }
    
    class TokenContainer {
        var token: NSObjectProtocol?
    }
}
