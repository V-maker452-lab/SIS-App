//
//  ContentView.swift
//  SIS App
//
//  Created by Wang Yunze on 8/11/20.
//

import SwiftUI
import NotificationCenter

struct ContentView: View {
    @EnvironmentObject var checkInManager: CheckInManager
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            HistoryView()
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("History")
                }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didEnterBlock)) { event in
            let block = (event.userInfo?["block"] as! Block)
            
            print("received did enter geofence: \(block.name)")
            
            if !checkInManager.isCheckedIn {
                UserNotificationHelper.sendNotification(
                    title: "Remember to check in!",
                    subtitle: "Please check in to \(block.name)"
                )
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didExitBlock)) { event in
            let block = (event.userInfo?["block"] as! Block)
            
            print("received did exit geofence \(block.name )")
            
            if checkInManager.isCheckedIn {
                UserNotificationHelper.sendNotification(
                    title: "Remember to check out!",
                    subtitle: "Please check out of \(block.name)"
                )
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didEnterSchool)) { _ in
            UserNotificationHelper.sendNotification(
                title: "Remember to check in!",
                subtitle: "Please check into the school via safe entry"
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .didExitSchool)) { _ in
            UserNotificationHelper.sendNotification(
                title: "Remember to check out!",
                subtitle: "Please check out of the school via safe entry"
             )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let checkInManager = CheckInManager()
        checkInManager.checkIn(to: Room(name: "Class 1A", level: 1, id: "C1-17"))
        
        return ContentView()
            .environmentObject(checkInManager)
    }
}
