import SwiftUI
import SwiftData

struct ContentView: View {
    // Controlamos si se muestra la pantalla de añadir libro
    @State private var showingAddBook = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                // 1. LEYENDO (Azul)
                NavigationLink(destination: BookListView(filterStatus: "Leyendo", title: "Leyendo")) {
                    MenuButton(title: "Leyendo", icon: "book.fill", color: .blue)
                }
                
                // 2. LEÍDOS (Rojo)
                NavigationLink(destination: BookListView(filterStatus: "Leídos", title: "Leídos")) {
                    MenuButton(title: "Leídos", icon: "checkmark.seal.fill", color: .red)
                }
                
                // 3. PRÓXIMOS (Naranja)
                NavigationLink(destination: BookListView(filterStatus: "Próximos", title: "Próximos libros")) {
                    MenuButton(title: "Próximos libros", icon: "clock.fill", color: .orange)
                }
                
                // 4. ESTADÍSTICAS (Morado/Indigo)
                NavigationLink(destination: StatsView()) {
                    MenuButton(title: "Estadísticas", icon: "chart.bar.xaxis", color: .indigo)
                }
                
                Spacer()
                
                // Botón flotante inferior para añadir
                Button(action: { showingAddBook = true }) {
                    Label("Añadir nuevo libro", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(25)
                        .shadow(radius: 3)
                }
                .padding(.bottom)
            }
            .padding()
            .navigationTitle("Mi Biblioteca")
            
            // --- AQUÍ ESTABA EL ERROR ---
            // Ahora pasamos 'isPresented' correctamente a la vista de búsqueda
            .sheet(isPresented: $showingAddBook) {
                SearchBookView(isPresented: $showingAddBook)
            }
        }
    }
}

// Componente visual de los botones (sin cambios)
struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
            Text(title)
                .font(.headline)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .opacity(0.6)
        }
        .foregroundColor(.white)
        .padding()
        .background(color)
        .cornerRadius(12)
        .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}
