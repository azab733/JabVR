//
//  GestureManager.swift
//  JabVR
//
//  Created by Adam Zabloudil on 11/25/23.
//

import ARKit
import SwiftUI
import RealityKit
import RealityKitContent

class GestureManager: ObservableObject {
    let session = ARKitSession()
    var handTracking = HandTrackingProvider()
    @Published var latestHandTracking: HandsUpdates = .init(left: nil, right: nil)

    struct HandsUpdates {
        var left: HandAnchor?
        var right: HandAnchor?
    }

    func start() async {
        do {
            if HandTrackingProvider.isSupported {
                print("ARKitSession starting.")
                try await session.run([handTracking])
            }
        } catch {
            print("ARKitSession error:", error)
        }
    }

    func publishHandTrackingUpdates() async {
        for await update in handTracking.anchorUpdates {
            switch update.event {
            case .updated:
                let anchor = update.anchor
                
                guard anchor.isTracked else { continue }
                
                if anchor.chirality == .left {
                    latestHandTracking.left = anchor
                } else if anchor.chirality == .right {
                    latestHandTracking.right = anchor
                }
            default:
                break
            }
        }
    }

    func detectLeftCross() -> Bool {
        guard let leftHandAnchor = latestHandTracking.left,
              let rightHandAnchor = latestHandTracking.right,
              leftHandAnchor.isTracked, rightHandAnchor.isTracked else {
            return false
        }

        let leftHandCenter = leftHandAnchor.originFromAnchorTransform.columns.3
        let rightHandCenter = rightHandAnchor.originFromAnchorTransform.columns.3
        let leftHandZ = leftHandAnchor.originFromAnchorTransform.columns.3.z

        let handsDistance = distance(leftHandCenter, rightHandCenter)

        let punchDistanceThreshold: Float = 0.5

        return handsDistance > punchDistanceThreshold && leftHandZ > 2
    }
    
    func detectLeftHook() -> Bool {
        guard let leftHandAnchor = latestHandTracking.left,
              let rightHandAnchor = latestHandTracking.right,
              leftHandAnchor.isTracked, rightHandAnchor.isTracked else {
            return false
        }

        let leftHandCenter = leftHandAnchor.originFromAnchorTransform.columns.3
        let rightHandCenter = rightHandAnchor.originFromAnchorTransform.columns.3
        let leftHandZ = leftHandAnchor.originFromAnchorTransform.columns.3.z
        let leftHandx = leftHandAnchor.originFromAnchorTransform.columns.3.x

        let handsDistance = distance(leftHandCenter, rightHandCenter)

        let punchDistanceThreshold: Float = 0.5

        return handsDistance > punchDistanceThreshold && leftHandZ > 2 && leftHandx > 1
    }
    
    func detectLeftUppercut() -> Bool {
        guard let leftHandAnchor = latestHandTracking.left,
              let rightHandAnchor = latestHandTracking.right,
              leftHandAnchor.isTracked, rightHandAnchor.isTracked else {
            return false
        }

        let leftHandCenter = leftHandAnchor.originFromAnchorTransform.columns.3
        let rightHandCenter = rightHandAnchor.originFromAnchorTransform.columns.3
        let leftHandZ = leftHandAnchor.originFromAnchorTransform.columns.3.z
        let leftHandY = leftHandAnchor.originFromAnchorTransform.columns.3.y

        let handsDistance = distance(leftHandCenter, rightHandCenter)

        let punchDistanceThreshold: Float = 0.5

        return handsDistance > punchDistanceThreshold && leftHandZ > 2 && leftHandY > 1
    }
    
    func detectRightCross() -> Bool {
        guard let leftHandAnchor = latestHandTracking.left,
              let rightHandAnchor = latestHandTracking.right,
              leftHandAnchor.isTracked, rightHandAnchor.isTracked else {
            return false
        }

        let leftHandCenter = leftHandAnchor.originFromAnchorTransform.columns.3
        let rightHandCenter = rightHandAnchor.originFromAnchorTransform.columns.3
        let rightHandZ = rightHandAnchor.originFromAnchorTransform.columns.3.z

        let handsDistance = distance(leftHandCenter, rightHandCenter)

        let punchDistanceThreshold: Float = 0.5

        return handsDistance > punchDistanceThreshold && rightHandZ > 2
    }
    
    func detectRightHook() -> Bool {
        guard let leftHandAnchor = latestHandTracking.left,
              let rightHandAnchor = latestHandTracking.right,
              leftHandAnchor.isTracked, rightHandAnchor.isTracked else {
            return false
        }

        let leftHandCenter = leftHandAnchor.originFromAnchorTransform.columns.3
        let rightHandCenter = rightHandAnchor.originFromAnchorTransform.columns.3
        let rightHandZ = rightHandAnchor.originFromAnchorTransform.columns.3.z
        let rightHandX = rightHandAnchor.originFromAnchorTransform.columns.3.x

        let handsDistance = distance(leftHandCenter, rightHandCenter)

        let punchDistanceThreshold: Float = 0.5

        return handsDistance > punchDistanceThreshold && rightHandZ > 2 && rightHandX > 1
    }
    
    func detectRightUpperCut() -> Bool {
        guard let leftHandAnchor = latestHandTracking.left,
              let rightHandAnchor = latestHandTracking.right,
              leftHandAnchor.isTracked, rightHandAnchor.isTracked else {
            return false
        }

        let leftHandCenter = leftHandAnchor.originFromAnchorTransform.columns.3
        let rightHandCenter = rightHandAnchor.originFromAnchorTransform.columns.3
        let rightHandZ = rightHandAnchor.originFromAnchorTransform.columns.3.z
        let rightHandY = rightHandAnchor.originFromAnchorTransform.columns.3.z

        let handsDistance = distance(leftHandCenter, rightHandCenter)

        let punchDistanceThreshold: Float = 0.5

        return handsDistance > punchDistanceThreshold && rightHandZ > 2 && rightHandY > 1
    }

    func detectBlock() -> Bool {
        guard let leftHandAnchor = latestHandTracking.left,
              let rightHandAnchor = latestHandTracking.right,
              leftHandAnchor.isTracked, rightHandAnchor.isTracked else {
            return false
        }

        let leftHandCenter = leftHandAnchor.originFromAnchorTransform.columns.3
        let rightHandCenter = rightHandAnchor.originFromAnchorTransform.columns.3
        let leftHandY = leftHandAnchor.originFromAnchorTransform.columns.3.y
        let rightHandY = rightHandAnchor.originFromAnchorTransform.columns.3.y

        let handsDistance = distance(leftHandCenter, rightHandCenter)

        let punchDistanceThreshold: Float = 0.2

        return handsDistance < punchDistanceThreshold && leftHandY > 2 && rightHandY > 2
    }

    func detectLeftFaceOpen() -> Bool {
        guard let leftHandAnchor = latestHandTracking.left,
              let rightHandAnchor = latestHandTracking.right,
              leftHandAnchor.isTracked, rightHandAnchor.isTracked else {
            return false
        }

        let leftHandY = leftHandAnchor.originFromAnchorTransform.columns.3.y

        return leftHandY < 1
    }
    
    func detectRightFaceOpen() -> Bool {
        guard let leftHandAnchor = latestHandTracking.left,
              let rightHandAnchor = latestHandTracking.right,
              leftHandAnchor.isTracked, rightHandAnchor.isTracked else {
            return false
        }

        let rightHandY = leftHandAnchor.originFromAnchorTransform.columns.3.y

        return rightHandY < 1
    }
    
    func detectRightPunchSpeed() -> Double {
        return 0.0
    }
    
    func detectLeftPunchSpeed() -> Double {
        return 0.0
    }

}
