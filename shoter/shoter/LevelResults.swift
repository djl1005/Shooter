//
//  LevelResults.swift
//  shoter
//
//  Created by student on 9/22/16.
//  Copyright © 2016 djl1005. All rights reserved.
//

import Foundation

class LevelResults  {
    let levelNum:Int
    let lives:Int
    let msg:String
    
    init(levelNum:Int, levelScore:Int , lives:Int, msg:String) {
        self.levelNum = levelNum
        self.lives = lives
        self.msg = msg
    }
}
