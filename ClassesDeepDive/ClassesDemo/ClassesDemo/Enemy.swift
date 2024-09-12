//
//  Enemy.swift
//  ClassesDemo
//
//  Created by haams on 9/6/24.
//

import Foundation
class Enemy {
    var health = 100
    var attackStrength = 10
    
    func move(){
        print("Walk forwards.")
    }
    
    func attack(){
        print("Land a hit, does \(attackStrength) damage.")
    }
}
