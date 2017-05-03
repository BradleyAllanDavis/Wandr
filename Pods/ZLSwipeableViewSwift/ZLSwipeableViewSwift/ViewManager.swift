//
//  ViewManager.swift
//  ZLSwipeableViewSwift
//
//  Created by Andrew Breckenridge on 5/17/16.
//  Copyright © 2016 Andrew Breckenridge. All rights reserved.
//

import UIKit

class ViewManager : NSObject {
    
    // Snapping -> [Moving]+ -> Snapping
    // Snapping -> [Moving]+ -> Swiping -> Snapping
    enum State {
        case Snapping(CGPoint), Moving(CGPoint), Swiping(CGPoint, CGVector)
    }
    
    var state: State {
        didSet {
            if case .Snapping(_) = oldValue,  case let .Moving(point) = state {
                unsnapView()
                attachView(toPoint: point)
            } else if case .Snapping(_) = oldValue,  case let .Swiping(origin, direction) = state {
                unsnapView()
                attachView(toPoint: origin)
                pushView(fromPoint: origin, inDirection: direction)
            } else if case .Moving(_) = oldValue, case let .Moving(point) = state {
                moveView(toPoint: point)
            } else if case .Moving(_) = oldValue, case let .Snapping(point) = state {
                detachView()
                snapView(point: point)
            } else if case .Moving(_) = oldValue, case let .Swiping(origin, direction) = state {
                pushView(fromPoint: origin, inDirection: direction)
            } else if case .Swiping(_, _) = oldValue, case let .Snapping(point) = state {
                unpushView()
                detachView()
                snapView(point: point)
            }
        }
    }
    
    /// To be added to view and removed
    private class ZLPanGestureRecognizer: UIPanGestureRecognizer { }
    private class ZLTapGestureRecognizer: UITapGestureRecognizer { }
    
    static private let anchorViewWidth = CGFloat(1000)
    private var anchorView = UIView(frame: CGRect(x: 0, y: 0, width: anchorViewWidth, height: anchorViewWidth))
    
    private var snapBehavior: UISnapBehavior!
    private var viewToAnchorViewAttachmentBehavior: UIAttachmentBehavior!
    private var anchorViewToPointAttachmentBehavior: UIAttachmentBehavior!
    private var pushBehavior: UIPushBehavior!
    
    private let view: UIView
    private let containerView: UIView
    private let miscContainerView: UIView
    private let animator: UIDynamicAnimator
    private weak var swipeableView: ZLSwipeableView?
    
    init(view: UIView, containerView: UIView, index: Int, miscContainerView: UIView, animator: UIDynamicAnimator, swipeableView: ZLSwipeableView) {
        self.view = view
        self.containerView = containerView
        self.miscContainerView = miscContainerView
        self.animator = animator
        self.swipeableView = swipeableView
        self.state = ViewManager.defaultSnappingState(view: view)
        
        super.init()
        
        view.addGestureRecognizer(ZLPanGestureRecognizer(target: self, action: #selector(ViewManager.handlePan(_:))))
        view.addGestureRecognizer(ZLTapGestureRecognizer(target: self, action: #selector(ViewManager.handleTap(_:))))
        miscContainerView.addSubview(anchorView)
        containerView.insertSubview(view, at: index)
    }
    
    static func defaultSnappingState(view: UIView) -> State {
        return .Snapping(view.convert(view.center, from: view.superview))
    }
    
    func snappingStateAtContainerCenter() -> State {
        guard let swipeableView = swipeableView else { return ViewManager.defaultSnappingState(view: view) }
        return .Snapping(containerView.convert(swipeableView.center, from: swipeableView.superview))
    }
    
    deinit {
        if let snapBehavior = snapBehavior {
            removeBehavior(behavior: snapBehavior)
        }
        if let viewToAnchorViewAttachmentBehavior = viewToAnchorViewAttachmentBehavior {
            removeBehavior(behavior: viewToAnchorViewAttachmentBehavior)
        }
        if let anchorViewToPointAttachmentBehavior = anchorViewToPointAttachmentBehavior {
            removeBehavior(behavior: anchorViewToPointAttachmentBehavior)
        }
        if let pushBehavior = pushBehavior {
            removeBehavior(behavior: pushBehavior)
        }
        
        for gestureRecognizer in view.gestureRecognizers! {
            if gestureRecognizer.isKind(of: ZLPanGestureRecognizer.classForCoder()) {
                view.removeGestureRecognizer(gestureRecognizer)
            }
        }
        
        anchorView.removeFromSuperview()
        view.removeFromSuperview()
    }
    
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        guard let swipeableView = swipeableView else { return }
        
        let translation = recognizer.translation(in: containerView)
        let location = recognizer.location(in: containerView)
        let velocity = recognizer.velocity(in: containerView)
        let movement = Movement(location: location, translation: translation, velocity: velocity)
        
        switch recognizer.state {
        case .began:
            guard case .Snapping(_) = state else { return }
            state = .Moving(location)
            swipeableView.didStart?(view, location)
        case .changed:
            guard case .Moving(_) = state else { return }
            state = .Moving(location)
            swipeableView.swiping?(view, location, translation)
        case .ended, .cancelled:
            guard case .Moving(_) = state else { return }
            if swipeableView.shouldSwipeView(view, movement, swipeableView) {
                let directionVector = CGVector(point: translation.normalized * max(velocity.magnitude, swipeableView.minVelocityInPointPerSecond))
                state = .Swiping(location, directionVector)
                swipeableView.swipeView(view: view, location: location, directionVector: directionVector)
            } else {
                state = snappingStateAtContainerCenter()
                swipeableView.didCancel?(view)
            }
            swipeableView.didEnd?(view, location)
        default:
            break
        }
    }
    
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let swipeableView = swipeableView, let topView = swipeableView.topView()  else { return }
        
        let location = recognizer.location(in: containerView)
        swipeableView.didTap?(topView, location)
    }
    
    private func snapView(point: CGPoint) {
        snapBehavior = UISnapBehavior(item: view, snapTo: point)
        snapBehavior!.damping = 0.75
        addBehavior(behavior: snapBehavior)
    }
    
    private func unsnapView() {
        guard let snapBehavior = snapBehavior else { return }
        removeBehavior(behavior: snapBehavior)
    }
    
    private func attachView(toPoint point: CGPoint) {
        anchorView.center = point
        anchorView.backgroundColor = UIColor.blue
        anchorView.isHidden = true
        
        // attach aView to anchorView
        let p = view.center
        viewToAnchorViewAttachmentBehavior = UIAttachmentBehavior(item: view, offsetFromCenter: UIOffset(horizontal: -(p.x - point.x), vertical: -(p.y - point.y)), attachedTo: anchorView, offsetFromCenter: UIOffset.zero)
        viewToAnchorViewAttachmentBehavior!.length = 0
        
        // attach anchorView to point
        anchorViewToPointAttachmentBehavior = UIAttachmentBehavior(item: anchorView, offsetFromCenter: UIOffset.zero, attachedToAnchor: point)
        anchorViewToPointAttachmentBehavior!.damping = 100
        anchorViewToPointAttachmentBehavior!.length = 0
        
        addBehavior(behavior: viewToAnchorViewAttachmentBehavior!)
        addBehavior(behavior: anchorViewToPointAttachmentBehavior!)
    }
    
    private func moveView(toPoint point: CGPoint) {
        guard let _ = viewToAnchorViewAttachmentBehavior, let toPoint = anchorViewToPointAttachmentBehavior else { return }
        toPoint.anchorPoint = point
    }
    
    private func detachView() {
        guard let viewToAnchorViewAttachmentBehavior = viewToAnchorViewAttachmentBehavior, let anchorViewToPointAttachmentBehavior = anchorViewToPointAttachmentBehavior else { return }
        removeBehavior(behavior: viewToAnchorViewAttachmentBehavior)
        removeBehavior(behavior: anchorViewToPointAttachmentBehavior)
    }
    
    private func pushView(fromPoint point: CGPoint, inDirection direction: CGVector) {
        guard let _ = viewToAnchorViewAttachmentBehavior, let anchorViewToPointAttachmentBehavior = anchorViewToPointAttachmentBehavior  else { return }
        
        removeBehavior(behavior: anchorViewToPointAttachmentBehavior)
        
        pushBehavior = UIPushBehavior(items: [anchorView], mode: .instantaneous)
        pushBehavior.pushDirection = direction
        addBehavior(behavior: pushBehavior)
    }
    
    private func unpushView() {
        guard let pushBehavior = pushBehavior else { return }
        removeBehavior(behavior: pushBehavior)
    }
    
    private func addBehavior(behavior: UIDynamicBehavior) {
        animator.addBehavior(behavior)
    }
    
    private func removeBehavior(behavior: UIDynamicBehavior) {
        animator.removeBehavior(behavior)
    }
    
}
