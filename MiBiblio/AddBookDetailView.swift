import SwiftUI
import SwiftData

struct AddBookDetailView: View {
    let googleBook: GoogleBookItem
    @Binding var isPresented: Bool
    @Environment(\.modelContext) private var modelContext
    
    @State private var readingOption = "Empezar a leer"
    let options = ["Empezar a leer", "Leer más tarde"]
    
    @State private var startDate = Date()
    @State private var price: Double = 0.0
    @State private var selectedFormat = "Físico"
    let formats = ["Físico", "Digital", "Audio"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Portada
                AsyncImage(url: URL(string: googleBook.coverUrl)) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fit)
                            .frame(height: 250).cornerRadius(12).shadow(radius: 5)
                    } else { Color.gray.opacity(0.1).frame(height: 250) }
                }.padding(.top)
                
                // Info Libro
                VStack(spacing: 4) {
                    Text(googleBook.volumeInfo.title).font(.title3).bold().multilineTextAlignment(.center)
                    Text(googleBook.volumeInfo.authors?.joined(separator: ", ") ?? "Autor Desconocido").foregroundStyle(.secondary)
                }.padding(.horizontal)
                
                // Opciones
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("¿Cuándo vas a leerlo?").font(.subheadline)
                        Picker("", selection: $readingOption) {
                            ForEach(options, id: \.self) { Text($0) }
                        }.pickerStyle(.segmented)
                    }
                    
                    if readingOption == "Empezar a leer" {
                        Divider()
                        DatePicker("Fecha de inicio", selection: $startDate, displayedComponents: .date).font(.subheadline)
                        Divider()
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Formato").font(.subheadline)
                            Picker("", selection: $selectedFormat) {
                                ForEach(formats, id: \.self) { Text($0) }
                            }.pickerStyle(.segmented)
                        }
                        Divider()
                        HStack {
                            Text("Precio").font(.subheadline)
                            Spacer()
                            TextField("0", value: $price, format: .number).keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                                .frame(width: 80).padding(6).background(Color(.systemGray6)).cornerRadius(8)
                            Text("€")
                        }
                    }
                }
                .padding().background(RoundedRectangle(cornerRadius: 15).fill(Color(.secondarySystemBackground))).padding(.horizontal)
                
                Button(action: saveBook) {
                    Text("Añadir a mi Biblioteca").bold().foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding().background(Color.blue).cornerRadius(15)
                }.padding(.horizontal).padding(.bottom, 30)
            }
        }
    }
    
    func saveBook() {
        let finalStatus = (readingOption == "Empezar a leer") ? "Leyendo" : "Próximos"
        
        let newBook = Book(
            title: googleBook.volumeInfo.title,
            author: googleBook.volumeInfo.authors?.joined(separator: ", ") ?? "Desconocido",
            coverUrl: googleBook.coverUrl,
            status: finalStatus,
            startDate: (readingOption == "Empezar a leer") ? startDate : nil,
            price: (readingOption == "Empezar a leer") ? price : 0.0,
            format: (readingOption == "Empezar a leer") ? selectedFormat : "Físico"
        )
        
        modelContext.insert(newBook)
        
        // ESTA ES LA CLAVE: Forzar el guardado inmediato
        do {
            try modelContext.save()
            print("✅ Libro guardado con éxito en el estado: \(finalStatus)")
            isPresented = false
        } catch {
            print("❌ ERROR AL GUARDAR: \(error.localizedDescription)")
        }
    }
}
