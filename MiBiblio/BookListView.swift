import SwiftUI
import SwiftData

struct BookListView: View {
    let filterStatus: String
    let title: String
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Book.dateAdded, order: .reverse) private var allBooks: [Book]
    
    // Filtro estricto por el estado
    var filteredBooks: [Book] {
        allBooks.filter { $0.status == filterStatus }
    }
    
    var body: some View {
        List {
            // Chivato temporal: si el número es > 0 pero no ves nada, es el filtro
            Section(header: Text("Total en BD: \(allBooks.count) | Filtrados: \(filteredBooks.count)")) {
                ForEach(filteredBooks) { book in
                    HStack {
                        NavigationLink(destination: BookDetailView(book: book)) {
                            HStack {
                                AsyncImage(url: URL(string: book.coverUrl)) { img in
                                    img.resizable()
                                } placeholder: { Color.gray.opacity(0.2) }
                                .frame(width: 40, height: 60).cornerRadius(4)
                                
                                VStack(alignment: .leading) {
                                    Text(book.title).font(.headline).lineLimit(1)
                                    Text(book.author).font(.subheadline).foregroundStyle(.secondary)
                                }
                            }
                        }
                        
                        if filterStatus == "Próximos" {
                            Button {
                                withAnimation {
                                    book.status = "Leyendo"
                                    book.startDate = Date()
                                }
                            } label: {
                                Image(systemName: "play.circle.fill").font(.title2).foregroundStyle(.orange)
                            }
                            .buttonStyle(.borderless)
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
