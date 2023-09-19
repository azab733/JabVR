//
//  BagMenuView.swift
//  JabVR
//
//  Created by Adam Zabloudil on 11/28/23.
//

import Foundation
import SwiftUI
import RealityKit
import RealityKitContent

struct BagMenuView: View {
    
    @Binding var userHealth: Double
    @Binding var userHits: Int
    
    var body: some View {
        ZStack {
            Model3D(named: "Vintage__Old_punching_bag", bundle: realityKitContentBundle) { phase in
                switch phase {
                case .empty:
                    Text("EMPTY")
                    ProgressView()
                case .success(let resolvedModel3D):
                    resolvedModel3D
                        .resizable()
                        .scaledToFit()
                case .failure:
                    Text("FAILURE")
                    ProgressView()
                }
            }
            
            VStack {
                Spacer().frame(height:50)
                
                Text("Your Health")
                    .font(.headline)
                ProgressView(value: userHealth).tint(.purple).frame(width: 200)
                
                Spacer().frame(height:50)
                
                Text("Your Hits")
                    .font(.headline)
                Text("\(userHits)")
                    .font(.largeTitle)
                
                Spacer().frame(height:50)
            }
            .padding()
        }.rotation3DEffect(Rotation3D(angle: .degrees(30), axis: .y))
    }
}
