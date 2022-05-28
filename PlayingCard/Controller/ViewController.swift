//
//  ViewController.swift
//  PlayingCard
//
//  Created by a-robota on 5/20/22.
//

import UIKit

@IBDesignable
class ViewController: UIViewController {
    
    @IBInspectable
    @IBOutlet var PlayingCardsView: [PlayingCardView]!
    
    private var deck = PlayingCardDeck()
    //MARK: UIView, allows swipe && pinch 1
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    // MARK: Init for Item Behaviors, control to item behavior
    lazy var cardBehavior = ItemBehaviors(in: animator)
    
    
    @IBInspectable
    @IBOutlet weak var playingCardView: PlayingCardView! {
        didSet {
            //MARK: Gesture Swipe Recongixer
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
            swipe.direction = [.left, .right]
            playingCardView.addGestureRecognizer(swipe)
            //MARK: Pinch Gesture Recognizer
            let pinch = UIPinchGestureRecognizer(target: playingCardView, action: #selector(PlayingCardView.adjustFaceCardScale(byHandlingGestureRecognizedBy: )))
            playingCardView.addGestureRecognizer(pinch)
        }
    }
    @objc func nextCard() {
        if let card = deck.draw() {
            playingCardView.rank = card.rank.order
            playingCardView.suit = card.suit.rawValue
        }
    }
    
    @IBAction func flipCard(_ sender : UITapGestureRecognizer) {
        playingCardView.isFaceUp = !playingCardView.isFaceUp
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        var cards = [PlayingCard]()
        
        
        
        // MARK: Multiple Card Display
        for _ in 1...(((PlayingCardsView?.count ?? 4 )+1)/2) {
            if let card = deck.draw() {
                print("\(card)")
                cards += [card, card]
                // view.addSubview(view: PlayingCardsView)
            }
            // MARK: START of Behaviors
            for playingCard in PlayingCardsView {
                playingCard.isFaceUp = true
                let card = cards.remove(at: cards.count.arc4random)
                playingCard.rank = card.rank.order
                playingCard.suit = card.suit.rawValue
                
                // MARK: PlayingCard View Gesture Recognizer [flipCard0]
                playingCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard0(_:))))
                
                //MARK: Collision Boundries for playing cards
                cardBehavior.addItem(playingCard)
            }
        }
    }
    
    // MARK: FaceUp card views-> conrols  hidden / faceup cards
    private var faceUpCardViews : [PlayingCardView] {
        return PlayingCardsView.filter { $0.isFaceUp && !$0.isHidden && $0.transform != CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0) && $0.alpha == 1 } }
    
    private var faceUpCardViewsMatch : Bool {
        return faceUpCardViews.count == 2 &&
        faceUpCardViews[0].rank == faceUpCardViews[1].rank &&
        faceUpCardViews[0].suit == faceUpCardViews[1].suit
    }
    
    
    var lastChosenCardView: PlayingCardView?
    //MARK: [Recognizer] Augments the tap to a "transition flip to left" animation"
    @objc func flipCard0(_ recognizier: UITapGestureRecognizer) {
        print("starting flip card recognizer [TaP Gesture]")
        switch recognizier.state {
        case .ended:
            if let chosenCardView = recognizier.view as? PlayingCardView, faceUpCardViews.count < 2 {
                lastChosenCardView = chosenCardView
                
                cardBehavior.removeItem(chosenCardView)
                UIView.transition(
                    with: chosenCardView,
                    duration: 0.6,
                    options: [.transitionFlipFromLeft],
                    animations: {
                        chosenCardView.isFaceUp = !chosenCardView.isFaceUp
                    },
                    
                    
                    // MARK: Completion to handle addtional animations
                    completion: { finished in
                        // MARK: Property Scaling
                        let cardsToAnimate = self.faceUpCardViews
                        if self.faceUpCardViewsMatch {
                            // Mark --> transform to enlarge CardViews
                            UIViewPropertyAnimator.runningPropertyAnimator(
                                withDuration: 0.7,
                                delay: 0,
                                options: [],
                                animations: {
                                    cardsToAnimate.forEach {
                                        $0.transform = CGAffineTransform.identity.scaledBy(x:3.0, y: 3.0)
                                    }
                                },
                                completion: { position in
                                    // Mark --> transform to enlarge CardViews
                                    UIViewPropertyAnimator.runningPropertyAnimator(
                                        withDuration: 0.7,
                                        delay: 0,
                                        options: [],
                                        animations: {
                                            cardsToAnimate.forEach {
                                                $0.transform = CGAffineTransform.identity.scaledBy(x:0.1, y: 0.1)
                                                $0 .alpha = 0
                                            }
                                        },
                                        // MARK: Hide the cards
                                        completion:{ position in
                                            cardsToAnimate.forEach {
                                                $0.isHidden = true
                                                $0.alpha = 1
                                                $0.transform = .identity
                                            }
                                        }
                                    )
                                }
                            )
                            // MARK: UIView Transition
                        }  else if cardsToAnimate.count == 2 {
                            if chosenCardView == self.lastChosenCardView {
                            cardsToAnimate.forEach { PlayingCardsView in
                                UIView.transition(
                                    with: PlayingCardsView,
                                    duration: 0.6,
                                    options: [.transitionFlipFromLeft],
                                    animations: {
                                        PlayingCardsView.isFaceUp = false
                                    },
                                    completion: { finished in
                                        self.cardBehavior.addItem(PlayingCardsView)
                                    }
                                )
                            }
                            }
                        } else {
                            if !chosenCardView.isFaceUp {
                                self.cardBehavior.addItem(chosenCardView)
                                
                            }
                        }
                        
                    })}
            
         default: return
        }}}


// MARK: Random Int / CGFloat / Double extensions
extension CGFloat {
    var arc4random: CGFloat {
        if self > 0 {
            return CGFloat(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -CGFloat(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}
extension Double {
    var arc4random: Double {
        if self > 0 {
            return Double(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Double(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}

                
                
                
