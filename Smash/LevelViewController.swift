//
//  ViewController.swift
//  Smash
//
//  Created by Shannon Armon on 5/19/15.
//  Copyright (c) 2015 Shannon Armon. All rights reserved.
//

import UIKit

class LevelViewController: UIViewController, UICollisionBehaviorDelegate {
    
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var livesView: BallCountView!
    
    @IBOutlet weak var currentScoreLabel: UILabel!
    @IBOutlet weak var topScoreLabel: UILabel!
   
    
    var currentScore: Int = 0 {
    
        didSet {
        
             currentScoreLabel.text = "Score: \(currentScore)"
            
            if currentScore > topScore {
                
                topScore = currentScore
            
            }
        
        }
        
    }
    
    var topScore: Int {
    
        get {
            
           return NSUserDefaults.standardUserDefaults().integerForKey("topScore")
            
        }                            //<===---NSUserDefaults small savings/settings
                                            //<-----Custom Getter and Setter
        set {
            
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: "topScore")
            NSUserDefaults.standardUserDefaults().synchronize()
            
        topScoreLabel.text = "\(newValue)"  //<---New Value comes with the SET
            
        }
        
    }

    var animator: UIDynamicAnimator!
    var gravityBehavior = UIGravityBehavior()
    var collisionBehavior = UICollisionBehavior()
    var ballBehavior = UIDynamicItemBehavior()
    var brickBehavior = UIDynamicItemBehavior()
    var paddleBehavior = UIDynamicItemBehavior()
    
    var balls: [UIView] = []
    var bricks: [BrickView] = []
    
    override func viewDidAppear(animated: Bool) {
     super.viewDidAppear(animated)
        
    //////////////
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        
//        view.setNeedsUpdateConstraints()
        
        topScoreLabel.text = "\(topScore)"

    
        animator = UIDynamicAnimator(referenceView: gameView)
        
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
        
        let pointTL = CGPointMake(0, 0)
        let pointTR = CGPointMake(gameView.frame.width, 0)
        let pointBL = CGPointMake(0, gameView.frame.height)
        let pointBR = CGPointMake(gameView.frame.width, gameView.frame.height)
        
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
            
                if brick.health > 1 {
                    
                    //reduce health
                    brick.health--
                
                } else {
                
                    //remove brick
                    gravityBehavior.addItem(brick)
                    
                    bricks.removeAtIndex(b)
                    
                    collisionBehavior.removeItem(brick)
                    
                    var scoreLabel = UILabel(frame: brick.frame)
                    scoreLabel.text = "+\(brick.points)"
                    scoreLabel.textAlignment = .Center
                    gameView.addSubview(scoreLabel)
                    
                    currentScore += brick.points 
                    
                    
                    
                    UIView.animateWithDuration(0.9, animations: { () -> Void in
                        
                        scoreLabel.alpha = 0
                        brick.alpha = 0
                        
                        }, completion: { (finished) -> Void in
                            
                            scoreLabel.removeFromSuperview()
                            brick.removeFromSuperview()
                            
                            
                    })
                    
                    if bricks.count == 0 {
                    
                     //level beaten
                    
                        //move this to when you hit play next level
                        GameData.mainData().currentLevel++
                        
                        if let levelVC = storyboard?.instantiateViewControllerWithIdentifier("LevelVC") as? LevelViewController {
                        
                            navigationController?.viewControllers = [levelVC]
                        
                        }
                    
                    }
                
                }
                
            }
        
        }
        
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        
        
        if "floor" == identifier as! String {
        
            // remove ball
        
            if balls.count > 0 {
                
                collisionBehavior.removeItem(balls[0])
                balls[0].removeFromSuperview()
                balls.removeAtIndex(0)
                
                if livesView.ballsLeft > 0 {
                    
                    livesView.ballsLeft--
                    
                     createBall()
                
                }
                
               
            }
            
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
        paddle.center = CGPointMake(gameView.center.x, gameView.frame.height - 40)
        
        gameView.addSubview(paddle)
        
        collisionBehavior.addItem(paddle)
        paddleBehavior.addItem(paddle)
        
        attachment = UIAttachmentBehavior(item: paddle, attachedToAnchor: paddle.center)
        
        animator.addBehavior(attachment)
    
    }

    func createBall() {
    
        var ball = UIView(frame: CGRectMake(20,20,20,20))
        balls.append(ball)
        
        ball.center = CGPointMake(gameView.center.x, gameView.frame.size.height - 100)
        
        ball.backgroundColor = UIColor.blackColor()
        ball.layer.cornerRadius = 10
        gameView.addSubview(ball)
        
        ballBehavior.addItem(ball)
        collisionBehavior.addItem(ball)
        
        var pusher = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.Instantaneous)
        
        
        
        pusher.pushDirection = CGVectorMake(0.1, -0.1)
        
        animator.addBehavior(pusher)
    
    }
    
    func createBricks() {
        
        let level = GameData.mainData().getCurrentLevelBricks()
        
        let padding: CGFloat = 10
        
        for r in 0..<level.count {
            
            let row = level[r]
            
            for c in 0..<row.count {
    
                if row[c] == 0 { continue } //<=== key word for loops
            
              let brickWidth = (gameView.frame.width - (padding * CGFloat(row.count + 1))) / CGFloat(row.count)
                
                let brickHeight: CGFloat = 30
                
                let brickX = (CGFloat(c) * (brickWidth + padding)) + padding
                let brickY = (CGFloat(r) * (brickHeight + padding)) + padding
                
                var brick = BrickView(frame: CGRectMake(brickX, brickY, brickWidth, brickHeight))
                
                brick.backgroundColor = UIColor.redColor()
                brick.health = row[c]
                
                gameView.addSubview(brick)
                bricks.append(brick)
                
                brickBehavior.addItem(brick)
                collisionBehavior.addItem(brick)
                
            }
        
        }
        
    }
    
}

