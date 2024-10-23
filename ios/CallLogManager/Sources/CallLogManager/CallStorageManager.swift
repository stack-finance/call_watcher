import Foundation
import SQLite3

class CallStorageManager {
    private var db: OpaquePointer?
    private let dbPath: String
    
    init() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("CallLogs.sqlite")
        
        dbPath = fileURL.path
        
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            createTable()
        } else {
            print("Error opening database")
        }
    }
    
    deinit {
        sqlite3_close(db)
    }
    
    private func createTable() {
        let createTableString = """
            CREATE TABLE IF NOT EXISTS call_logs(
                id TEXT PRIMARY KEY,
                number TEXT,
                contact_name TEXT,
                date TEXT,
                duration INTEGER,
                is_outgoing INTEGER
            );
        """
        
        var createTableStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Call logs table created successfully")
            } else {
                print("Failed to create call logs table")
            }
        } else {
            print("Failed to prepare create table statement")
        }
        
        sqlite3_finalize(createTableStatement)
    }
    
    // MARK: - CRUD Operations
    
    func save(_ callLog: CallLogEntry) -> Bool {
        let insertString = """
            INSERT OR REPLACE INTO call_logs (id, number, contact_name, date, duration, is_outgoing)
            VALUES (?, ?, ?, ?, ?, ?);
        """
        
        var insertStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, callLog.id.uuidString, -1, nil)
            sqlite3_bind_text(insertStatement, 2, callLog.number, -1, nil)
            sqlite3_bind_text(insertStatement, 3, callLog.contactName ?? "", -1, nil)
            sqlite3_bind_text(insertStatement, 4, callLog.date.iso8601, -1, nil)
            sqlite3_bind_int(insertStatement, 5, Int32(callLog.duration.rounded()))
            sqlite3_bind_int(insertStatement, 6, callLog.isOutgoing ? 1 : 0)
            
            let result = sqlite3_step(insertStatement) == SQLITE_DONE
            sqlite3_finalize(insertStatement)
            return result
        }
        
        return false
    }
    
    func getCallLog(byId id: UUID) -> CallLogEntry? {
        let queryString = "SELECT * FROM call_logs WHERE id = ?;"
        var queryStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, id.uuidString, -1, nil)
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                let callLog = extractCallLogFromStatement(queryStatement)
                sqlite3_finalize(queryStatement)
                return callLog
            }
        }
        
        sqlite3_finalize(queryStatement)
        return nil
    }
    
    func getAllCallLogs() -> [CallLogEntry] {
        let queryString = "SELECT * FROM call_logs ORDER BY date DESC;"
        var queryStatement: OpaquePointer?
        var callLogs: [CallLogEntry] = []
        
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                if let callLog = extractCallLogFromStatement(queryStatement) {
                    callLogs.append(callLog)
                }
            }
        }
        
        sqlite3_finalize(queryStatement)
        return callLogs
    }
    
    func deleteCallLog(byId id: UUID) -> Bool {
        let deleteString = "DELETE FROM call_logs WHERE id = ?;"
        var deleteStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteString, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(deleteStatement, 1, id.uuidString, -1, nil)
            
            let result = sqlite3_step(deleteStatement) == SQLITE_DONE
            sqlite3_finalize(deleteStatement)
            return result
        }
        
        return false
    }
    
    func clear() -> Bool {
        
        let deleteString = "DELETE FROM call_logs;"
        var deleteStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteString, -1, &deleteStatement, nil) == SQLITE_OK {
            let result = sqlite3_step(deleteStatement) == SQLITE_DONE
            
            return result;
        }
        
        return false
    }
    
    // MARK: - Helper Methods
    
    private func extractCallLogFromStatement(_ statement: OpaquePointer?) -> CallLogEntry? {
        guard let idString = sqlite3_column_text(statement, 0).map({ String(cString: $0) }),
              let id = UUID(uuidString: idString),
              let numberText = sqlite3_column_text(statement, 1).map({ String(cString: $0) }),
              let dateText = sqlite3_column_text(statement, 3).map({ String(cString: $0) }),
              let date = ISO8601DateFormatter().date(from: dateText) else {
            return nil
        }
        
        let contactName = sqlite3_column_text(statement, 2).map { String(cString: $0) }
        let duration = TimeInterval(sqlite3_column_int(statement, 4))
        let isOutgoing = sqlite3_column_int(statement, 5) != 0
        
        return CallLogEntry(
            id: id,
            number: numberText,
            contactName: contactName?.isEmpty == true ? nil : contactName,
            date: date,
            duration: duration,
            isOutgoing: isOutgoing
        )
    }
}
