import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query private var books: [Book]
    
    // ESTADO: Año seleccionado
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                
                // 1. SELECTOR DE AÑO
                HStack(spacing: 25) {
                    Button(action: { withAnimation { selectedYear -= 1 } }) {
                        Image(systemName: "chevron.left")
                            .font(.largeTitle).foregroundStyle(.gray.opacity(0.5))
                            .contentShape(Rectangle())
                    }
                    
                    Text(String(selectedYear))
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundStyle(.indigo)
                        .contentTransition(.numericText(value: Double(selectedYear)))
                    
                    Button(action: { withAnimation { selectedYear += 1 } }) {
                        Image(systemName: "chevron.right")
                            .font(.largeTitle)
                            .foregroundStyle(selectedYear >= currentRealYear ? .gray.opacity(0.1) : .gray.opacity(0.5))
                            .contentShape(Rectangle())
                    }
                    .disabled(selectedYear >= currentRealYear)
                }
                .padding(.top, 20)
                
                Text("Resumen de Lectura")
                    .font(.title3).foregroundStyle(.secondary)
                
                // 2. BLOQUE DE DATOS
                VStack(spacing: 20) {
                    
                    // A. Tarjeta: Leídos en el año seleccionado
                    StatsCard(
                        title: "Leídos en \(String(selectedYear))",
                        count: booksReadInSelectedYear,
                        icon: "calendar.badge.clock",
                        color: .indigo
                    )
                    
                    // B. GRÁFICO DE BARRAS MENSUAL (EN ESPAÑOL)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ritmo Mensual")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 5)
                        
                        Chart {
                            ForEach(0..<12, id: \.self) { monthIndex in
                                BarMark(
                                    x: .value("Mes", getMonthName(monthIndex)),
                                    y: .value("Libros", getBooksCountForMonth(monthIndex))
                                )
                                .foregroundStyle(.indigo.gradient)
                                .cornerRadius(5)
                            }
                        }
                        .frame(height: 200)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(20)
                    }
                    
                    // C. Tarjeta: Total Histórico
                    StatsCard(
                        title: "Total Histórico",
                        count: totalBooksRead,
                        icon: "books.vertical.fill",
                        color: .green
                    )
                }
                .padding()
            }
        }
        .navigationTitle("Estadísticas")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // --- LÓGICA ---
    
    var currentRealYear: Int {
        Calendar.current.component(.year, from: Date())
    }
    
    var booksReadInSelectedYear: Int {
        books.filter { book in
            guard book.status == "Leídos", let date = book.dateFinished else { return false }
            return Calendar.current.component(.year, from: date) == selectedYear
        }.count
    }
    
    var totalBooksRead: Int {
        books.filter { $0.status == "Leídos" }.count
    }
    
    // FUNCIONES PARA EL GRÁFICO
    
    // 1. Obtener nombre del mes (AHORA EN CASTELLANO SIEMPRE)
    func getMonthName(_ index: Int) -> String {
        let meses = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"]
        return meses[index]
    }
    
    // 2. Contar libros por mes
    func getBooksCountForMonth(_ monthIndex: Int) -> Int {
        books.filter { book in
            guard book.status == "Leídos", let date = book.dateFinished else { return false }
            let components = Calendar.current.dateComponents([.year, .month], from: date)
            return components.year == selectedYear && components.month == (monthIndex + 1)
        }.count
    }
}

// Componente visual de tarjeta (sin cambios)
struct StatsCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.headline).foregroundStyle(.secondary)
                Text("\(count)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
            }
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(color.opacity(0.3))
        }
        .padding(25)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
    }
}
