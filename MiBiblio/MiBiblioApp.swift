import SwiftUI
import SwiftData

@main
struct MiBiblioApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Book.self) // <--- ¡ESTO ES LO QUE FALTA!
    }
}
