import Foundation
import SwiftData

@Model
final class Book {
    var title: String
    var author: String
    var dateAdded: Date
    var coverUrl: String
    var startDate: Date
    var price: Double
    var format: String
    var isRead: Bool
    
    // Campos opcionales / nuevos
    var notes: String?
    var rating: Int
    var dateFinished: Date?
    
    // Init con valores por defecto para evitar errores
    init(title: String,
         author: String,
         coverUrl: String,
         startDate: Date = Date(),
         price: Double = 0.0,
         format: String = "Físico",
         isRead: Bool = false,
         notes: String? = nil,
         rating: Int = 0,
         dateFinished: Date? = nil) {
        
        self.title = title
        self.author = author
        self.dateAdded = Date()
        self.coverUrl = coverUrl
        self.startDate = startDate
        self.price = price
        self.format = format
        self.isRead = isRead
        self.notes = notes
        self.rating = rating
        self.dateFinished = dateFinished
    }
}
