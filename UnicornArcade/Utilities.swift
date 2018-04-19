//
//  File.swift
//  UnicornArcade
//
//  Created by Daniel Alarcon on 4/8/18.
//  Copyright © 2018 NYU_iOS_Programming_Team. All rights reserved.
//

import Foundation
import SpriteKit

extension Array {
    func randomElement() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}

func squareNum(number: CGFloat) -> CGFloat {
    return number*number
}
