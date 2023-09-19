//
//  ContentView.swift
//  JabVR
//
//  Created by Adam Zabloudil on 9/18/23.
//

import SwiftUI
import RealityKit
import RealityKitContent

class GameSettings: ObservableObject {
    @Published var difficulty: Difficulty = .medium
}

struct ContentView: View {

    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    let difficulty = ["Easy", "Medium", "Hard"]
    
    @State private var rotation: Double = 0

    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    @StateObject var gameSettings = GameSettings()
    @State private var selectedOption = 1
    
    @State private var countdownValue = 5
    @State private var showCountdown = false
    
    @State private var showHowToPlay = false
    @State private var showRankings = false
    
    private func startCountdown() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.countdownValue > 1 {
                self.countdownValue -= 1
                self.startCountdown()
            } else {
                self.showImmersiveSpace = false
                Task {
                    switch await openImmersiveSpace(id: "ImmersiveSpace") {
                    case .opened:
                        immersiveSpaceIsShown = true
                        dismissWindow(id: "contentView")
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        immersiveSpaceIsShown = false
                        showImmersiveSpace = false
                    }
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            if showCountdown {
                Text("Fight starting in \(countdownValue)...")
                    .font(.largeTitle)
                    .preferredSurroundingsEffect(.systemDark)
            } else {
                VStack {
                    
                    HStack {
                        Model3D(named: "purpleGlove", bundle: realityKitContentBundle)
                            .scaleEffect(x: 0.3, y: 0.3, z: 0.3)
                            .frame(width: 50, height: 50)
                            .rotation3DEffect(Angle(degrees: rotation), axis: (x: -1, y: 1, z: 0))
                        
                        Spacer().frame(width: 70)
                        
                        Text("Jab VR").font(.title).padding()
                        
                        Spacer().frame(width: 70)
                        
                        Model3D(named: "purpleGlove2", bundle: realityKitContentBundle)
                            .scaleEffect(x: 0.3, y: 0.3, z: 0.3)
                            .frame(width: 50, height: 50)
                            .rotation3DEffect(Angle(degrees: rotation), axis: (x: 1, y: 1, z: 0))
                    }
                    .onReceive(timer) { _ in
                        rotation += 2
                        if rotation >= 360 {
                            rotation = 0
                        }
                    }
                    
                    Toggle("Start Game", isOn: $showImmersiveSpace)
                        .toggleStyle(.button)
                        .padding(.top, 50)
                        .hoverEffect()
                    
                    Spacer().frame(height:40)
                    
                    Text("Difficulty")
                    
                    Picker("Difficulty", selection: $selectedOption) {
                        Text("Easy").tag(0)
                        Text("Medium").tag(1)
                        Text("Hard").tag(2)
                    }
                    .onChange(of: selectedOption) { newValue in
                        switch newValue {
                        case 0:
                            gameSettings.difficulty = .easy
                        case 1:
                            gameSettings.difficulty = .medium
                        case 2:
                            gameSettings.difficulty = .hard
                        default:
                            gameSettings.difficulty = .medium
                        }
                    }
                    
                    Spacer().frame(height:20)
                    
                    HStack {
                        VStack {
                            Button {
                                
                            } label: {
                                Text("Training").frame(width: 150)
                            }
                            
    //                        Button {
    //                            showRankings = true
    //                        } label: {
    //                            Text("Rankings").frame(width: 150)
    //                                .hoverEffect()
    //                        }
    //                        .sheet(isPresented: $showRankings) {
    //                            RankingsView()
    //                        }
                            
                            NavigationLink(destination: RankingsView()) {
                                Text("Rankings").frame(width: 150)
                            }
                            
                        }
                        VStack {
    //                        Button {
    //                            showHowToPlay = true
    //                        } label: {
    //                            Text("How To Play").frame(width: 150)
    //                                .hoverEffect()
    //                        }
    //                        .sheet(isPresented: $showHowToPlay) {
    //                            HowToPlayView()
    //                        }
                            
                            NavigationLink(destination: HowToPlayView()) {
                                Text("How To Play").frame(width: 150)
                            }
                            
                            
                            Button {
                                
                            } label: {
                                Text("Settings").frame(width: 150)
                            }
                        }
                    }
                    
    //                if showCountdown {
    //                    CountdownView(countdownValue: $countdownValue) {
    //                        Task {
    //                            switch await openImmersiveSpace(id: "ImmersiveSpace") {
    //                            case .opened:
    //                                immersiveSpaceIsShown = true
    //                                dismissWindow(id: "contentView")
    //                            case .error, .userCancelled:
    //                                fallthrough
    //                            @unknown default:
    //                                immersiveSpaceIsShown = false
    //                                showImmersiveSpace = false
    //                            }
    //                        }
    //                    }
    //                }
                    
                }
            }
            
        }
        .frame(width:800, height:650)
        .glassBackgroundEffect()
        .onChange(of: showImmersiveSpace) { newValue in
            if newValue {
                self.countdownValue = 5
                self.showCountdown = true
                self.startCountdown()
            }
        }
        
    }
    
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
