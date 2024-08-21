import SwiftUI
import UIKit

struct CircleView: UIViewRepresentable {
    class Coordinator: NSObject {
        var parent: CircleView
        
        init(parent: CircleView) {
            self.parent = parent
        }

        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            if gesture.state == .began {
                parent.isDragging = true
            }
        }

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard parent.isDragging else { return }

            let location = gesture.location(in: gesture.view)
            parent.circlePosition = location

            if gesture.state == .ended {
                parent.isDragging = false
            }
        }
    }

    @Binding var circlePosition: CGPoint
    @Binding var isDragging: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()

        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.1  // Adjust duration as needed
        view.addGestureRecognizer(longPressGesture)

        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        view.addGestureRecognizer(panGesture)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.subviews.forEach { $0.removeFromSuperview() }

        let circleDiameter: CGFloat = 100
        let circleView = UIView(frame: CGRect(x: circlePosition.x - circleDiameter / 2, y: circlePosition.y - circleDiameter / 2, width: circleDiameter, height: circleDiameter))
        circleView.backgroundColor = .blue
        circleView.layer.cornerRadius = circleDiameter / 2
        circleView.clipsToBounds = true

        uiView.addSubview(circleView)
    }
}

