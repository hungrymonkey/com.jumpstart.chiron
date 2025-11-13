import Foundation
import SQLite3
internal import Combine

final class SQLiteManager: ObservableObject {
    static let shared = SQLiteManager()
    
    private var db: OpaquePointer?
    private let dbPath: String
    
    private init() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        dbPath = "\(documentsPath)/Database.sqlite"
        openDatabase()
        createTables()
    }
    
    deinit {
        sqlite3_close(db)
    }
    
    private func openDatabase() {
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            print("Unable to open database at \(dbPath)")
        }
    }
    
    private func createTables() {
        let createUserTable = """
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                email TEXT UNIQUE NOT NULL,
                name TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            );
        """
        
        if sqlite3_exec(db, createUserTable, nil, nil, nil) != SQLITE_OK {
            print("Error creating users table: \(String(cString: sqlite3_errmsg(db)))")
        }
    }
    
    // MARK: - User Operations
    func insertUser(email: String, name: String) -> Bool {
        let insertSQL = "INSERT INTO users (email, name) VALUES (?, ?)"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            sqlite3_bind_text(statement, 1, email, Int32(email.utf8.count), SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, name, Int32(name.utf8.count), SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                sqlite3_finalize(statement)
                print("Successfully inserted user: \(email), \(name)")
                return true
            } else {
                print("Failed to insert user: \(String(cString: sqlite3_errmsg(db)))")
            }
        } else {
            print("Failed to prepare statement: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(statement)
        return false
    }
    
    func getUser(by email: String) -> (id: Int, email: String, name: String)? {
        let querySQL = "SELECT id, email, name FROM users WHERE email = ?"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            email.withCString { emailCString in
                sqlite3_bind_text(statement, 1, emailCString, -1, nil)
            }
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                
                var email = ""
                if let emailCString = sqlite3_column_text(statement, 1) {
                    email = String(cString: emailCString)
                }
                
                var name = ""
                if let nameCString = sqlite3_column_text(statement, 2) {
                    name = String(cString: nameCString)
                }
                
                sqlite3_finalize(statement)
                return (id: id, email: email, name: name)
            }
        }
        
        sqlite3_finalize(statement)
        return nil
    }
    
    func getAllUsers() -> [(id: Int, email: String, name: String)] {
        // First, let's debug what's actually in the database
        debugDatabaseContents()
        
        let querySQL = "SELECT id, email, name FROM users ORDER BY created_at DESC"
        var statement: OpaquePointer?
        var users: [(id: Int, email: String, name: String)] = []
        
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                
                var email = ""
                if let emailCString = sqlite3_column_text(statement, 1) {
                    email = String(cString: emailCString)
                }
                
                var name = ""
                if let nameCString = sqlite3_column_text(statement, 2) {
                    name = String(cString: nameCString)
                }
                
                print("Retrieved user: id=\(id), email='\(email)', name='\(name)'")
                users.append((id: id, email: email, name: name))
            }
        } else {
            print("Failed to prepare getAllUsers statement: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(statement)
        return users
    }
    
    private func debugDatabaseContents() {
        let querySQL = "SELECT id, email, name, length(email), length(name) FROM users"
        var statement: OpaquePointer?
        
        print("=== DEBUG DATABASE CONTENTS ===")
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let emailLen = Int(sqlite3_column_int(statement, 3))
                let nameLen = Int(sqlite3_column_int(statement, 4))
                
                print("Row \(id): email_length=\(emailLen), name_length=\(nameLen)")
                
                // Try different ways to read the text
                if let emailBytes = sqlite3_column_text(statement, 1) {
                    let emailStr = String(cString: emailBytes)
                    print("  Email (cString): '\(emailStr)'")
                }
                
                if let nameBytes = sqlite3_column_text(statement, 2) {
                    let nameStr = String(cString: nameBytes)
                    print("  Name (cString): '\(nameStr)'")
                }
            }
        }
        sqlite3_finalize(statement)
        print("=== END DEBUG ===")
    }
    
    func deleteUser(by email: String) -> Bool {
        let deleteSQL = "DELETE FROM users WHERE email = ?"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteSQL, -1, &statement, nil) == SQLITE_OK {
            email.withCString { emailCString in
                sqlite3_bind_text(statement, 1, emailCString, -1, nil)
            }
            
            if sqlite3_step(statement) == SQLITE_DONE {
                sqlite3_finalize(statement)
                return true
            }
        }
        
        sqlite3_finalize(statement)
        return false
    }
    
    func clearAllUsers() -> Bool {
        let deleteSQL = "DELETE FROM users"
        let result = sqlite3_exec(db, deleteSQL, nil, nil, nil)
        if result == SQLITE_OK {
            print("All users cleared from database")
            return true
        } else {
            print("Failed to clear users: \(String(cString: sqlite3_errmsg(db)))")
            return false
        }
    }
}
