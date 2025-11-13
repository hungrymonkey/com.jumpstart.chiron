import Foundation

struct User: Identifiable, Codable {
    let id: Int
    let email: String
    let name: String
    let createdAt: Date?
    
    init(id: Int, email: String, name: String, createdAt: Date? = nil) {
        self.id = id
        self.email = email
        self.name = name
        self.createdAt = createdAt
    }
}