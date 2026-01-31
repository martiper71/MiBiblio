import SwiftUI
import SwiftData

struct BookListView: View {
    // La consulta a la base de datos
    @Query private var books: [Book]
    
    // Título de la pantalla (ej: "Leídos")
    let title: String
    
    // Configuración del filtro (Leído vs No leído)
    init(filterByRead: Bool, title: String) {
        self.title = title
        
        let predicate = #Predicate<Book> { book in
            book.isRead == filterByRead
        }
        
        _books = Query(filter: predicate, sort: \Book.dateAdded, order: .reverse)
    }

    var body: some View {
        List {
            if books.isEmpty {
                // Pantalla bonita cuando no hay libros
                ContentUnavailableView(
                    "No hay libros aquí",
                    systemImage: "books.vertical",
                    description: Text("Añade libros con el botón +")
                )
            } else {
                ForEach(books) { book in
                    
                    // --- AQUÍ ESTÁ EL CAMBIO ---
                    // Hemos metido el diseño dentro de este NavigationLink
                    // Esto hace que la fila sea "clicable"
                    NavigationLink(destination: BookDetailView(book: book)) {
                        
                        // Diseño visual de la fila
                        HStack(spacing: 12) {
                            // 1. Imagen Pequeña
                            AsyncImage(url: URL(string: book.coverUrl)) { phase in
                                if let image = phase.image {
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } else {
                                    Color.gray.opacity(0.3)
                                }
                            }
                            .frame(width: 50, height: 75)
                            .cornerRadius(6)
                            .shadow(radius: 2)
                            
                            // 2. Textos
                            VStack(alignment: .leading) {
                                Text(book.title)
                                    .font(.headline)
                                    .lineLimit(2)
                                
                                Text(book.author)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                // Etiquetas de precio y formato
                                HStack {
                                    Text(book.format)
                                        .font(.caption2)
                                        .padding(4)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(4)
                                    
                                    Text(book.price, format: .currency(code: "EUR"))
                                        .font(.caption2)
                                        .foregroundStyle(.gray)
                                }
                                .padding(.top, 2)
                            }
                        }
                        .padding(.vertical, 4)
                        
                    } // Fin del NavigationLink
                }
            }
        }
        .navigationTitle(title)
    }
}
