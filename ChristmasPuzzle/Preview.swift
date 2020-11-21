//
//  Preview.swift
//  ChristmasPuzzle
//
//  Created by Yana  on 2020-11-18.
//  Copyright © 2020 Yana . All rights reserved.
//

import SpriteKit
import AVFoundation

class Preview: SKScene {
    
      override func didMove(to view: SKView) {
        audio.playMusic(fileName: "Sound/background", type: "mp3", volume: 1, loop: -1)
        audio.playSound(fileName: "Sound/MerryChristmas", type: "mp3", volume: 1, loop: 0)
    }
}
