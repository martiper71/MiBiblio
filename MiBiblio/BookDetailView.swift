import SwiftUI
import SwiftData

struct BookDetailView: View {
    @Bindable var book: Book
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    // Estado local para la puntuación antes de guardar
    @State private var rating: Int = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Portada
                AsyncImage(url: URL(string: book.coverUrl)) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                    Image(systemName: "book").font(.system(size: 100))
                }
                .frame(height: 250).padding(.top)

                Text(book.title).font(.title).bold().multilineTextAlignment(.center)
                Text(book.author).font(.title3).foregroundStyle(.secondary)

                // SECCIÓN DE ESTADO Y PUNTUACIÓN
                VStack(spacing: 15) {
                    if book.status == "Leyendo" {
                        Button(action: finishBook) {
                            Label("Marcar como terminado", systemImage: "checkmark.circle.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    } else if book.status == "Leídos" {
                        VStack(spacing: 10) {
                            Text("Tu calificación").font(.headline)
                            RatingView(rating: $book.rating) // Aquí usamos el componente de arriba
                                .font(.largeTitle)
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)

                // NOTAS
                VStack(alignment: .leading) {
                    Text("Mis Notas").font(.headline)
                    TextEditor(text: Binding(get: { book.notes ?? "" }, set: { book.notes = $0 }))
                        .frame(height: 150)
                        .padding(4)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                }
                .padding(.horizontal)

                Button("Eliminar libro", role: .destructive) {
                    modelContext.delete(book)
                    dismiss()
                }
                .padding(.top)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        // Al entrar, si ya tiene rating, lo cargamos
        .onAppear { rating = book.rating }
    }

    private func finishBook() {
        // Aquí podrías mostrar un pequeño Alert o Sheet para pedir las estrellas
        // Por ahora, lo movemos a leídos y podrías dejar que el usuario las pulse
        withAnimation {
            book.status = "Leídos"
            book.dateFinished = Date()
            // Aquí podrías añadir una lógica para que el usuario elija las estrellas
        }
    }
}
struct RatingView: View {
    @Binding var rating: Int
    
    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        rating = index
                    }
            }
        }
    }
}
