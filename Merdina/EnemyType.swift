//
//  EnemyType.swift
//  Merdina
//
//  Created by Rita Marrano on 03/12/22.
//

import SpriteKit

struct EnemyType: Codable {
    let name: String
    let shields: Int
    let speed: CGFloat
    let powerUpChance: Int
}
