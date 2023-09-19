//
//  RankingsView.swift
//  JabVR
//
//  Created by Adam Zabloudil on 11/26/23.
//

import Foundation
import SwiftUI

struct RankingsView: View {
    //firebase doesn't support visionOS yet, filler players for now
    let players = [
        Player(name: "Player1", wins: 47, losses: 5),
        Player(name: "Player2", wins: 36, losses: 20),
        Player(name: "Player3", wins: 10, losses: 16),
        Player(name: "Player4", wins: 28, losses: 4),
        Player(name: "Player5", wins: 40, losses: 7),
        Player(name: "Player6", wins: 20, losses: 12),
        Player(name: "Player7", wins: 30, losses: 18),
        Player(name: "Player8", wins: 36, losses: 3),
        Player(name: "Player9", wins: 14, losses: 0),
        Player(name: "Player10", wins: 24, losses: 0),
        Player(name: "Player11", wins: 64, losses: 25),
        Player(name: "Player12", wins: 26, losses: 15),
        Player(name: "Player13", wins: 73, losses: 8),
        Player(name: "Player14", wins: 35, losses: 30),
        Player(name: "Player15", wins: 16, losses: 16),
        Player(name: "Player16", wins: 21, losses: 23),
        Player(name: "Player17", wins: 19, losses: 18),
        Player(name: "Player18", wins: 32, losses: 11),
        Player(name: "Player19", wins: 18, losses: 15),
        Player(name: "Player20", wins: 11, losses: 13),
    ]

    var body: some View {
        Text("Worldwide Rankings")
            .font(.largeTitle)
        List(players.sorted(by: { $0.rank > $1.rank })) { player in
            HStack {
                Text(player.name)
                Spacer()
                Text("Wins: \(player.wins) - Losses: \(player.losses)")
            }
        }
    }
}
