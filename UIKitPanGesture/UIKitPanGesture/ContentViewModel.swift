import Foundation

class ContentViewModel: ObservableObject {
    static let shared = ContentViewModel()
    
    @Published var isLocked: Bool = false 
}
