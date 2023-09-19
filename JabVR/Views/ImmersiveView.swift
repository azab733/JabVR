//
//  ImmersiveView.swift
//  JabVR
//
//  Created by Adam Zabloudil on 9/18/23.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine

struct ImmersiveView: View {
    @Environment(\.openWindow)  var openWindow
    @Environment(\.dismissWindow)  var dismissWindow
    @Environment(\.dismissImmersiveSpace)  var dismissImmersiveSpace
    
    @EnvironmentObject var gameSettings: GameSettings
    
    @ObservedObject var animationManager = AnimationManager()
    @ObservedObject var audioManager = AudioManager()
    
    let opponentAttatchment = "opponentAttatchment"
    let bagAttatchment = "bagAttatchment"
    let bagMenuAttatchment = "bagMenuAttatchment"
    let gameOverAttatchment = "gameOverAttatchment"
    let flashAttatchment = "flashAttatchment"
    
    @State var currentDifficulty: Difficulty = .medium
    
    @State var opponentHealthPercentage = 1.00
    @State var userHealthPercentage = 1.00
    @State var opponentHits = 0
    let maxOpponentHealth: Double = 100
    let maxUserHealth: Double = 100
    @State var userHits = 0
    @State var wonGame = false
    @State var gameOver = false
    
    @State private var showFlash = false
    
    @State var punchTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var characterPosition = {
        let headAnchor = AnchorEntity(.head)
        headAnchor.position = SIMD3<Float>(0, -1.7, 0)
        return headAnchor
    }()
    
    @State var headPosition = {
        let headAnchor = AnchorEntity(.head)
        headAnchor.position = SIMD3<Float>(0, 0, -0.1)
        return headAnchor
    }()

    var body: some View {

        RealityView { content, attachments in
            
            if let immersiveContentEntity = try? await Entity(named: "homeScene", in: realityKitContentBundle) {
                immersiveContentEntity.components.set(InputTargetComponent())
                immersiveContentEntity.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.1)]))
                characterPosition.addChild(immersiveContentEntity)
                content.add(characterPosition)
                content.add(headPosition)
                
                if let opponent = immersiveContentEntity.findEntity(named: "newOpponent") {
                    self.animationManager.opponentEntity = opponent
                }
            }
            
            if let sceneAttachment = attachments.entity(for: flashAttatchment) {
                headPosition.addChild(sceneAttachment)
                content.add(headPosition)
            }
            
            self.audioManager.playBellSound()
            self.animationManager.swayUpperBody()
             
        } update: { content, attachments in
            
            if opponentHealthPercentage <= 0 || userHealthPercentage <= 0 {
                
                if let sceneAttachment = attachments.entity(for: gameOverAttatchment) {
                    sceneAttachment.position = SIMD3<Float>(0, 1.5, -0.7)
                    content.add(sceneAttachment)
                }
                
                if let sceneAttachment = attachments.entity(for: opponentAttatchment) {
                    content.remove(sceneAttachment)
                }
                if let sceneAttachment = attachments.entity(for: bagMenuAttatchment) {
                    content.remove(sceneAttachment)
                }
                
                if let model = content.entities.first {
                    model.findEntity(named: "newOpponent")?.removeFromParent()
                }
                
            } else {
                if let model = content.entities.first {
                    if let sceneAttachment = attachments.entity(for: opponentAttatchment) {
                        model.findEntity(named: "newOpponent")?.addChild(sceneAttachment)
                        sceneAttachment.position = SIMD3<Float>(0.0, 9, -1.0)
                        sceneAttachment.setScale(.init(x: 3, y: 3, z: 3), relativeTo: nil)
                    }
                }
                
                if let sceneAttachment = attachments.entity(for: bagMenuAttatchment) {
                    sceneAttachment.position = SIMD3<Float>(-0.7, 1.5, -1.0)
                    content.add(sceneAttachment)
                }
                
            }
             
        } placeholder: {
            ProgressView()
                .progressViewStyle(.circular)
                .controlSize(.large)
        } attachments: {
            Attachment(id: flashAttatchment) {
                Color.white
                    .opacity(showFlash ? 1 : 0)
                    .edgesIgnoringSafeArea(.all)
                    .animation(.easeOut(duration: 0.1), value: showFlash)
            }
            
            Attachment(id: opponentAttatchment) {
                VStack {
                    Text("Opponent Health").font(.headline)
                    ProgressView(value: opponentHealthPercentage).tint(.purple)
                        .frame(width: 400)
                }
                .padding()
                .glassBackgroundEffect()
            }
            
            Attachment(id: bagMenuAttatchment) {
                BagMenuView(userHealth: $userHealthPercentage, userHits: $userHits)
            }
            
            Attachment(id: gameOverAttatchment) {
                VStack {
                    
                    Text("You \(wonGame ? "Lost" : "Won")")
                        .font(.title2)
                    
                    Spacer().frame(height:50)
                    
                    HStack {
                        VStack {
                            Text("Your Hits")
                                .font(.headline)
                            Text("\(userHits)")
                                .font(.largeTitle)
                        }
                        
                        Spacer().frame(width:20)
                        
                        VStack {
                            Text("Opponent Hits")
                                .font(.headline)
                            Text("\(opponentHits)")
                                .font(.largeTitle)
                        }
                    }
                    
                    Spacer().frame(height:50)
                    
                    Button("Exit") {
                        Task {
                            await dismissImmersiveSpace()
                            openWindow(id: "contentView")
                        }
                    }
                }
                .padding(50)
                .glassBackgroundEffect()
            }
        }
        .preferredSurroundingsEffect(.systemDark)
        .onReceive(punchTimer) { _ in
            if opponentHealthPercentage > 0 && userHealthPercentage > 0 {
                if shouldThrowPunch(for: gameSettings.difficulty) {
                    if Bool.random() == true {
                        triggerHitFlash()
                        self.animationManager.animateLeftPunch()
                        let damage = randomDamage()
                        opponentHits += 1
                        reduceUserHealth(by: damage)
                        self.audioManager.playPunchSound()
                    } else {
                        triggerHitFlash()
                        self.animationManager.animateRightPunch()
                        let damage = randomDamage()
                        opponentHits += 1
                        reduceUserHealth(by: damage)
                        self.audioManager.playPunchSound()
                    }
                }
            }
        }
        .gesture(TapGesture().targetedToAnyEntity().onEnded { _ in
            let action = selectDefensiveAction(for: gameSettings.difficulty)

            switch action {
            case "Dodge":
                self.animationManager.animateDodge()
            case "Block":
                self.animationManager.animateArmsForBlocking()
            case "Get Hit":
                self.animationManager.animateHeadForHit()
                let damage = randomDamage()
                userHits += 1
                reduceOpponentHealth(by: damage)
                self.animationManager.damageText(text: String(damage))
            default:
                break
            }
        })
         
    }
    
    func shouldDodge() -> Bool {
        return Bool.random()
    }

    func shouldBlock() -> Bool {
        return Bool.random()
    }
    
    func randomDamage() -> Int {
        return Int.random(in: 5...30)
    }

    func reduceOpponentHealth(by damage: Int) {
        let healthDecrease = Double(damage) / maxOpponentHealth
        opponentHealthPercentage -= healthDecrease
        opponentHealthPercentage = max(0, opponentHealthPercentage)
    }
    
    func reduceUserHealth(by damage: Int) {
        let healthDecrease = Double(damage) / maxUserHealth
        userHealthPercentage -= healthDecrease
        userHealthPercentage = max(0, userHealthPercentage)
    }
    
    func triggerHitFlash() {
        withAnimation {
            showFlash = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showFlash = false
            }
        }
    }
    
    func selectDefensiveAction(for difficulty: Difficulty) -> String {
        let randomValue = Double.random(in: 0...1)
        switch difficulty {
        case .easy:
            return randomValue < 0.7 ? "Get Hit" : "Block"
        case .medium:
            return randomValue < 0.4 ? "Get Hit" : "Block"
        case .hard:
            return randomValue < 0.2 ? "Get Hit" : "Block"
        }
    }

    func shouldThrowPunch(for difficulty: Difficulty) -> Bool {
        let randomValue = Double.random(in: 0...1)
        switch difficulty {
        case .easy:
            return randomValue < 0.1
        case .medium:
            return randomValue < 0.3
        case .hard:
            return randomValue < 0.5
        }
    }
    
}


#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}



