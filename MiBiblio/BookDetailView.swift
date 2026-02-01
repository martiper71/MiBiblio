import SwiftUI
import SwiftData

struct BookDetailView: View {
    @Bindable var book: Book
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    // Estados
    @State private var showingRating = false
    @State private var showingStartSheet = false
    @State private var showingEditSheet = false // <--- NUEVO: Para abrir la edición
    
    // Variables temporales
    @State private var tempDate = Date()
    @State private var tempFormat = "Físico"
    @State private var tempPrice = 0.0
    let formats = ["Físico", "Digital", "Audio"]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 1. PORTADA
                AsyncImage(url: URL(string: book.coverUrl)) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                    Image(systemName: "book").font(.system(size: 100))
                }
                .frame(height: 250).padding(.top).shadow(radius: 5)

                // 2. TÍTULO Y AUTOR
                VStack(spacing: 5) {
                    Text(book.title).font(.title).bold().multilineTextAlignment(.center)
                    Text(book.author).font(.title3).foregroundStyle(.secondary)
                }.padding(.horizontal)

                // BLOQUE DE DETALLES (Fecha, Formato, Precio)
                if book.status != "Próximos" {
                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Text("Formato").font(.caption).textCase(.uppercase).foregroundStyle(.secondary)
                            Text(book.format).font(.headline)
                        }.frame(maxWidth: .infinity)
                        Divider()
                        VStack(spacing: 4) {
                            Text("Precio").font(.caption).textCase(.uppercase).foregroundStyle(.secondary)
                            Text(book.price.formatted(.currency(code: "EUR"))).font(.headline)
                        }.frame(maxWidth: .infinity)
                        Divider()
                        VStack(spacing: 4) {
                            Text("Inicio").font(.caption).textCase(.uppercase).foregroundStyle(.secondary)
                            if let start = book.startDate {
                                Text(start.formatted(date: .numeric, time: .omitted)).font(.headline)
                            } else { Text("-").font(.headline) }
                        }.frame(maxWidth: .infinity)
                    }
                    .padding().background(Color(.secondarySystemBackground)).cornerRadius(12).padding(.horizontal)
                }

                Divider().padding(.horizontal)

                // 3. LÓGICA DE ESTADO
                VStack(spacing: 20) {
                    // CASO A: Leyendo
                    if book.status == "Leyendo" {
                        if !showingRating {
                            Button(action: { withAnimation { showingRating = true } }) {
                                Label("Terminar Libro", systemImage: "flag.checkered")
                                    .font(.headline).foregroundColor(.white)
                                    .frame(maxWidth: .infinity).padding().background(Color.blue).cornerRadius(12)
                            }
                        } else {
                            VStack(spacing: 15) {
                                Text("¿Qué nota le pones?").font(.headline)
                                HStack(spacing: 10) {
                                    ForEach(1...5, id: \.self) { number in
                                        Image(systemName: number <= book.rating ? "star.fill" : "star")
                                            .font(.largeTitle).foregroundColor(.yellow)
                                            .onTapGesture { book.rating = number }
                                    }
                                }
                                Button(action: moveToRead) {
                                    Text("Guardar en Leídos").bold().foregroundColor(.white)
                                        .padding(.vertical, 10).padding(.horizontal, 30)
                                        .background(Color.green).cornerRadius(20)
                                }
                            }
                            .padding().background(Color.gray.opacity(0.1)).cornerRadius(15)
                        }
                    }
                    // CASO B: Leídos
                    else if book.status == "Leídos" {
                        VStack(spacing: 5) {
                            Text("Finalizado el \(book.dateFinished?.formatted(date: .abbreviated, time: .omitted) ?? "-")")
                                .font(.caption).foregroundStyle(.secondary)
                            HStack {
                                ForEach(1...5, id: \.self) { number in
                                    Image(systemName: number <= book.rating ? "star.fill" : "star")
                                        .foregroundColor(.yellow)
                                }
                            }.font(.title2)
                        }
                        .padding().frame(maxWidth: .infinity).background(Color.yellow.opacity(0.15)).cornerRadius(12)
                    }
                    // CASO C: Próximos
                    else {
                        Button(action: { showingStartSheet = true }) {
                            Label("Empezar a leer", systemImage: "book.fill")
                                .font(.headline).foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding().background(Color.orange).cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)

                // 4. NOTAS
                VStack(alignment: .leading) {
                    Text("Mis Notas").font(.headline)
                    TextEditor(text: Binding(get: { book.notes ?? "" }, set: { book.notes = $0 }))
                        .frame(height: 150).padding(4)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                }.padding()

                Button("Eliminar libro", role: .destructive) {
                    modelContext.delete(book)
                    dismiss()
                }.padding(.bottom, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        
        // --- AQUÍ ESTÁ EL NUEVO BOTÓN DE EDITAR ---
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Editar") {
                    showingEditSheet = true
                }
            }
        }
        // --- AQUÍ ESTÁ LA LÓGICA PARA ABRIR EL EDITOR ---
        .sheet(isPresented: $showingEditSheet) {
            EditBookView(book: book)
        }
        
        // HOJA DE INICIO DE LECTURA (Como antes)
        .fullScreenCover(isPresented: $showingStartSheet) {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 25) {
                        AsyncImage(url: URL(string: book.coverUrl)) { image in
                            image.resizable().aspectRatio(contentMode: .fit)
                        } placeholder: { Color.gray }
                        .frame(height: 250).cornerRadius(12).shadow(radius: 5).padding(.top, 40)
                        
                        Text(book.title).font(.title2).bold().multilineTextAlignment(.center).padding(.horizontal)
                        
                        VStack(spacing: 20) {
                            DatePicker("Fecha de inicio", selection: $tempDate, displayedComponents: .date).font(.subheadline)
                            Divider()
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Formato").font(.subheadline)
                                Picker("Formato", selection: $tempFormat) {
                                    ForEach(formats, id: \.self) { Text($0) }
                                }.pickerStyle(.segmented)
                            }
                            Divider()
                            HStack {
                                Text("Precio").font(.subheadline)
                                Spacer()
                                TextField("0", value: $tempPrice, format: .number)
                                    .keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                                    .frame(width: 80).padding(6).background(Color(.systemGray6)).cornerRadius(8)
                                Text("€").font(.body)
                            }
                        }
                        .padding().background(RoundedRectangle(cornerRadius: 15).fill(Color(.secondarySystemBackground))).padding(.horizontal)
                        
                        Button(action: confirmStartReading) {
                            Text("Confirmar y Empezar")
                                .bold().foregroundStyle(.white)
                                .frame(maxWidth: .infinity).padding().background(Color.blue).cornerRadius(15)
                        }
                        .padding(.horizontal).padding(.top, 20)
                    }
                }
                .navigationTitle("Configurar Lectura")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") { showingStartSheet = false }
                    }
                }
            }
        }
    }

    private func confirmStartReading() {
        withAnimation {
            book.status = "Leyendo"
            book.startDate = tempDate
            book.format = tempFormat
            book.price = tempPrice
            showingStartSheet = false
        }
    }

    private func moveToRead() {
        withAnimation {
            book.status = "Leídos"
            book.dateFinished = Date()
            showingRating = false
            dismiss()
        }
    }
}
