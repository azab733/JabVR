//
//  HowToPlayView.swift
//  JabVR
//
//  Created by Adam Zabloudil on 11/26/23.
//

import Foundation
import SwiftUI

struct HowToPlayView: View {
    var body: some View {
        
        Spacer()
        
        Text("How To Play")
            .font(.title)
            .padding()
        
        Text("Jab VR is a simple mixed reality boxing game that's easy for anyone to play. \n \n On the home screen, select the difficulty level you want to play at. \n \n You can then tap start game, and your fight will start. \n \n To fight, you can either punch your opponent, or put your hands up in front of your face to block when the opponent punches. \n \n Your health and number of hits will be shown on the punching bag to the left. \n \n The first fighter to run out of health loses, good luck!")
            .font(.headline)
            .padding()
            .multilineTextAlignment(.center)
        
        Spacer()
        Spacer()
    }
}
