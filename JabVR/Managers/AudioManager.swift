//
//  SoundManager.swift
//  JabVR
//
//  Created by Adam Zabloudil on 11/26/23.
//

import AVFoundation

class AudioManager: ObservableObject {
    
    private var punchAudioPlayer: AVAudioPlayer?
    private var bellAudioPlayer: AVAudioPlayer?
    
    init() {
        configureAudioPlayerPunch()
        configureAudioPlayerBell()
    }
    
    private func configureAudioPlayerPunch() {
        if let soundURL = Bundle.main.url(forResource: "fist-punch-or-kick-7171", withExtension: "mp3") {
            do {
                punchAudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                punchAudioPlayer?.prepareToPlay()
            } catch {
                print("Error playing sound: \(error)")
            }
        }
    }
    
    private func configureAudioPlayerBell() {
        if let soundURL = Bundle.main.url(forResource: "boxing-bell", withExtension: "mp3") {
            do {
                bellAudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                bellAudioPlayer?.prepareToPlay()
            } catch {
                print("Error playing sound: \(error)")
            }
        }
    }
    
    func playPunchSound() {
        punchAudioPlayer?.play()
    }
    
    func playBellSound() {
        bellAudioPlayer?.play()
    }
    
}
