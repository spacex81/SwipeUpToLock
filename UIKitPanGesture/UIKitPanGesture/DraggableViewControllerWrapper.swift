import SwiftUI
import UIKit

struct DraggableViewControllerWrapper: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> DraggableViewController {
        return DraggableViewController()
    }

    func updateUIViewController(_ uiViewController: DraggableViewController, context: Context) {
        // You can update the view controller if needed
    }
}
