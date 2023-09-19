//
//  AnimationManager.swift
//  JabVR
//
//  Created by Adam Zabloudil on 11/15/23.
//

import SwiftUI
import RealityKit
import RealityKitContent
import AVFoundation

class AnimationManager: ObservableObject {
    
    @ObservedObject var audioManager = AudioManager()
    
    var opponentEntity: Entity?
    
    private var keepSwaying = true

    func damageText(text: String) {
        guard let head = opponentEntity?.findEntity(named: "head") else { return }
        
        let textMeshResource: MeshResource = .generateText(text,
                                                           extrusionDepth: 0.1,
                                                           font: .systemFont(ofSize: 1),
                                                           containerFrame: .zero,
                                                           alignment: .center,
                                                           lineBreakMode: .byWordWrapping)
        
        let unlitmaterial = UnlitMaterial(color: UIColor(red: 195, green: 177, blue: 225, alpha: 1))
        let litmaterial = SimpleMaterial(color: .purple, isMetallic: false)

        let textEntity = ModelEntity(mesh: textMeshResource, materials: [unlitmaterial])
        textEntity.position = head.position + .init(x: Float(Double.random(in: -2.0...2.0)), y: 1, z: 0.5)
        textEntity.orientation = simd_quatf(angle: (Float(Double.random(in: -15.0...15.0)) * Float.pi / 180), axis: [0, 0, 1])

        opponentEntity?.addChild(textEntity)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
            opponentEntity?.removeChild(textEntity)
        }
        
    }
    
    func swayUpperBody() {
        guard let upperBody = opponentEntity?.findEntity(named: "upperBody"), keepSwaying else { return }

        let swayLeft = simd_quatf(angle: 2 * Float.pi / 180, axis: [0, 0, 1])
        let swayRight = simd_quatf(angle: -2 * Float.pi / 180, axis: [0, 0, 1])
        
        let swayLeft2 = simd_quatf(angle: Float.random(in: 0...5.0) * Float.pi / 180, axis: [0, 0, 1])
        let swayRight2 = simd_quatf(angle: Float.random(in: -5.0...0) * Float.pi / 180, axis: [0, 0, 1])

        let swayDuration: TimeInterval = 1.0

        let swayToLeft = FromToByAnimation<Transform>(
            name: "swayToLeft",
            from: Transform(rotation: swayRight),
            to: Transform(rotation: swayLeft2),
            duration: swayDuration,
            timing: .easeInOut,
            bindTarget: .transform
        )
        let swayToRight = FromToByAnimation<Transform>(
            name: "swayToRight",
            from: Transform(rotation: swayLeft2),
            to: Transform(rotation: swayRight2),
            duration: swayDuration,
            timing: .easeInOut,
            bindTarget: .transform
        )
        let swayToLeft2 = FromToByAnimation<Transform>(
            name: "swayLeft2",
            from: Transform(rotation: swayRight2),
            to: Transform(rotation: swayLeft),
            duration: swayDuration,
            timing: .easeInOut,
            bindTarget: .transform
        )
        let swayToRight2 = FromToByAnimation<Transform>(
            name: "swayRight2",
            from: Transform(rotation: swayLeft),
            to: Transform(rotation: swayRight),
            duration: swayDuration,
            timing: .easeInOut,
            bindTarget: .transform
        )

        upperBody.playAnimation(try! AnimationResource.sequence(with: [try! AnimationResource.generate(with: swayToLeft), try! AnimationResource.generate(with: swayToRight), try! AnimationResource.generate(with: swayToLeft2), try! AnimationResource.generate(with: swayToRight2)]))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4 * swayDuration) { [weak self] in
            self?.swayUpperBody()
        }
    }
    
    func stopSwaying() {
        keepSwaying = false
    }

    func animateHeadForHit() {
        guard let head = opponentEntity?.findEntity(named: "head") else { return }

        let headTiltBack = FromToByAnimation<Transform>(
            name: "headTiltBack",
            from: Transform(scale: head.scale, rotation: simd_quatf(angle: 0 / 4, axis: [1, 0, 0]), translation: head.position),
            to: Transform(scale: head.scale, rotation: simd_quatf(angle: -.pi / 4, axis: [1, 0, 0]), translation: head.position),
            duration: 0.2,
            timing: .linear,
            bindTarget: .transform
        )

        let headReturn = FromToByAnimation<Transform>(
            name: "headReturn",
            from: Transform(scale: head.scale, rotation: simd_quatf(angle: -.pi / 4, axis: [1, 0, 0]), translation: head.position),
            to: Transform(scale: head.scale, rotation: simd_quatf(angle: 0 / 4, axis: [1, 0, 0]), translation: head.position),
            duration: 0.2,
            timing: .linear,
            bindTarget: .transform
        )

        let tiltBackAnimation = try! AnimationResource.generate(with: headTiltBack)
        let returnAnimation = try! AnimationResource.generate(with: headReturn)
        let sequence = try! AnimationResource.sequence(with: [tiltBackAnimation, returnAnimation])

        //head.components.set(ParticleEmitterComponent())
        head.components[ParticleEmitterComponent.self]?.burst()
        audioManager.playPunchSound()
        head.playAnimation(sequence, transitionDuration: 0.5)
    }

    
    func animateArmsForBlocking() {
        guard let rightArm = opponentEntity?.findEntity(named: "rightUpperArm"),
              let leftArm = opponentEntity?.findEntity(named: "leftUpperArm") else { return }

        let rightArmBlock = FromToByAnimation<Transform>(
            name: "rightArmBlock",
            from: Transform(scale: rightArm.scale, rotation: simd_quatf(angle: -40 * Float.pi / 180, axis: [0, 0, 1]) * simd_quatf(angle: -60 * Float.pi / 180, axis: [1, 0, 0]), translation: rightArm.position),
            to: Transform(scale: rightArm.scale, rotation: simd_quatf(angle: -20 * Float.pi / 180, axis: [0, 0, 1]) * simd_quatf(angle: 25 * Float.pi / 180, axis: [0, 1, 0]) * simd_quatf(angle: -90 * Float.pi / 180, axis: [1, 0, 0]), translation: rightArm.position),
            duration: 0.2,
            timing: .linear,
            bindTarget: .transform
        )
        let rightArmBlockReturn = FromToByAnimation<Transform>(
            name: "rightArmBlockReturn",
            from: Transform(scale: rightArm.scale, rotation: simd_quatf(angle: -20 * Float.pi / 180, axis: [0, 0, 1]) * simd_quatf(angle: 25 * Float.pi / 180, axis: [0, 1, 0]) * simd_quatf(angle: -90 * Float.pi / 180, axis: [1, 0, 0]), translation: rightArm.position),
            to: Transform(scale: rightArm.scale, rotation: simd_quatf(angle: -40 * Float.pi / 180, axis: [0, 0, 1]) * simd_quatf(angle: -60 * Float.pi / 180, axis: [1, 0, 0]), translation: rightArm.position),
            duration: 0.2,
            timing: .linear,
            bindTarget: .transform
        )
        
        let leftArmBlock = FromToByAnimation<Transform>(
            name: "leftArmBlock",
            from: Transform(scale: leftArm.scale, rotation: simd_quatf(angle: 40 * Float.pi / 180, axis: [0, 0, 1]) * simd_quatf(angle: -60 * Float.pi / 180, axis: [1, 0, 0]), translation: leftArm.position),
            to: Transform(scale: leftArm.scale, rotation: simd_quatf(angle: 20 * Float.pi / 180, axis: [0, 0, 1]) * simd_quatf(angle: -25 * Float.pi / 180, axis: [0, 1, 0]) * simd_quatf(angle: -90 * Float.pi / 180, axis: [1, 0, 0]), translation: leftArm.position),
            duration: 0.2,
            timing: .linear,
            bindTarget: .transform
        )
        let leftArmBlockReturn = FromToByAnimation<Transform>(
            name: "leftArmBlockReturn",
            from: Transform(scale: leftArm.scale, rotation: simd_quatf(angle: 20 * Float.pi / 180, axis: [0, 0, 1]) * simd_quatf(angle: -25 * Float.pi / 180, axis: [0, 1, 0]) * simd_quatf(angle: -90 * Float.pi / 180, axis: [1, 0, 0]), translation: leftArm.position),
            to: Transform(scale: leftArm.scale, rotation: simd_quatf(angle: 40 * Float.pi / 180, axis: [0, 0, 1]) * simd_quatf(angle: -60 * Float.pi / 180, axis: [1, 0, 0]), translation: leftArm.position),
            duration: 0.2,
            timing: .linear,
            bindTarget: .transform
        )

        rightArm.playAnimation(try! AnimationResource.sequence(with: [try! AnimationResource.generate(with: rightArmBlock), try! AnimationResource.generate(with: rightArmBlockReturn)]), transitionDuration: 0.5)
        leftArm.playAnimation(try! AnimationResource.sequence(with: [try! AnimationResource.generate(with: leftArmBlock), try! AnimationResource.generate(with: leftArmBlockReturn)]), transitionDuration: 0.5)
    }
    
    func animateDodge() {
        guard let opponentBody = opponentEntity else { return }
            
        let dodgeMove = FromToByAnimation<Transform>(
            name: "dodgeMove",
            from: .init(scale: opponentBody.scale, rotation: opponentBody.orientation, translation: .init(x: 0.0, y: 0.0, z: -1.8)),
            to: .init(scale: opponentBody.scale, rotation: opponentBody.orientation, translation: opponentBody.position + .init(x: 0.5, y: 0.0, z: 0.0)),
            duration: 0.2,
            timing: .linear,
            bindTarget: .transform
        )

        let dodgeReturn = FromToByAnimation<Transform>(
            name: "dodgeReturn",
            from: .init(scale: opponentBody.scale, rotation: opponentBody.orientation, translation: opponentBody.position + .init(x: 0.5, y: 0.0, z: 0.0)),
            to: .init(scale: opponentBody.scale, rotation: opponentBody.orientation, translation: .init(x: 0.0, y: 0.0, z: -1.8)),
            duration: 0.2,
            timing: .linear,
            bindTarget: .transform
        )
        
        print("TRANSLATION")
        print(opponentBody.transform.translation)
        
        print("POSITION")
        print(opponentBody.position)
        
        print("TRANSFORM")
        print(opponentBody.transform)

        let dodgeAnimation = try! AnimationResource.sequence(with: [try! AnimationResource.generate(with: dodgeMove), try! AnimationResource.generate(with: dodgeReturn)])
        opponentBody.playAnimation(dodgeAnimation, transitionDuration: 0.5)
    }
    
    func animateLeftPunch() {
        guard let leftUpperArm = opponentEntity?.findEntity(named: "leftUpperArm"),
              let leftForearm = leftUpperArm.findEntity(named: "leftForearm") else { return }

        let upperArmAnimation = FromToByAnimation<Transform>(
            name: "leftUpperArmPunch",
            from: Transform(scale: leftUpperArm.scale, rotation: simd_quatf(angle: 40 * Float.pi / 180, axis: [0, 0, 1]) * simd_quatf(angle: -60 * Float.pi / 180, axis: [1, 0, 0]), translation: leftUpperArm.position),
            to: Transform(scale: leftUpperArm.scale, rotation: simd_quatf(angle: 40 * Float.pi / 180, axis: [0, 0, 1]) * simd_quatf(angle: -90 * Float.pi / 180, axis: [1, 0, 0]), translation: leftUpperArm.position),
            duration: 0.2,
            timing: .linear,
            bindTarget: .transform
        )
        
        let upperArmReturnAnimation = FromToByAnimation<Transform>(
            name: "leftUpperArmReturn",
            from: Transform(scale: leftUpperArm.scale, rotation: simd_quatf(angle: 40 * Float.pi / 180, axis: [0, 0, 1]) * simd_quatf(angle: -90 * Float.pi / 180, axis: [1, 0, 0]), translation: leftUpperArm.position),
            to: Transform(scale: leftUpperArm.scale, rotation: simd_quatf(angle: 40 * Float.pi / 180, axis: [0, 0, 1]) * simd_quatf(angle: -60 * Float.pi / 180, axis: [1, 0, 0]), translation: leftUpperArm.position),
            duration: 0.2,
            timing: .linear,
            bindTarget: .transform
        )

        let forearmAnimation = FromToByAnimation<Transform>(
            name: "leftForearmPunch",
            from: Transform(scale: leftForearm.scale, rotation: simd_quatf(angle: -100 * Float.pi / 180, axis: [1, 0, 0]), translation: .init(x: 0.0, y: -0.2, z: 0.1)),
            to: Transform(scale: leftForearm.scale, rotation: simd_quatf(angle: Float.pi / 180, axis: [1, 0, 0]), translation: .init(x: 0.0, y: -0.35, z: 0.1)),
            duration: 0.2,
            timing: .linear,
            bindTarget: .transform
        )

        let forearmReturnAnimation = FromToByAnimation<Transform>(
            name: "leftForearmReturn",
            from: Transform(scale: leftForearm.scale, rotation: simd_quatf(angle: Float.pi / 180, axis: [1, 0, 0]), translation: .init(x: 0.0, y: -0.35, z: 0.1)),
            to: Transform(scale: leftForearm.scale, rotation: simd_quatf(angle: -100 * Float.pi / 180, axis: [1, 0, 0]), translation: .init(x: 0.0, y: -0.2, z: 0.1)),
            duration: 0.2,
            timing: .linear,
            bindTarget: .transform
        )

        let upperArmSequence = try! AnimationResource.sequence(with: [
            try! AnimationResource.generate(with: upperArmAnimation),
            try! AnimationResource.generate(with: upperArmReturnAnimation)
        ])
        leftUpperArm.playAnimation(upperArmSequence, transitionDuration: 0.5)

        let forearmSequence = try! AnimationResource.sequence(with: [
            try! AnimationResource.generate(with: forearmAnimation),
            try! AnimationResource.generate(with: forearmReturnAnimation)
        ])
        leftForearm.playAnimation(forearmSequence, transitionDuration: 0.5)
    }
    
    func animateRightPunch() {
        guard let rightUpperArm = opponentEntity?.findEntity(named: "rightUpperArm"),
              let rightForearm = rightUpperArm.findEntity(named: "rightForearm") else { return }

        let upperArmAnimation = FromToByAnimation<Transform>(
            name: "rightUpperArmPunch",
            from: Transform(scale: rightUpperArm.scale, rotation: simd_quatf(angle: -40 * Float.pi / 180, axis: [0, 0, 1]) * simd_quatf(angle: -60 * Float.pi / 180, axis: [1, 0, 0]), translation: rightUpperArm.position),
            to: Transform(scale: rightUpperArm.scale, rotation: simd_quatf(angle: -40 * Float.pi / 180, axis: [0, 0, 1]) * simd_quatf(angle: -90 * Float.pi / 180, axis: [1, 0, 0]), translation: rightUpperArm.position),
            duration: 0.2,
            timing: .linear,
            bindTarget: .transform
        )
        
        let upperArmReturnAnimation = FromToByAnimation<Transform>(
            name: "rightUpperArmReturn",
            from: Transform(scale: rightUpperArm.scale, rotation: simd_quatf(angle: -40 * Float.pi / 180, axis: [0, 0, 1]) * simd_quatf(angle: -90 * Float.pi / 180, axis: [1, 0, 0]), translation: rightUpperArm.position),
            to: Transform(scale: rightUpperArm.scale, rotation: simd_quatf(angle: -40 * Float.pi / 180, axis: [0, 0, 1]) * simd_quatf(angle: -60 * Float.pi / 180, axis: [1, 0, 0]), translation: rightUpperArm.position),
            duration: 0.2,
            timing: .linear,
            bindTarget: .transform
        )

        let forearmAnimation = FromToByAnimation<Transform>(
            name: "rightForearmPunch",
            from: Transform(scale: rightForearm.scale, rotation: simd_quatf(angle: -100 * Float.pi / 180, axis: [1, 0, 0]), translation: .init(x: 0.0, y: -0.2, z: 0.1)),
            to: Transform(scale: rightForearm.scale, rotation: simd_quatf(angle: Float.pi / 180, axis: [1, 0, 0]), translation: .init(x: 0.0, y: -0.35, z: 0.1)),
            duration: 0.2,
            timing: .linear,
            bindTarget: .transform
        )

        let forearmReturnAnimation = FromToByAnimation<Transform>(
            name: "rightForearmReturn",
            from: Transform(scale: rightForearm.scale, rotation: simd_quatf(angle: Float.pi / 180, axis: [1, 0, 0]), translation: .init(x: 0.0, y: -0.35, z: 0.1)),
            to: Transform(scale: rightForearm.scale, rotation: simd_quatf(angle: -100 * Float.pi / 180, axis: [1, 0, 0]), translation: .init(x: 0.0, y: -0.2, z: 0.1)),
            duration: 0.2,
            timing: .linear,
            bindTarget: .transform
        )

        let upperArmSequence = try! AnimationResource.sequence(with: [
            try! AnimationResource.generate(with: upperArmAnimation),
            try! AnimationResource.generate(with: upperArmReturnAnimation)
        ])
        rightUpperArm.playAnimation(upperArmSequence, transitionDuration: 0.5)

        let forearmSequence = try! AnimationResource.sequence(with: [
            try! AnimationResource.generate(with: forearmAnimation),
            try! AnimationResource.generate(with: forearmReturnAnimation)
        ])
        rightForearm.playAnimation(forearmSequence, transitionDuration: 0.5)
    }

}
