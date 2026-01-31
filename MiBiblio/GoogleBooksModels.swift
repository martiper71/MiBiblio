import Foundation

// --- MODELOS DE DATOS SEGUROS (SENDABLE) ---
// Al añadir 'Sendable', le prometemos a Swift que estos datos
// pueden viajar seguros desde internet hasta la pantalla.

struct GoogleBookResponse: Codable, Sendable {
    let items: [GoogleBookItem]?
}

struct GoogleBookItem: Codable, Identifiable, Sendable {
    let id: String
    let volumeInfo: VolumeInfo
    
    // Convertimos la URL a segura (https)
    var coverUrl: String {
        guard let link = volumeInfo.imageLinks?.thumbnail else { return "" }
        return link.replacingOccurrences(of: "http://", with: "https://")
    }
}

struct VolumeInfo: Codable, Sendable {
    let title: String
    let authors: [String]?
    let publishedDate: String?
    let imageLinks: ImageLinks?
}

struct ImageLinks: Codable, Sendable {
    let thumbnail: String?
}
