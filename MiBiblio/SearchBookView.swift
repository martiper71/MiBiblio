import SwiftUI

struct SearchBookView: View {
    @Binding var isPresented: Bool
    @State private var query: String = ""
    @State private var foundBooks: [GoogleBookItem] = []
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            VStack {
                // BARRA DE BÚSQUEDA
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    TextField("Buscar por título o autor...", text: $query)
                        .submitLabel(.search)
                        .onSubmit {
                            Task {
                                await searchBooks()
                            }
                        }
                    
                    if !query.isEmpty {
                        Button(action: { query = ""; foundBooks = [] }) {
                            Image(systemName: "xmark.circle.fill").foregroundStyle(.gray)
                        }
                    }
                }
                .padding().background(Color(.systemGray6)).cornerRadius(10).padding()

                // RESULTADOS
                if isLoading {
                    ProgressView("Conectando con Google...").padding(.top, 50)
                    Spacer()
                } else {
                    List(foundBooks) { item in
                        NavigationLink(destination: AddBookDetailView(googleBook: item, isPresented: $isPresented)) {
                            HStack(spacing: 15) {
                                AsyncImage(url: URL(string: item.coverUrl)) { phase in
                                    if let image = phase.image {
                                        image.resizable().aspectRatio(contentMode: .fill)
                                    } else {
                                        Color.gray.opacity(0.2)
                                    }
                                }
                                .frame(width: 50, height: 75).cornerRadius(4)
                                
                                VStack(alignment: .leading) {
                                    Text(item.volumeInfo.title).font(.headline).lineLimit(2)
                                    Text(item.volumeInfo.authors?.joined(separator: ", ") ?? "Desconocido")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Añadir Libro")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { isPresented = false }
                }
            }
        }
    }

    @MainActor
    func searchBooks() async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        isLoading = true
        let cleanQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // --- 🔑 PEGA TU CLAVE AQUÍ ---
        let apiKey = "AIzaSyCFi3IGwH-BRG7QNe4K_0xrvlCgowgJBf8"
        // -----------------------------
        
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(cleanQuery)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }

        print("📡 Enviando petición a Google...")

        do {
            let config = URLSessionConfiguration.ephemeral
            let session = URLSession(configuration: config)
            
            let (data, _) = try await session.data(from: url)
            
            let decodedResponse = try JSONDecoder().decode(GoogleBookResponse.self, from: data)
            self.foundBooks = decodedResponse.items ?? []
            
            print("✅ Búsqueda finalizada. Libros encontrados: \(self.foundBooks.count)")
            
        } catch {
            print("❌ Error en la búsqueda: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}
