//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by a-robota on 5/20/22.
//

import Foundation
import UIKit

@IBDesignable
class PlayingCardView : UIView
{
    // MARK: setNeedsDisplay will call: (layoutSubViews) and setNeedsLayout will call: (draw)
    @IBInspectable
    var rank: Int = 5 { didSet { setNeedsDisplay(); setNeedsLayout() }}
    @IBInspectable
    var suit: String = "􀊵" { didSet { setNeedsDisplay(); setNeedsLayout() }}
    @IBInspectable
    var isFaceUp: Bool = true { didSet { setNeedsDisplay(); setNeedsLayout() }}
    
    var faceCardScale : CGFloat = sizeRatio.faceCardImageSizeToBoundsSize { didSet { setNeedsDisplay(); setNeedsLayout() }}
    
    //MARK: Handle Gesture for Pinch
    @objc func adjustFaceCardScale(byHandlingGestureRecognizedBy recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            faceCardScale *= recognizer.scale
            recognizer.scale = 1.0
        default: break
        }
    }
    
    // MARK: nsattributedString
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString
    {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [.paragraphStyle:paragraphStyle, .font:font])
    }
    
    //MARK: Corner Display
    private var cornerString : NSAttributedString { return centeredAttributedString(rankString+"\n"+suit, fontSize: cornerFontSize) }
    
    // MARK: Corner Labels
    private lazy var upperLeftCorner = createCornerLabel()
    private lazy var lowerRightCorner = createCornerLabel()
    
    private func createCornerLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0  // 0 = use as many lines per ned
        addSubview(label)
        return label
    }
    
    private func configureCornerLabel(_ label: UILabel)  {
        label.attributedText = cornerString
        label.frame.size = CGSize.zero // to expand in both directions (needed for sizeToFit() )
        label.sizeToFit()
        label.isHidden = !isFaceUp
        //  return label
    }
    
    private func drawPips() {
        let pipsPerRowForRank = [[0],[1],[1,1],[1,1,1],[2,2],[2,1,2], [2,2,2], [2,1,2,2], [2,2,2,2], [2,2,2,2], [2,2,1,2,2], [2,2,2,2,2]]
        
        // MARK: To Create Centered Attributed String
        func createPipString(thatFits pipRect: CGRect) -> NSAttributedString {
            let maxVerticalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.count, $0) })
            let maxHorizontalPipCount = CGFloat(pipsPerRowForRank.reduce(0) {max($1.max() ?? 0, $0)} )
            
            let verticalPipRowSpacing = pipRect.size.height / maxVerticalPipCount
            let attemptedPipString = centeredAttributedString(suit, fontSize: verticalPipRowSpacing)
            let probablyOkayPipStringSize = verticalPipRowSpacing / (attemptedPipString.size().height / verticalPipRowSpacing)
            
            let propablyOkayPipString = centeredAttributedString(suit, fontSize: probablyOkayPipStringSize)
            let probablyOkayPipStringFontSize = verticalPipRowSpacing / (attemptedPipString.size().height / verticalPipRowSpacing)
            
            
            if propablyOkayPipString.size().width > pipRect.size.width / maxHorizontalPipCount {
                return centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize / propablyOkayPipString.size().width / (pipRect.size.width / (pipRect.size.width / maxHorizontalPipCount)))
            } else {
                return propablyOkayPipString
            }
             if pipsPerRowForRank.indices.contains(rank) {
                let pipsPerRow = pipsPerRowForRank[rank]
                var pipRect = bounds.insetBy(dx: cornerOffset, dy: cornerOffset).insetBy(dx: cornerString.size().width, dy: cornerString.size().height / 2 )
                
                
                
                let pipString = createPipString(thatFits: pipRect)
                let pipRowSpacing = pipRect.size.height / CGFloat(pipsPerRow.count)
                pipRect.size.height = pipString.size().height
                pipRect.origin.y += (pipRowSpacing - pipRect.size.height) / 2
                for pipCount in pipsPerRow {
                    switch pipCount {
                    case 1:
                        pipString.draw(in: pipRect)
                    case 2:
                        pipString.draw(in: pipRect.leftHalf)
                        pipString.draw(in: pipRect.rightHalf)
                    default:
                        break
                    }
                    
                }
            }
        }
        
    }
    
    //MARK: To check if user changed OS Settings [ if OS Settings are changed, then is detected, redraw]
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    //MARK: Views
    override func layoutSubviews()
    {
        super.layoutSubviews()
        //MARK: Upper Left Corner Label
        configureCornerLabel(upperLeftCorner)
        upperLeftCorner.frame.origin.offsetBy(dx: cornerOffset, dy: cornerOffset)
        
        //MARK: Lower Right Corner Label [To match label rotations with OS rotation]
        configureCornerLabel(lowerRightCorner)
        lowerRightCorner.transform = CGAffineTransform.identity
            .translatedBy(x: lowerRightCorner.frame.width, y: lowerRightCorner.frame.size.height)
            .rotated(by: CGFloat.pi)
        lowerRightCorner.frame.origin = CGPoint(x: bounds.maxX, y: bounds.maxY)
            .offsetBy(dx: -cornerOffset, dy: -cornerOffset)
            .offsetBy(dx: -lowerRightCorner.frame.size.height, dy: -lowerRightCorner.frame.size.height )
    }
    
    
    override func draw(_ rect: CGRect)
    {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        // let path = UIBezierPath()
        roundedRect.addClip()
        UIColor.white.setFill()
        roundedRect.fill()
        
        // MARK: Display Card Face .
        
        
        if isFaceUp {
            if let faceCardImage = UIImage(named: rankString + suit, in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
                faceCardImage.draw(in: bounds.zoom(by: faceCardScale))
            } else {
                drawPips()
            }
            // MARK: Show back of card
        } else {
            if let cardBackImage = UIImage(named: "cardback") {
                cardBackImage.draw(in: bounds)
            }
        }
    }
}

// MARK: To fill in attributedString and assign card ranks [extension]
extension PlayingCardView {
    private struct sizeRatio {
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        static let faceCardImageSizeToBoundsSize: CGFloat = 0.75
    }
    
    // MARK: Attributed Strings Args [Extension]
    private var cornerRadius : CGFloat { return bounds.size.height * sizeRatio.cornerOffsetToCornerRadius }
    private var cornerOffset: CGFloat { return cornerRadius*sizeRatio.cornerFontSizeToBoundsHeight }
    private var cornerFontSize: CGFloat { return bounds.size.height * sizeRatio.cornerFontSizeToBoundsHeight }
    
    // MARK: Card Ranks [Extension]
    private var rankString : String {
        switch rank {
        case 1: return "A"
        case 2...10: return String(rank)
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default : return "?"
        }
    }
}

//MARK: For CGRect scalability
extension CGRect {
    
    var leftHalf : CGRect { return CGRect(x: minX, y: minY, width: width/2, height: height) }
    var rightHalf : CGRect { return CGRect(x: midX, y: midY, width: width/2, height: height) }
    
    func inset(by size: CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
    
    func sized(to size: CGSize) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    
    
    func zoom(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth) / 2, dy: (height - newHeight) / 2)
    }
}

// MARK: Views Positioning
extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x+dx, y: y+dy)
    }
}
// MARK: To make circle
//        path.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: 100.0, startAngle: 0, endAngle:  2*CGFloat.pi, clockwise: true)
//        path.lineWidth = 5
//        UIColor.green.setFill()
//        UIColor.red.setStroke()
//        path.stroke()
//        path.fill()
