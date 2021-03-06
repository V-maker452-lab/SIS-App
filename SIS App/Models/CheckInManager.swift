//
//  CheckInManager.swift
//  SIS App
//
//  Created by Wang Yunze on 7/11/20.
//

import Foundation

class CheckInManager: ObservableObject {
    /// Used to check if the user is currently checked in or not
    /// This should check the persisted data (if any) from the `checkIn()` static method
    @Published private(set) var isCheckedIn = false

    /// This should control if the UI should show the check in screen or not, for better control over the UI
    /// This prevents the UI immediately changing to show something different when `checkIn()` or `checkOut()` is called
    @Published var showCheckedInScreen = false
    
    /// The current check in session. This is nil when the user isn't checked in
    @Published private(set) var currentSession: CheckInSession?
    
    static let currentSessionFilename = "currentSession.json"
    static let currentSessionFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(CheckInManager.currentSessionFilename)
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBlock), name: .didEnterBlock, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didExitBlock), name: .didExitBlock, object: nil)
        
        // TODO: Restore check in state here
        
        
        // ------- [[ RESTORE CHECK IN STATE ]] ----------- //
        // 1. Check if file exisists
        print("📂 document's directory: \(CheckInManager.currentSessionFile.path)")
        if FileManager.default.fileExists(atPath: CheckInManager.currentSessionFile.path) {
            print("📂✅ file exisists :)")
            
            // 2. Get file contents
            var fileContents = ""
            do {
                fileContents = try String(contentsOf: CheckInManager.currentSessionFile)
            } catch {
                print("❌ could not read string from file 0_o: \(error)")
                return
            }
            
            // 3. De-serialize json
            do {
                currentSession = try JSONDecoder().decode(CheckInSession.self, from: fileContents.data(using: .utf8)!)
            } catch {
                print("❌ could not de-serialize json ☹️: \(error)")
                return
            }
            
            // 4. Update variables
            isCheckedIn = true
            showCheckedInScreen = true
            
            // 5. Delete file
            deleteCurrentSessionFile()
        }
    }
    
    
    /// Used to check the user into a room.
    /// Note that this should persist if the user quits the app while checked in
    /// This should never be called when `isCheckedIn` is true
    func checkIn(to room: CheckInTarget, shouldUpdateUI: Bool = true) {
        if isCheckedIn == true { return }
        
        // ------- [[ UPDATE STATE ]] -------- //
        isCheckedIn = true
        if shouldUpdateUI { showCheckedInScreen = true }
        currentSession = CheckInSession(checkedIn: Date(), checkedOut: nil, target: room)
        
        // ------- [[ SAVE CURRENT SESSION TO FILE ]] ------ //
        
        // 1. Serialise current session into json
        var toWrite: Data!
        do {
            toWrite = try JSONEncoder().encode(currentSession!)
        } catch {
            print("❌ error serializing current session to json \(error)")
            return
        }
        
        // 2. Write that json to file
        do {
            try toWrite.write(to: CheckInManager.currentSessionFile)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            print("❌ oops, failed to write current session to file ☹️ \(error)")
            return
        }
    }
    
    /// Used to check the user out from the room they are currently checked into
    /// This should use the persisted data (if any) from the `checkIn()` static method
    /// This should never be called when `isCheckedIn` is false
    func checkOut(shouldUpdateUI: Bool = true) {
        
        // ------- [[ SET STATE ]] -------- //
        isCheckedIn = false
        if shouldUpdateUI { showCheckedInScreen = false }
        currentSession?.checkedOut = Date()
        
        // TODO: Save current session to CoreData
        
        currentSession = nil
        
        deleteCurrentSessionFile()
        
        objectWillChange.send()
    }
    
    /// This should use the session's UUID to figure out which session to change,
    /// then update that session based on the other properties of the passed session
    func updateCheckInSession(_ session: CheckInSession) {
        // TODO: Implement this
    }
    
    /// This should get the user's history from CoreData
    /// The `CheckInSession`s should be sorted by date
    func getCheckInSessions() -> [Day] {
        // TODO: Implemenet this
        // For now, return dummy data
        return [
            Day(
                date: Date(timeIntervalSince1970: 1604840241),
                sessions: [
                    CheckInSession(
                        checkedIn: Date(timeIntervalSince1970: 1604840241),
                        checkedOut: Date(timeIntervalSince1970: 1604840241+3600),
                        target: Room(name: "Class 1A", level: 1, id: "C1-17")
                    ),
                    CheckInSession(
                        checkedIn: Date(timeIntervalSince1970: 1604840882),
                        checkedOut: Date(timeIntervalSince1970: 1604840882+3600),
                        target: Room(name: "Computer Lab 3", level: 2, id: "J2-6")
                    ),
                    CheckInSession(
                        checkedIn: Date(timeIntervalSince1970: 1604841082),
                        checkedOut: Date(timeIntervalSince1970: 1604841082+3600),
                        target: Block(name: "Raja Block", location: Location(longitude: 1, latitude: 1), radius: 1)
                    ),
                ]
            ),
            Day(
                date: Date(timeIntervalSince1970: 1604922272),
                sessions: [
                    CheckInSession(
                        checkedIn: Date(timeIntervalSince1970: 1604922272),
                        checkedOut: Date(timeIntervalSince1970: 1604922272+3600),
                        target: Room(name: "Class 1A", level: 1, id: "C1-17")
                    ),
                    CheckInSession(
                        checkedIn: Date(timeIntervalSince1970: 1604925272),
                        checkedOut: Date(timeIntervalSince1970: 1604925272+3600),
                        target: Room(name: "Computer Lab 3", level: 2, id: "J2-6")
                    )
                ]
            )
        ]
    }
    
    
    /// This is the method that will be called when user enters a block
    /// This is supposed to automatically check the user into a block for them to edit later
    /// TODO: Don't always automatically check in, perhaps like wait a minute to see if the user already checks in manually
    @objc func didEnterBlock(_ notification: Notification) {
        if isCheckedIn { return }
        let block = notification.userInfo?["block"] as! Block
        print("automatically checking in to \(block.name)")
        checkIn(to: block)
    }
    
    
    /// This is the method that will be called when user exits a block
    /// This is supposed to automatically check the user out of a block for them to edit later
    /// TODO: Don't always automatically check out, perhaps like wait a minute to see if the user already manually
    @objc func didExitBlock(_ notification: Notification) {
        if !isCheckedIn { return }
        print("automatically checking out")
        checkOut()
    }
    
    // MARK: Helper Methods
    private func deleteCurrentSessionFile() {
        do {
            try FileManager.default.removeItem(at: CheckInManager.currentSessionFile)
        } catch {
            print("❌ could not delete file ☹️: \(error)")
            return
        }
    }
}
