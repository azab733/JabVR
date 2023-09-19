//
//  ActionModels.swift
//  JabVR
//
//  Created by Adam Zabloudil on 11/28/23.
//

import Foundation

enum Difficulty {
    case easy, medium, hard
}

struct ActionProbability {
    var punch: Double
    var dodge: Double
    var block: Double
    var getHit: Double
}

let probabilities: [Difficulty: ActionProbability] = [
    .easy: ActionProbability(punch: 0.1, dodge: 0.1, block: 0.1, getHit: 0.7),
    .medium: ActionProbability(punch: 0.3, dodge: 0.3, block: 0.3, getHit: 0.1),
    .hard: ActionProbability(punch: 0.5, dodge: 0.4, block: 0.1, getHit: 0.0)
]
