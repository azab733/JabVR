//
//  JabVRApp.swift
//  JabVR
//
//  Created by Adam Zabloudil on 9/18/23.
//

import SwiftUI
import RealityKit

@main
struct JabVRApp: App {
    @State private var immersionState: ImmersionStyle = .mixed
    @StateObject var gameSettings = GameSettings()
    
    var body: some SwiftUI.Scene {
        WindowGroup("contentView", id: "contentView") {
            ContentView().environmentObject(gameSettings)
        }.windowStyle(.plain)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView().environmentObject(gameSettings)
        }.immersionStyle(selection: $immersionState, in: .mixed)
    }
}
