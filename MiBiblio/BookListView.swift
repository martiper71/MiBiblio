import SwiftUI
import SwiftData

struct BookListView: View {
    let filterStatus: String
    let title: String
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Book.dateAdded, order: .reverse) private var allBooks: [Book]
    
    var filteredBooks: [Book] {
        allBooks.filter { $0.status == filterStatus }
    }
    
    var body: some View {
        List {
            Section(header: Text("Total: \(filteredBooks.count) libros")) {
                ForEach(filteredBooks) { book in
                    NavigationLink(destination: BookDetailView(book: book)) {
                        HStack(spacing: 15) {
                            // 1. PORTADA
                            AsyncImage(url: URL(string: book.coverUrl)) { img in
                                img.resizable()
                            } placeholder: { Color.gray.opacity(0.2) }
                            .frame(width: 45, height: 65).cornerRadius(4)
                            
                            // 2. DATOS DEL LIBRO
                            VStack(alignment: .leading, spacing: 4) {
                                Text(book.title)
                                    .font(.headline)
                                    .lineLimit(1)
                                
                                Text(book.author)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                // DETALLES EXTRA (Solo si NO es Próximos)
                                if filterStatus != "Próximos" {
                                    HStack(spacing: 8) {
                                        // Fecha
                                        if let start = book.startDate {
                                            Text(start.formatted(date: .numeric, time: .omitted))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        // Formato (etiqueta)
                                        Text(book.format)
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.gray.opacity(0.15))
                                            .cornerRadius(4)
                                        
                                        // Precio
                                        if book.price > 0 {
                                            Text(book.price.formatted(.currency(code: "EUR")))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .padding(.top, 2)
                                }
                            }
                        }
                    }
                }
                .onDelete(perform: deleteBooks)
            }
        }
        .navigationTitle(title)
    }

    private func deleteBooks(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredBooks[index])
        }
    }
}
