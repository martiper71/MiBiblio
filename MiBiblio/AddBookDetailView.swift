import SwiftUI
import SwiftData

struct AddBookDetailView: View {
    let googleBook: GoogleBookItem
    @Binding var isPresented: Bool
    
    @Environment(\.modelContext) private var modelContext
    @State private var startDate = Date()
    @State private var price: Double = 0.0
    @State private var selectedFormat = "Físico"
    
    let formats = ["Físico", "Digital", "Audio"]

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // 1. PORTADA CON SOMBRA
                AsyncImage(url: URL(string: googleBook.coverUrl)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 280)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 280)
                            .overlay(Image(systemName: "book.closed").font(.largeTitle))
                    }
                }
                .padding(.top, 20)

                // 2. TÍTULO Y AUTOR
                VStack(spacing: 8) {
                    Text(googleBook.volumeInfo.title)
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text(googleBook.volumeInfo.authors?.joined(separator: ", ") ?? "Autor desconocido")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                // 3. TARJETA DE DATOS
                VStack(spacing: 20) {
                    // Fecha de inicio
                    DatePicker("Fecha de inicio", selection: $startDate, displayedComponents: .date)
                        .font(.subheadline) // Estilo de fuente estándar

                    Divider()

                    // Formato con la misma fuente que la fecha
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Formato")
                            .font(.subheadline) // Ahora igual que "Fecha de inicio"
                        
                        Picker("Formato", selection: $selectedFormat) {
                            ForEach(formats, id: \.self) { format in
                                Text(format).tag(format)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Divider()

                    // Precio con el símbolo € al final
                    HStack {
                        Text("Precio")
                            .font(.subheadline)
                        Spacer()
                        TextField("0", value: $price, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                            .padding(6)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        Text("€") // Símbolo al final como pediste
                            .font(.body)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(Color(.secondarySystemBackground)))
                .padding(.horizontal)

                // 4. BOTÓN DE ACCIÓN
                Button(action: saveBook) {
                    Text("Añadir a mi Biblioteca")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    func saveBook() {
        let newBook = Book(
            title: googleBook.volumeInfo.title,
            author: googleBook.volumeInfo.authors?.joined(separator: ", ") ?? "Desconocido",
            coverUrl: googleBook.coverUrl,
            startDate: startDate,
            price: price,
            format: selectedFormat
        )
        modelContext.insert(newBook)
        isPresented = false
    }
}
