//
//  ProfileModels.swift
//  JabVR
//
//  Created by Adam Zabloudil on 11/28/23.
//

import Foundation

struct Player: Identifiable {
    let id = UUID()
    let name: String
    let wins: Int
    let losses: Int

    var rank: Int {
        wins - (losses * 5)
    }
}
