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
    @Published private(set) var currentSession: CheckInSession?
    
    /// Used to check the user into a room.
    /// Note that this should persist if the user quits the app while checked in
    /// This should never be called when `isCheckedIn` is true
    func checkIn(to room: Room) {
        // TODO: Implement this
        isCheckedIn = true
        currentSession = CheckInSession(checkedIn: Date(), checkedOut: nil, target: room)
    }
    
    /// Used to check the user out from the room they are currently checked into
    /// This should use the persisted data (if any) from the `checkIn()` static method
    /// This should never be called when `isCheckedIn` is false
    func checkOut() {
        isCheckedIn = false
        currentSession?.checkedOut = Date()
        // TODO: Save current session to CoreData
        currentSession = nil
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
}
