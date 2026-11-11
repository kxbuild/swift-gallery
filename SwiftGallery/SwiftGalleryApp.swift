import SwiftData
import SwiftUI

@main
struct SwiftGalleryApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: TodoItem.self)
    }
}
