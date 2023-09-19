//
//  CountdownView.swift
//  JabVR
//
//  Created by Adam Zabloudil on 11/26/23.
//

import Foundation
import SwiftUI

struct CountdownView: View {
    @Binding var countdownValue: Int
    let onCountdownEnd: () -> Void

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Text("Fight starting in \(countdownValue)...")
            .font(.largeTitle)
            .onReceive(timer) { _ in
                if countdownValue > 0 {
                    countdownValue -= 1
                } else {
                    onCountdownEnd()
                }
            }
    }
}
