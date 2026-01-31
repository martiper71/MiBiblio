import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isSearchPresented = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // TUS BOTONES ORIGINALES
                NavigationLink(destination: BookListView(filterStatus: "Leyendo", title: "Leyendo")) {
                    MenuButton(title: "Leyendo", icon: "book.fill", color: .blue)
                }

                NavigationLink(destination: BookListView(filterStatus: "Leídos", title: "Leídos")) {
                    MenuButton(title: "Leídos", icon: "checkmark.seal.fill", color: .pink)
                }

                // NUEVA SECCIÓN
                NavigationLink(destination: BookListView(filterStatus: "Próximos", title: "Próximos libros")) {
                    MenuButton(title: "Próximos libros", icon: "clock.arrow.circlepath", color: .orange)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Mi Biblioteca")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: { isSearchPresented = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Añadir nuevo libro")
                        }
                        .font(.headline)
                    }
                }
            }
            // Esto abre el buscador sobre tu pantalla de botones
            .sheet(isPresented: $isSearchPresented) {
                SearchBookView(isPresented: $isSearchPresented)
            }
        }
    }
}

// El diseño de tus botones para no repetir código
struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color)
        .foregroundColor(.white)
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}
