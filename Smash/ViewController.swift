//
//  ViewController.swift
//  Smash
//
//  Created by Shannon Armon on 5/19/15.
//  Copyright (c) 2015 Shannon Armon. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {

    var animator: UIDynamicAnimator!
    var gravityBehavior = UIGravityBehavior()
    var collisionBehavior = UICollisionBehavior()
    var ballBehavior = UIDynamicItemBehavior()
    var brickBehavior = UIDynamicItemBehavior()
    var paddleBehavior = UIDynamicItemBehavior()
    
    var balls: [UIView] = []
    var bricks: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        animator = UIDynamicAnimator(referenceView: view)
        
        animator.addBehavior(gravityBehavior)
        animator.addBehavior(collisionBehavior)
        animator.addBehavior(ballBehavior)
        animator.addBehavior(brickBehavior)
        animator.addBehavior(paddleBehavior)
        
        gravityBehavior.gravityDirection = CGVectorMake(0, 2)
        
        ballBehavior.friction = 0
        ballBehavior.resistance = 0
        ballBehavior.elasticity = 1
        // ballBehavior.allowsRotation = false
        
        brickBehavior.density = 1000000
        
        paddleBehavior.density = 1000000
        paddleBehavior.allowsRotation = false
        
        
//        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionDelegate = self
        
        let pointTL = CGPointZero
        let pointTR = CGPointMake(view.frame.width, 0)
        let pointBL = CGPointMake(0, view.frame.height)
        let pointBR = CGPointMake(view.frame.width, view.frame.height)
        
        collisionBehavior.addBoundaryWithIdentifier("floor", fromPoint: pointBL, toPoint: pointBR)
        
        collisionBehavior.addBoundaryWithIdentifier("right", fromPoint: pointTR, toPoint: pointBR)
        
        collisionBehavior.addBoundaryWithIdentifier("left", fromPoint: pointTL, toPoint: pointBL)
        
        collisionBehavior.addBoundaryWithIdentifier("top", fromPoint: pointTL, toPoint: pointTR)
        
       
//            
//        createBall()           <===== Create 10 balls
//        
//        }
//        
        
        createBall()
        createBricks()
        createAPaddle()
        
        
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        
        for (b, brick) in enumerate(bricks) {
        
            if brick == item1 as! UIView || brick == item2 as! UIView {
            
                gravityBehavior.addItem(brick)
                
                bricks.removeAtIndex(b)
                
                collisionBehavior.removeItem(brick)
                
                var scoreLabel = UILabel(frame: brick.frame)
                scoreLabel.text = "+100!"
                scoreLabel.textAlignment = .Center
                view.addSubview(scoreLabel)
                
                
                
                UIView.animateWithDuration(0.9, animations: { () -> Void in
                    
                    scoreLabel.alpha = 0
                    brick.alpha = 0
                    
                }, completion: { (finished) -> Void in
                    
                    scoreLabel.removeFromSuperview()
                    brick.removeFromSuperview()
                    
                    
                })
                
            }
        
        }
        
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        
        
        if "floor" == identifier as! String {
        
            // remove ball
        
        }
           // println(identifier)
        
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        movePaddle(touches)
        
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        movePaddle(touches)
        
    }
    
    func movePaddle(touches: Set<NSObject>) {
    
        if let touch = touches.first as? UITouch {
            
            let location = touch.locationInView(view)
            
            attachment.anchorPoint.x = location.x
            
//            paddle.center.x = location.x
        
        }
        
    }
    
    var paddle = UIView(frame: CGRectMake(0, 0, 100, 10))
    var attachment: UIAttachmentBehavior!
    
    func createAPaddle() {
    
        paddle.backgroundColor = UIColor.blackColor()
        paddle.center = CGPointMake(view.center.x, view.frame.height - 40)
        
        view.addSubview(paddle)
        
        collisionBehavior.addItem(paddle)
        paddleBehavior.addItem(paddle)
        
        attachment = UIAttachmentBehavior(item: paddle, attachedToAnchor: paddle.center)
        
        animator.addBehavior(attachment)
    
    }

    func createBall() {
    
        var ball = UIView(frame: CGRectMake(20,20,20,20))
        balls.append(ball)
        
        ball.center = CGPointMake(view.center.x, view.frame.size.height - 100)
        
        ball.backgroundColor = UIColor.blackColor()
        ball.layer.cornerRadius = 10
        view.addSubview(ball)
        
        ballBehavior.addItem(ball)
        collisionBehavior.addItem(ball)
        
        var pusher = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.Instantaneous)
        
        
        
        pusher.pushDirection = CGVectorMake(0.1, -0.1)
        
        animator.addBehavior(pusher)
    
    }
    
    func createBricks() {
        
        let rows = 3
        let cols = 8
        
        let padding: CGFloat = 10
        
        for r in 0..<rows {
            
            for c in 0..<cols {
            
              let brickWidth = (view.frame.width - (padding * CGFloat(cols + 1))) / CGFloat(cols)
                
                let brickHeight: CGFloat = 30
                
                let brickX = (CGFloat(c) * (brickWidth + padding)) + padding
                let brickY = (CGFloat(r) * (brickHeight + padding)) + padding
                
                var brick = UIView(frame: CGRectMake(brickX, brickY, brickWidth, brickHeight))
                
                brick.backgroundColor = UIColor.redColor()
                
                view.addSubview(brick)
                bricks.append(brick)
                
                brickBehavior.addItem(brick)
                collisionBehavior.addItem(brick)
                
            }
        
        }
        
    }
    
}

