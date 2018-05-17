//
//  NotesGenerator.swift
//  BookPractice2
//
//  Created by Moi on 12/5/18.
//  Copyright © 2018 Moi. All rights reserved.
//

import Foundation

struct NotesGenerator{
    static private var coefficient = 0.05776226505
    var baseFrequency: Double
    var scale: FreeScale
    
    init(baseFrequency:Double,scale:FreeScale){
        self.baseFrequency = baseFrequency
        self.scale = scale
    }
    
    subscript(_ n: Int)->Double{
        return (baseFrequency*exp(Double(self.scale[n]) * NotesGenerator.coefficient))
    }
}


