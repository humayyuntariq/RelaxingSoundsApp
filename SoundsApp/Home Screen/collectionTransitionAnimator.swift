//
//  ollectionTransitionAnimator.swift
//  SoundsApp
//
//  Created by Humayun Tariq on 24/07/2025.
//

import UIKit

class CollectionTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var originImageView: UIImageView?
    var originLabel: UILabel?
    
    var destinationImageView: UIImageView?
    var destinationLabel: UILabel?

    var originFrame: CGRect = .zero

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to),
              let originImageView = originImageView,
              let originLabel = originLabel,
              let destinationImageView = destinationImageView,
              let destinationLabel = destinationLabel else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        container.addSubview(toVC.view)
        toVC.view.alpha = 0

        // Snapshot views
        let snapshotImage = UIImageView(image: originImageView.image)
        snapshotImage.contentMode = .scaleAspectFill
        snapshotImage.frame = container.convert(originImageView.bounds, from: originImageView)
        snapshotImage.clipsToBounds = true

        let snapshotLabel = UILabel()
        snapshotLabel.text = originLabel.text
        snapshotLabel.font = originLabel.font
        snapshotLabel.textColor = originLabel.textColor
        snapshotLabel.frame = container.convert(originLabel.bounds, from: originLabel)

        container.addSubview(snapshotImage)
        container.addSubview(snapshotLabel)

        originImageView.isHidden = true
        originLabel.isHidden = true
        destinationImageView.isHidden = true
        destinationLabel.isHidden = true

        let finalImageFrame = container.convert(destinationImageView.bounds, from: destinationImageView)
        let finalLabelFrame = container.convert(destinationLabel.bounds, from: destinationLabel)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            snapshotImage.frame = finalImageFrame
            snapshotLabel.frame = finalLabelFrame
            toVC.view.alpha = 1
        }, completion: { _ in
            originImageView.isHidden = false
            originLabel.isHidden = false
            destinationImageView.isHidden = false
            destinationLabel.isHidden = false

            snapshotImage.removeFromSuperview()
            snapshotLabel.removeFromSuperview()
            
            transitionContext.completeTransition(true)
        })
    }
}
