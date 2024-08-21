import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel.shared

    var body: some View {
        VStack {
            Text("isLocked is \(viewModel.isLocked ? "true" : "false")")
            
            DraggableViewControllerWrapper()
                .edgesIgnoringSafeArea(.all) // Optional: make it full screen or adjust as needed
            
            if viewModel.isLocked {
                Button {
                    viewModel.isLocked = false
                } label: {
                    Text("Cancel")
                }
            }

        }
    }
}
