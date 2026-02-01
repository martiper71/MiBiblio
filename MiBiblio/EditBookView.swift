import SwiftUI
import SwiftData

struct EditBookView: View {
    @Bindable var book: Book
    @Environment(\.dismiss) var dismiss

    let formats = ["Físico", "Digital", "Audio"]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Información Principal")) {
                    TextField("Título", text: $book.title)
                    TextField("Autor", text: $book.author)
                }

                Section(header: Text("Detalles")) {
                    Picker("Formato", selection: $book.format) {
                        ForEach(formats, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)

                    HStack {
                        Text("Precio")
                        Spacer()
                        TextField("Precio", value: $book.price, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("€")
                    }
                }
                
                // Solo mostramos fechas si el libro ya se ha empezado o terminado
                if book.status != "Próximos" {
                    Section(header: Text("Fechas")) {
                        if book.startDate != nil {
                            DatePicker("Fecha Inicio", selection: Binding(
                                get: { book.startDate ?? Date() },
                                set: { book.startDate = $0 }
                            ), displayedComponents: .date)
                        }
                        
                        if book.dateFinished != nil {
                            DatePicker("Fecha Fin", selection: Binding(
                                get: { book.dateFinished ?? Date() },
                                set: { book.dateFinished = $0 }
                            ), displayedComponents: .date)
                        }
                    }
                }
            }
            .navigationTitle("Editar Libro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                }
            }
        }
    }
}
