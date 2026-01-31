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
            // Chivato de control (puedes quitarlo si ya no lo necesitas)
            Section(header: Text("Total: \(filteredBooks.count) libros")) {
                ForEach(filteredBooks) { book in
                    NavigationLink(destination: BookDetailView(book: book)) {
                        HStack(spacing: 15) {
                            AsyncImage(url: URL(string: book.coverUrl)) { img in
                                img.resizable()
                            } placeholder: { Color.gray.opacity(0.2) }
                            .frame(width: 45, height: 65).cornerRadius(4)
                            
                            VStack(alignment: .leading) {
                                Text(book.title).font(.headline).lineLimit(1)
                                Text(book.author).font(.subheadline).foregroundStyle(.secondary)
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
