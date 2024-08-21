import UIKit

class DraggableViewController: UIViewController {

    private let draggableView = UIView()
    private var longPressRecognized = false
    private var initialCenterY: CGFloat = 0.0
    private var maxUpwardDistance: CGFloat = 0.0

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
        } else if gesture.state == .ended {
            longPressRecognized = false
            // Animate back to the original position when the long press ends
            animateViewBackToOriginalPosition()
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard longPressRecognized else { return }

        let translation = gesture.translation(in: view)
        guard let draggedView = gesture.view else { return }
        
        if gesture.state == .began || gesture.state == .changed {
            let newCenterY = draggedView.center.y + translation.y
            
            // Calculate the maximum allowed position
            let minAllowedY = initialCenterY - maxUpwardDistance
            
            // Only update the center if moving upwards and within bounds
            if translation.y < 0 && newCenterY >= minAllowedY {
                draggedView.center = CGPoint(x: draggedView.center.x, y: newCenterY)
            }
            gesture.setTranslation(.zero, in: view)
        } else if gesture.state == .ended {
            longPressRecognized = false
            // Animate back to the original position when the pan ends
            animateViewBackToOriginalPosition()
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
