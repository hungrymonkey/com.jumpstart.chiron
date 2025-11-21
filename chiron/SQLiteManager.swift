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
        
        let createResumeTable = """
            CREATE TABLE IF NOT EXISTS resumes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                title TEXT NOT NULL,
                summary TEXT,
                phone TEXT,
                address TEXT,
                website TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
            );
        """
        
        let createEducationTable = """
            CREATE TABLE IF NOT EXISTS education (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                resume_id INTEGER NOT NULL,
                institution TEXT NOT NULL,
                degree TEXT,
                field_of_study TEXT,
                start_date TEXT,
                end_date TEXT,
                description TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (resume_id) REFERENCES resumes (id) ON DELETE CASCADE
            );
        """
        
        let createExperienceTable = """
            CREATE TABLE IF NOT EXISTS experience (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                resume_id INTEGER NOT NULL,
                company TEXT NOT NULL,
                position TEXT NOT NULL,
                start_date TEXT,
                end_date TEXT,
                description TEXT,
                location TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (resume_id) REFERENCES resumes (id) ON DELETE CASCADE
            );
        """
        
        if sqlite3_exec(db, createUserTable, nil, nil, nil) != SQLITE_OK {
            print("Error creating users table: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        if sqlite3_exec(db, createResumeTable, nil, nil, nil) != SQLITE_OK {
            print("Error creating resumes table: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        if sqlite3_exec(db, createEducationTable, nil, nil, nil) != SQLITE_OK {
            print("Error creating education table: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        if sqlite3_exec(db, createExperienceTable, nil, nil, nil) != SQLITE_OK {
            print("Error creating experience table: \(String(cString: sqlite3_errmsg(db)))")
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
    
    // MARK: - Resume Operations
    func insertResume(userId: Int, title: String, summary: String? = nil, phone: String? = nil, address: String? = nil, website: String? = nil) -> Bool {
        let insertSQL = "INSERT INTO resumes (user_id, title, summary, phone, address, website) VALUES (?, ?, ?, ?, ?, ?)"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            sqlite3_bind_int(statement, 1, Int32(userId))
            sqlite3_bind_text(statement, 2, title, Int32(title.utf8.count), SQLITE_TRANSIENT)
            
            if let summary = summary {
                sqlite3_bind_text(statement, 3, summary, Int32(summary.utf8.count), SQLITE_TRANSIENT)
            } else {
                sqlite3_bind_null(statement, 3)
            }
            
            if let phone = phone {
                sqlite3_bind_text(statement, 4, phone, Int32(phone.utf8.count), SQLITE_TRANSIENT)
            } else {
                sqlite3_bind_null(statement, 4)
            }
            
            if let address = address {
                sqlite3_bind_text(statement, 5, address, Int32(address.utf8.count), SQLITE_TRANSIENT)
            } else {
                sqlite3_bind_null(statement, 5)
            }
            
            if let website = website {
                sqlite3_bind_text(statement, 6, website, Int32(website.utf8.count), SQLITE_TRANSIENT)
            } else {
                sqlite3_bind_null(statement, 6)
            }
            
            if sqlite3_step(statement) == SQLITE_DONE {
                sqlite3_finalize(statement)
                return true
            }
        }
        
        sqlite3_finalize(statement)
        return false
    }
    
    func getResumesByUserId(_ userId: Int) -> [(id: Int, title: String, summary: String?, phone: String?, address: String?, website: String?)] {
        let querySQL = "SELECT id, title, summary, phone, address, website FROM resumes WHERE user_id = ?"
        var statement: OpaquePointer?
        var resumes: [(id: Int, title: String, summary: String?, phone: String?, address: String?, website: String?)] = []
        
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(userId))
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let title = String(cString: sqlite3_column_text(statement, 1))
                
                let summary = sqlite3_column_text(statement, 2) != nil ? String(cString: sqlite3_column_text(statement, 2)) : nil
                let phone = sqlite3_column_text(statement, 3) != nil ? String(cString: sqlite3_column_text(statement, 3)) : nil
                let address = sqlite3_column_text(statement, 4) != nil ? String(cString: sqlite3_column_text(statement, 4)) : nil
                let website = sqlite3_column_text(statement, 5) != nil ? String(cString: sqlite3_column_text(statement, 5)) : nil
                
                resumes.append((id: id, title: title, summary: summary, phone: phone, address: address, website: website))
            }
        }
        
        sqlite3_finalize(statement)
        return resumes
    }
    
    // MARK: - Education Operations
    func insertEducation(resumeId: Int, institution: String, degree: String? = nil, fieldOfStudy: String? = nil, startDate: String? = nil, endDate: String? = nil, description: String? = nil) -> Bool {
        let insertSQL = "INSERT INTO education (resume_id, institution, degree, field_of_study, start_date, end_date, description) VALUES (?, ?, ?, ?, ?, ?, ?)"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            sqlite3_bind_int(statement, 1, Int32(resumeId))
            sqlite3_bind_text(statement, 2, institution, Int32(institution.utf8.count), SQLITE_TRANSIENT)
            
            if let degree = degree {
                sqlite3_bind_text(statement, 3, degree, Int32(degree.utf8.count), SQLITE_TRANSIENT)
            } else {
                sqlite3_bind_null(statement, 3)
            }
            
            if let fieldOfStudy = fieldOfStudy {
                sqlite3_bind_text(statement, 4, fieldOfStudy, Int32(fieldOfStudy.utf8.count), SQLITE_TRANSIENT)
            } else {
                sqlite3_bind_null(statement, 4)
            }
            
            if let startDate = startDate {
                sqlite3_bind_text(statement, 5, startDate, Int32(startDate.utf8.count), SQLITE_TRANSIENT)
            } else {
                sqlite3_bind_null(statement, 5)
            }
            
            if let endDate = endDate {
                sqlite3_bind_text(statement, 6, endDate, Int32(endDate.utf8.count), SQLITE_TRANSIENT)
            } else {
                sqlite3_bind_null(statement, 6)
            }
            
            if let description = description {
                sqlite3_bind_text(statement, 7, description, Int32(description.utf8.count), SQLITE_TRANSIENT)
            } else {
                sqlite3_bind_null(statement, 7)
            }
            
            if sqlite3_step(statement) == SQLITE_DONE {
                sqlite3_finalize(statement)
                return true
            }
        }
        
        sqlite3_finalize(statement)
        return false
    }
    
    func getEducationByResumeId(_ resumeId: Int) -> [(id: Int, institution: String, degree: String?, fieldOfStudy: String?, startDate: String?, endDate: String?, description: String?)] {
        let querySQL = "SELECT id, institution, degree, field_of_study, start_date, end_date, description FROM education WHERE resume_id = ?"
        var statement: OpaquePointer?
        var education: [(id: Int, institution: String, degree: String?, fieldOfStudy: String?, startDate: String?, endDate: String?, description: String?)] = []
        
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(resumeId))
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let institution = String(cString: sqlite3_column_text(statement, 1))
                
                let degree = sqlite3_column_text(statement, 2) != nil ? String(cString: sqlite3_column_text(statement, 2)) : nil
                let fieldOfStudy = sqlite3_column_text(statement, 3) != nil ? String(cString: sqlite3_column_text(statement, 3)) : nil
                let startDate = sqlite3_column_text(statement, 4) != nil ? String(cString: sqlite3_column_text(statement, 4)) : nil
                let endDate = sqlite3_column_text(statement, 5) != nil ? String(cString: sqlite3_column_text(statement, 5)) : nil
                let description = sqlite3_column_text(statement, 6) != nil ? String(cString: sqlite3_column_text(statement, 6)) : nil
                
                education.append((id: id, institution: institution, degree: degree, fieldOfStudy: fieldOfStudy, startDate: startDate, endDate: endDate, description: description))
            }
        }
        
        sqlite3_finalize(statement)
        return education
    }
    
    // MARK: - Experience Operations
    func insertExperience(resumeId: Int, company: String, position: String, startDate: String? = nil, endDate: String? = nil, description: String? = nil, location: String? = nil) -> Bool {
        let insertSQL = "INSERT INTO experience (resume_id, company, position, start_date, end_date, description, location) VALUES (?, ?, ?, ?, ?, ?, ?)"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            sqlite3_bind_int(statement, 1, Int32(resumeId))
            sqlite3_bind_text(statement, 2, company, Int32(company.utf8.count), SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, position, Int32(position.utf8.count), SQLITE_TRANSIENT)
            
            if let startDate = startDate {
                sqlite3_bind_text(statement, 4, startDate, Int32(startDate.utf8.count), SQLITE_TRANSIENT)
            } else {
                sqlite3_bind_null(statement, 4)
            }
            
            if let endDate = endDate {
                sqlite3_bind_text(statement, 5, endDate, Int32(endDate.utf8.count), SQLITE_TRANSIENT)
            } else {
                sqlite3_bind_null(statement, 5)
            }
            
            if let description = description {
                sqlite3_bind_text(statement, 6, description, Int32(description.utf8.count), SQLITE_TRANSIENT)
            } else {
                sqlite3_bind_null(statement, 6)
            }
            
            if let location = location {
                sqlite3_bind_text(statement, 7, location, Int32(location.utf8.count), SQLITE_TRANSIENT)
            } else {
                sqlite3_bind_null(statement, 7)
            }
            
            if sqlite3_step(statement) == SQLITE_DONE {
                sqlite3_finalize(statement)
                return true
            }
        }
        
        sqlite3_finalize(statement)
        return false
    }
    
    func getExperienceByResumeId(_ resumeId: Int) -> [(id: Int, company: String, position: String, startDate: String?, endDate: String?, description: String?, location: String?)] {
        let querySQL = "SELECT id, company, position, start_date, end_date, description, location FROM experience WHERE resume_id = ?"
        var statement: OpaquePointer?
        var experience: [(id: Int, company: String, position: String, startDate: String?, endDate: String?, description: String?, location: String?)] = []
        
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(resumeId))
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let company = String(cString: sqlite3_column_text(statement, 1))
                let position = String(cString: sqlite3_column_text(statement, 2))
                
                let startDate = sqlite3_column_text(statement, 3) != nil ? String(cString: sqlite3_column_text(statement, 3)) : nil
                let endDate = sqlite3_column_text(statement, 4) != nil ? String(cString: sqlite3_column_text(statement, 4)) : nil
                let description = sqlite3_column_text(statement, 5) != nil ? String(cString: sqlite3_column_text(statement, 5)) : nil
                let location = sqlite3_column_text(statement, 6) != nil ? String(cString: sqlite3_column_text(statement, 6)) : nil
                
                experience.append((id: id, company: company, position: position, startDate: startDate, endDate: endDate, description: description, location: location))
            }
        }
        
        sqlite3_finalize(statement)
        return experience
    }
}
