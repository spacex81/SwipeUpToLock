import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("LongPress Pan")
                .font(.largeTitle)
                .padding()
            
            DraggableViewControllerWrapper()
                .edgesIgnoringSafeArea(.all) // Optional: make it full screen or adjust as needed
        }
    }
}
