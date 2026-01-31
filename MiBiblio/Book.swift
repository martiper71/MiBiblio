import Foundation
import SwiftData

@Model
final class Book {
    // Propiedades básicas
    var title: String
    var author: String
    var dateAdded: Date
    var coverUrl: String
    
    // Propiedades de lectura y estado
    var status: String // "Leyendo", "Leídos" o "Próximos"
    var startDate: Date?
    var dateFinished: Date?
    var isRead: Bool // Mantenemos por compatibilidad, aunque usemos status
    
    // Propiedades de detalles
    var price: Double
    var format: String
    var notes: String?
    var rating: Int // El sistema de 5 estrellas (0 a 5)
    
    init(
        title: String,
        author: String,
        coverUrl: String,
        status: String = "Próximos",
        startDate: Date? = nil,
        price: Double = 0.0,
        format: String = "Físico",
        rating: Int = 0,
        notes: String = ""
    ) {
        self.title = title
        self.author = author
        self.coverUrl = coverUrl
        self.dateAdded = Date()
        self.status = status
        self.startDate = startDate
        self.dateFinished = nil
        self.isRead = (status == "Leídos")
        self.price = price
        self.format = format
        self.notes = notes
        self.rating = rating
    }
}
