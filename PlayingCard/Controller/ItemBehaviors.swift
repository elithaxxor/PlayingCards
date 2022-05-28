//
//  UIDynamicBehavior.swift
//  PlayingCard
//
//  Created by a-robota on 5/21/22.
//

import UIKit

class ItemBehaviors: UIDynamicBehavior {
    // MARK: Start For UIDynamic Animator
    // MARK: Start of Collsion behavior (boundries)
    
    var control = ViewController()
    lazy var collisionBehavior : UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        control.animator.addBehavior(behavior)
        return behavior
    }()
    
    // MARK: Start : Individual Item Behavior
    lazy var itemBehavior : UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = true
        behavior.elasticity = 1.0
        behavior.resistance = 0
        return behavior
    }()
    
    
    // MARK: Push Method
    private func push(_ item: UIDynamicItem) {
        // MARK: Start Of Push Behavior (movements & Bounds)
        let push = UIPushBehavior(items: [item],
                                  mode: .instantaneous)
        
        if let referenceBounds = dynamicAnimator?.referenceView?.bounds {
            let center = CGPoint(x: referenceBounds.midX, y: referenceBounds.midY)
           
            //MARK: Tune Animations.  
            switch (item.center.x, item.center.y) {
            case let (x, y) where x < center.x && y < center.y:
                push.angle = (CGFloat.pi/2).arc4random
                
            case let (x, y) where x > center.x && y < center.y:
                push.angle = CGFloat.pi-(CGFloat.pi/2).arc4random
                
            case let(x, y) where x < center.x && y > center.y:
                push.angle = CGFloat.pi+(-CGFloat.pi/2).arc4random
                
            case let (x, y) where x > center.x && y > center.y:
                push.angle = CGFloat.pi+(CGFloat.pi/2).arc4random
                
            default:
                push.angle = (CGFloat.pi*2).arc4random
            }
        }
        push.angle = (2*CGFloat.pi).arc4random
        push.magnitude = CGFloat(1.0) + CGFloat(2.0).arc4random
        push.action = {[ unowned push, weak self ] in
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    
    // MARK: Add Item Behavior
    func addItem(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        push(item)
    }
    
    // MARK: Remove Item Behavior
    func removeItem(_ item: UIDynamicItem) {
        collisionBehavior.removeItem(collisionBehavior as! UIDynamicItem)
        itemBehavior.removeItem(itemBehavior as! UIDynamicItem)
    }
    
    
    
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }
    
    convenience init(in animator : UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
}
