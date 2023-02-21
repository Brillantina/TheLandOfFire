//
//  WaveComp.swift
//  Merdina
//
//  Created by Rita Marrano on 18/12/22.
//

import SpriteKit

struct WaveComp: Codable {
    
    struct compWave: Codable {
        let position: Int
        let xOffset: CGFloat
        let moveStraight: Bool
    }

    let name: String
    let components: [compWave]
}
