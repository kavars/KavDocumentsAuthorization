//
//  FlowCoordinatorProtocol.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 26.03.2022.
//

import UIKit

public protocol FlowCoordinatorProtocol: AnyObject {
    func start(animated: Bool)
    func finish(animated: Bool, completion: (() -> Void)?)
}

extension FlowCoordinatorProtocol {
    func finish(animated: Bool) {
        finish(animated: animated, completion: nil)
    }
}

extension Array where Element == FlowCoordinatorProtocol {
    
    mutating func removeFlowCoordinator<T: FlowCoordinatorProtocol>(ofType type: T.Type) {
        guard let index = firstIndex(where: { $0 is T }) else { return }
        
        remove(at: index)
    }
    
    mutating func remove<T: FlowCoordinatorProtocol>(_ flowCoordinator: T.Type) {
        removeFlowCoordinator(ofType: flowCoordinator)
    }
    
    func flowCoordinator<T: FlowCoordinatorProtocol>(ofType type: T.Type) -> T? {
        return first(where: { $0 is T }) as? T
    }
    
    func flowCoordinator<T: FlowCoordinatorProtocol>() -> T? {
        return first(where: { $0 is T }) as? T
    }
    
    func finishAll(animated: Bool, completon: (() -> Void)? = nil) {
        guard let flowCoordinator = last else {
            completon?()
            return
        }
        
        var flowCoordinators = self
        flowCoordinator.finish(animated: animated) {
            flowCoordinators.removeLast()
            flowCoordinators.finishAll(animated: animated, completon: completon)
        }
    }
}

extension Array where Element == AnyObject {
    
    func flowCoordinatorInput<T>(ofType type: T.Type) -> T? {
        return first(where: { $0 is T }) as? T
    }
    
    func flowCoordinatorInput<T>() -> T? {
        return first(where: { $0 is T }) as? T
    }
}
