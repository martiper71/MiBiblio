import SwiftUI
import SwiftData

struct BookDetailView: View {
    @Bindable var book: Book
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 1. PORTADA (Igual que antes)
                ZStack {
                    AsyncImage(url: URL(string: book.coverUrl)) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                                .frame(height: 300)
                                .blur(radius: 20)
                                .opacity(0.5)
                        }
                    }
                    AsyncImage(url: URL(string: book.coverUrl)) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fit)
                                .shadow(radius: 10)
                        } else {
                            Image(systemName: "book.closed")
                                .font(.system(size: 80))
                                .foregroundStyle(.gray)
                        }
                    }
                    .frame(height: 220)
                }
                .frame(height: 300)
                .clipped()
                
                // 2. TÍTULO
                VStack(spacing: 8) {
                    Text(book.title).font(.title).bold().multilineTextAlignment(.center)
                    Text(book.author).font(.title3).foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                // 3. ZONA DE ESTADO (Aquí están los cambios)
                GroupBox {
                    VStack(spacing: 15) {
                        // INTERRUPTOR
                        Toggle(isOn: $book.isRead) {
                            HStack {
                                Image(systemName: book.isRead ? "flag.checkered" : "eyeglasses")
                                    .foregroundStyle(book.isRead ? .purple : .blue)
                                // Texto dinámico como pediste
                                Text(book.isRead ? "Terminado" : "Leyendo actualmente")
                                    .font(.headline)
                            }
                        }
                        // Al activar el toggle, asignamos fecha de hoy si no tenía
                        .onChange(of: book.isRead) { oldValue, newValue in
                            if newValue && book.dateFinished == nil {
                                book.dateFinished = Date()
                            }
                        }
                        
                        // OPCIONES QUE APARECEN AL TERMINAR EL LIBRO
                        if book.isRead {
                            Divider()
                            
                            // A) Selector de Fecha
                            DatePicker(
                                "Fecha de finalización",
                                selection: Binding(
                                    get: { book.dateFinished ?? Date() },
                                    set: { book.dateFinished = $0 }
                                ),
                                displayedComponents: .date
                            )
                            
                            Divider()
                            
                            // B) Calificación con Estrellas
                            HStack {
                                Text("Calificación")
                                Spacer()
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= book.rating ? "star.fill" : "star")
                                        .foregroundStyle(.yellow)
                                        .font(.title3)
                                        .onTapGesture {
                                            // Guardado automático al tocar
                                            withAnimation {
                                                book.rating = star
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // 4. NOTAS
                VStack(alignment: .leading) {
                    Text("Mis Notas").font(.headline).padding(.leading, 5)
                    TextEditor(text: Binding(get: { book.notes ?? "" }, set: { book.notes = $0 }))
                        .frame(height: 150)
                        .scrollContentBackground(.hidden)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // 5. BORRAR
                Button(role: .destructive, action: deleteBook) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Eliminar de mi biblioteca")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .padding(.top, 20)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
    
    func deleteBook() {
        modelContext.delete(book)
        dismiss()
    }
}
