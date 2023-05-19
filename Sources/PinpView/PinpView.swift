//
//  PinpView.swift
//  Dictionarius
//
//  Created by Mico Miloloza on 14/11/2020.
//  Copyright © 2020 mm. All rights reserved.
//

import UIKit


protocol PinpViewControlsDelegate: AnyObject {
    func minimizePinpView(_ minimize: Bool)
}


final public class PinpView: UIView {
    
    public var activityIndicator: UIActivityIndicatorView!
    public var panGestureRecognizer: UIPanGestureRecognizer!
    
    private var lastLocation: CGPoint!
    private var pulloutPinpViewButton: UIButton!
    private var propertyAnimator: UIViewPropertyAnimator!
    private var blurVisualEffect: UIVisualEffectView!
    private var childView: UIView!
    
    private var pinpViewControlsDelegate: PinpViewControlsDelegate?
    
    public typealias PulloutPinpViewButtonPositionInfo = (show: Bool, edge: ActivePanEdge)
    
    public var pulloutPinpViewButtonPositionInfo: PulloutPinpViewButtonPositionInfo {
        get {
            guard let superview = superview else { return (false, .none) }
            
            if self.frame.midX < superview.frame.minX && self.frame.maxY < superview.frame.maxY && self.frame.minY > superview.frame.minY {
                return (true, .left)
            } else if self.frame.midX > superview.frame.maxX && self.frame.maxY < superview.frame.maxY && self.frame.minY > superview.frame.minY {
                return (true, .right)
            } else {
                return (false, .none)
            }
        }
    }
    
    public init(frame: CGRect, indicatorColor: UIColor = .gray, childView: UIView, pulloutIcon: UIImage) {
        super.init(frame: frame)
        self.childView = childView
        self.activityIndicator = UIActivityIndicatorView(style: .medium)
        self.activityIndicator.color = indicatorColor
        self.activityIndicator.hidesWhenStopped = true
        self.backgroundColor = .clear
        
        // Adding LMT as subview and positioning it to superview edges
        self.addSubview(childView)
        childView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.topAnchor.constraint(equalTo: self.topAnchor),
            childView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            childView.leftAnchor.constraint(equalTo: self.leftAnchor),
            childView.rightAnchor.constraint(equalTo: self.rightAnchor)
        ])
        
        let exitButton = UIButton()
        let blurEffect = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        
        
        // MARK: - Exit button setup
        self.addSubview(exitButton)
        
        exitButton.backgroundColor = .clear
        exitButton.tintColor = .darkGray
        exitButton.setImage(#imageLiteral(resourceName: "removeAllBetsX"), for: .normal)
        exitButton.imageView?.backgroundColor = .clear
        exitButton.addTarget(self, action: #selector(closePinpView), for: .touchUpInside)
        
        
        NSLayoutConstraint.activate([
            exitButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            exitButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            exitButton.heightAnchor.constraint(equalToConstant: 25),
            exitButton.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        exitButton.layer.cornerRadius = 8
        exitButton.addSubview(blurEffect)
        
        
        // MARK: - Blur effect setup
        blurEffect.frame = exitButton.bounds
        
        NSLayoutConstraint.activate([
            blurEffect.topAnchor.constraint(equalTo: exitButton.topAnchor),
            blurEffect.bottomAnchor.constraint(equalTo: exitButton.bottomAnchor),
            blurEffect.leftAnchor.constraint(equalTo: exitButton.leftAnchor),
            blurEffect.rightAnchor.constraint(equalTo: exitButton.rightAnchor)
        ])
        
        blurEffect.isUserInteractionEnabled = false
        exitButton.clipsToBounds = true
        exitButton.sendSubviewToBack(blurEffect)
        
        
        // MARK: - Adding activity indicator and centering it
        self.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        self.activityIndicator.startAnimating()
        
        
        // Setup pan gesture recognizer
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pinpViewWasDragged))
        self.addGestureRecognizer(panGestureRecognizer!)
        panGestureRecognizer?.maximumNumberOfTouches = 1
        lastLocation = self.center
        
        
        // Setup pullout button that is visible when lmt is pushed on screen edges
        pulloutPinpViewButton = UIButton()
        pulloutPinpViewButton.addTarget(self, action: #selector(showPinpView), for: .touchUpInside)
        self.addSubview(pulloutPinpViewButton)
        
        NSLayoutConstraint.activate([
            pulloutPinpViewButton.leftAnchor.constraint(equalTo: self.leftAnchor),
            pulloutPinpViewButton.rightAnchor.constraint(equalTo: self.rightAnchor),
            pulloutPinpViewButton.topAnchor.constraint(equalTo: self.topAnchor),
            pulloutPinpViewButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        pulloutPinpViewButton?.backgroundColor = .clear
        pulloutPinpViewButton?.alpha = 0
        
        blurVisualEffect = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        pulloutPinpViewButton.addSubview(blurVisualEffect)
        
        NSLayoutConstraint.activate([
            blurVisualEffect.topAnchor.constraint(equalTo: pulloutPinpViewButton.topAnchor),
            blurVisualEffect.bottomAnchor.constraint(equalTo: pulloutPinpViewButton.bottomAnchor),
            blurVisualEffect.leftAnchor.constraint(equalTo: pulloutPinpViewButton.leftAnchor),
            blurVisualEffect.rightAnchor.constraint(equalTo: pulloutPinpViewButton.rightAnchor)
        ])
        
        blurVisualEffect.isUserInteractionEnabled = false
        
        
        let leftImageView = UIImageView()
        let rightImageView = UIImageView()
        let leftImage = pulloutIcon
        let rightImage = pulloutIcon
        
        leftImageView.image = leftImage
        rightImageView.image = rightImage
        leftImageView.contentMode = .scaleAspectFit
        rightImageView.contentMode = .scaleAspectFit
        leftImageView.rotateBy180()
        
        pulloutPinpViewButton?.addSubview(leftImageView)
        pulloutPinpViewButton?.addSubview(rightImageView)
        
        NSLayoutConstraint.activate([
            leftImageView.leadingAnchor.constraint(equalTo: pulloutPinpViewButton.leadingAnchor),
            leftImageView.centerYAnchor.constraint(equalTo: pulloutPinpViewButton.centerYAnchor),
            leftImageView.heightAnchor.constraint(equalToConstant: 20),
            leftImageView.widthAnchor.constraint(equalToConstant: 40)
        ])
        
//        leftImageView.autoPinEdge(toSuperviewEdge: .leading)
//        leftImageView.autoAlignAxis(toSuperviewAxis: .horizontal)
//        leftImageView.autoSetDimension(.width, toSize: 40)
//        leftImageView.autoSetDimension(.height, toSize: 20)
        leftImageView.isUserInteractionEnabled = false
        
        NSLayoutConstraint.activate([
            rightImageView.trailingAnchor.constraint(equalTo: pulloutPinpViewButton.trailingAnchor),
            rightImageView.centerYAnchor.constraint(equalTo: pulloutPinpViewButton.centerYAnchor),
            rightImageView.heightAnchor.constraint(equalToConstant: 20),
            rightImageView.widthAnchor.constraint(equalToConstant: 40)
        ])
        
//        rightImageView.autoPinEdge(toSuperviewEdge: .trailing)
//        rightImageView.autoAlignAxis(toSuperviewAxis: .horizontal)
//        rightImageView.autoSetDimension(.width, toSize: 40)
//        rightImageView.autoSetDimension(.height, toSize: 20)
        rightImageView.isUserInteractionEnabled = false
        
        
    }
    
    deinit {
        
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Floating LMT controls
extension PinpView: UIGestureRecognizerDelegate {
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    /// Pan gesture recognizer handling function for floating view
    @objc func pinpViewWasDragged(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
            let translation = gestureRecognizer.translation(in: self.superview)
            childView.isUserInteractionEnabled = false
            guard let superview = superview else { return }
            
            switch gestureRecognizer.state {
            case .began:
                propertyAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
                    self.pulloutPinpViewButton.alpha = 0
                }
                propertyAnimator.startAnimation()
                propertyAnimator.pauseAnimation()
                lastLocation = self.center
                
            case .changed:
                if pulloutPinpViewButtonPositionInfo.show {
                    var fractionValue: CGFloat = 0.0
                    if pulloutPinpViewButtonPositionInfo.edge == .left || pulloutPinpViewButtonPositionInfo.edge == .leftClosing {
                        fractionValue = scaledValue(val: self.frame.midX, max: superview.frame.minX, min: (40 - superview.frame.minX - self.frame.width / 2))
                    } else if pulloutPinpViewButtonPositionInfo.edge == .right {
                        propertyAnimator.isReversed = true
                        fractionValue = scaledValue(val: self.frame.midX, max: superview.frame.maxX, min: (40 + superview.frame.maxX - self.frame.width / 2)) - 1
                    }
                    
                    propertyAnimator.fractionComplete = fractionValue
                }
                
                UIView.animate(withDuration: 0.1) {
                    self.center = CGPoint(x: self.lastLocation.x + translation.x, y: self.lastLocation.y + translation.y)
                }
                
            case .ended:
                if !self.pulloutPinpViewButtonPositionInfo.show {
                    self.propertyAnimator.stopAnimation(true)
                    self.propertyAnimator.finishAnimation(at: .end)
                    self.pulloutPinpViewButton.alpha = 0
                } else {
                    self.propertyAnimator.stopAnimation(true)
                    self.propertyAnimator.finishAnimation(at: .start)
                    self.pulloutPinpViewButton.alpha = 1
                }
                
                lastLocation = CGPoint(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)
               
                UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: {
                    self.center = self.positionFloatingPinpView(inside: superview)
                   
                }, completion: nil)
                
            case .cancelled:
                lastLocation = CGPoint(x: translation.x, y: translation.y)
                
            default:
                print("DEFAULT")
            }
        }
    }
    
    @objc func showPinpView() {
        guard let superview = superview else { return }
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: {
            self.propertyAnimator.stopAnimation(true)
            self.propertyAnimator.finishAnimation(at: .end)
            self.pulloutPinpViewButton.alpha = 0
            if self.pulloutPinpViewButtonPositionInfo.edge == .left {
                self.center = CGPoint(x: (superview.frame.minX + self.frame.width / 2), y: self.lastLocation.y)//self.lastLocation//self.positionFloatingLMT(inside: superview)
            } else if self.pulloutPinpViewButtonPositionInfo.edge == .right {
                self.center = CGPoint(x: (superview.frame.maxX - self.frame.width / 2), y: self.lastLocation.y)
            }
        }, completion: nil)
    }
    
    private func positionFloatingPinpView(inside superview: UIView) -> CGPoint {
        var activeEdge: ActivePanEdge = .none
        
        if self.frame.maxX > superview.frame.maxX && self.frame.maxY > superview.frame.maxY && self.frame.midY > superview.frame.midY { // bottom right corner
            activeEdge = .bottomRightCorner
        } else if self.frame.maxX > superview.frame.maxX && self.frame.minY < superview.frame.minY && self.frame.midY < superview.frame.midY { // top right corner
            activeEdge = .topRightCorner
        } else if self.frame.minX < superview.frame.minX && self.frame.maxY > superview.frame.maxY && self.frame.midY > superview.frame.midY { // bottom left corner
            activeEdge = .bottomLeftCorner
        } else if self.frame.minX < superview.frame.minX && self.frame.minY < superview.frame.minY && self.frame.midY < superview.frame.midY { // top left corner
            activeEdge = .topLeftCorner
            
        } else if self.frame.midX > superview.frame.maxX {
            activeEdge = .rightClosing
            lastLocation = CGPoint(x: (superview.frame.maxX + self.frame.width / 2) - 40, y: lastLocation.y)
        } else if self.frame.midX < superview.frame.minX {
            activeEdge = .leftClosing
            lastLocation = CGPoint(x: (superview.frame.minX - self.frame.width / 2) + 40, y: lastLocation.y)
            
        } else if self.frame.maxX > superview.frame.maxX { // right
            activeEdge = .right
            lastLocation = CGPoint(x: (superview.frame.maxX - self.frame.width / 2), y: lastLocation.y)
        } else if self.frame.minX < superview.frame.minX { // left
            activeEdge = .left
            lastLocation = CGPoint(x: (superview.frame.minX + self.frame.width / 2), y: lastLocation.y)
        } else if self.frame.maxY > superview.frame.maxY { // top
            activeEdge = .top
            lastLocation = CGPoint(x: lastLocation.x, y: (superview.frame.maxY - self.frame.height / 2))
        } else if self.frame.minY < superview.frame.minY { // bottom
            activeEdge = .bottom
            lastLocation = CGPoint(x: lastLocation.x, y: (superview.frame.minY + self.frame.height / 2))
        }
        
        
        switch activeEdge {
        case .top:
            return CGPoint(x: lastLocation.x, y: (superview.frame.maxY - self.frame.height / 2))
        case .bottom:
            return CGPoint(x: lastLocation.x, y: (superview.frame.minY + self.frame.height / 2))
        case .left:
            return CGPoint(x: (superview.frame.minX + self.frame.width / 2), y: lastLocation.y)
        case .right:
            return CGPoint(x: (superview.frame.maxX - self.frame.width / 2), y: lastLocation.y)
            
        case .topLeftCorner:
            return CGPoint(x: (superview.frame.minX + self.frame.width / 2), y: (superview.frame.minY + self.frame.height / 2))
        case .topRightCorner:
            return CGPoint(x: (superview.frame.maxX - self.frame.width / 2), y: (superview.frame.minY + self.frame.height / 2))
        case .bottomLeftCorner:
            return CGPoint(x: (superview.frame.minX + self.frame.width / 2), y: (superview.frame.maxY - self.frame.height / 2))
        case .bottomRightCorner:
            return CGPoint(x: (superview.frame.maxX - self.frame.width / 2), y: (superview.frame.maxY - self.frame.height / 2))
            
        case .leftClosing:
            return lastLocation
        case .rightClosing:
            return lastLocation
        case .none:
            return lastLocation
        }
    }
    
    private func scaledValue(val: CGFloat, max: CGFloat, min: CGFloat) -> CGFloat {
        return (val - min) / (max - min)
    }
    
    @objc func closePinpView() {
//        guard let parentVC = self.parentContainerViewController() as? MatchDetailsViewController else { return }
//        parentVC.minimizePinpView(false)
        pinpViewControlsDelegate?.minimizePinpView(true)
    }
}


public enum ActivePanEdge: Int {
    case none, left, bottom, top, right, topLeftCorner, topRightCorner, bottomLeftCorner, bottomRightCorner
    case leftClosing
    case rightClosing
}


extension UIImageView {
    public func rotateBy180() {
        transform = transform.rotated(by: .pi)
    }
}
