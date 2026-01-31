import SwiftUI
import SwiftData

@main
struct MiBiblioApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Asegúrate de que esta línea esté aquí y use el modelo Book
        .modelContainer(for: Book.self)
    }
}
