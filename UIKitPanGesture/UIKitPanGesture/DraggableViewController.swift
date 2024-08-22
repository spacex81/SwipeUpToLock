import UIKit
import Combine

class DraggableViewController: UIViewController {

    private let draggableView = UIView()
    private var longPressRecognized = false
    private var initialCenterY: CGFloat = 0.0
    private var maxUpwardDistance: CGFloat = 0.0
    private var viewModel = ContentViewModel.shared
    private var cancellables = Set<AnyCancellable>()
    
    private var shimmerLayer: CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up draggable view
        draggableView.backgroundColor = .blue
        draggableView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        draggableView.layer.cornerRadius = 50
        view.addSubview(draggableView)
        
        // Center the draggable view
        centerDraggableView()
        
        // Calculate the maximum upward distance
        let screenHeight = view.bounds.height
        maxUpwardDistance = screenHeight * 0.10 // 10% of the screen height
        
        // Add gesture recognizers
        setupGestures()
        
        viewModel.$isLocked
            .sink { [weak self] isLocked in
                if !isLocked {
                    self?.animateViewBackToOriginalPosition()
                    self?.removeShimmerEffect()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupShimmerEffect() {
        // Create the shimmer layer
        let shimmerLayer = CAGradientLayer()
        let shimmerHeight = maxUpwardDistance + draggableView.bounds.height
        shimmerLayer.frame = CGRect(x: 0, y: 0, width: draggableView.bounds.width, height: shimmerHeight)
        
        shimmerLayer.colors = [UIColor.clear.cgColor, UIColor.white.withAlphaComponent(0.5).cgColor, UIColor.clear.cgColor]
        shimmerLayer.locations = [0.0, 0.5, 1.0]
        
        // Create the animation to move shimmer effect from top to bottom
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.fromValue = 0
        animation.toValue = -shimmerHeight
        animation.duration = 1.5
        animation.repeatCount = .infinity
        shimmerLayer.add(animation, forKey: "shimmerAnimation")
        
        // Set the shimmer layer's position to match the draggable view's position
        shimmerLayer.position = CGPoint(x: draggableView.bounds.width / 2, y: draggableView.bounds.height / 2)
        
        // Add the shimmer layer to the draggable view
        draggableView.layer.addSublayer(shimmerLayer)
        self.shimmerLayer = shimmerLayer
    }
    
    private func removeShimmerEffect() {
        shimmerLayer?.removeFromSuperlayer()
        shimmerLayer = nil
    }

    private func centerDraggableView() {
        // Calculate the center of the screen
        let screenWidth = view.bounds.width
        let screenHeight = view.bounds.height
        
        // Set the draggable view's center
        draggableView.center = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        initialCenterY = draggableView.center.y
    }

    private func setupGestures() {
        // Long press gesture recognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        draggableView.addGestureRecognizer(longPressRecognizer)
        
        // Pan gesture recognizer
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        draggableView.addGestureRecognizer(panRecognizer)
        
        // Enable simultaneous gesture recognition
        draggableView.gestureRecognizers?.forEach {
            $0.delegate = self
        }
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            longPressRecognized = true
            setupShimmerEffect()
        } else if gesture.state == .ended {
            longPressRecognized = false
            // Animate back to the original position if not locked
            if !viewModel.isLocked {
                animateViewBackToOriginalPosition()
            }
            removeShimmerEffect()
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard longPressRecognized else { return }

        let translation = gesture.translation(in: view)
        guard let draggedView = gesture.view else { return }

        // Get the touch point in the view's coordinate space
        let touchPoint = gesture.location(in: view)
        
        // Determine if the touch is below the circle's center
        let isTouchBelowCenter = touchPoint.y < draggableView.center.y

        if gesture.state == .began || gesture.state == .changed {
            // Only update the center if moving upwards and within bounds and the touch is below the circle's center
            if isTouchBelowCenter {
                let newCenterY = draggedView.center.y + translation.y
                let minAllowedY = initialCenterY - maxUpwardDistance

                if newCenterY >= minAllowedY && newCenterY <= initialCenterY {
                    draggedView.center = CGPoint(x: draggedView.center.x, y: newCenterY)
                    
                    // Set isLocked if the view has reached the minAllowedY
                    if newCenterY <= minAllowedY + 1 {
                        if !viewModel.isLocked {
                            NSLog("LOG: is locked")
                            viewModel.isLocked = true
                        }
                    }
                }
            }
            gesture.setTranslation(.zero, in: view)
        } else if gesture.state == .ended {
            longPressRecognized = false
            // Animate back to the original position if not locked
            if !viewModel.isLocked {
                animateViewBackToOriginalPosition()
            }
            removeShimmerEffect()
        }
    }

    private func animateViewBackToOriginalPosition() {
        UIView.animate(withDuration: 0.3, animations: {
            self.draggableView.center = CGPoint(x: self.view.bounds.width / 2, y: self.initialCenterY)
        })
    }
}

extension DraggableViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
