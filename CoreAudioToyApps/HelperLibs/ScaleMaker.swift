//
//  ScaleProtocols.swift
//  BookPractice2
//
//  Created by Moi on 12/5/18.
//  Copyright © 2018 Moi. All rights reserved.
//

import Foundation

enum ErrorFreeScale:Error{
    case wrongFormat
    var localizedDescription: String{
        get{
            switch self {
            case .wrongFormat:
                return "Error >> You should write a scale using twelves binary numbers, ex:\n\nMayor Ionian Scale     = 101011010101\nMinor Aeolian Scale    = 101101011010\nMinor Pentatonic Scale = 100101010010\n\n"
            }
        }
    }
}

struct FreeScale{
    
    subscript(_ n: Int)->UInt8{
        let result = n.quotientAndRemainder(dividingBy: self.notes.count )
        return notes[result.remainder] + (UInt8(result.quotient) * 12)
    }
    
    init(bitPattern:String) throws{
        let notBinaryCharacters = CharacterSet.init(charactersIn: "10").inverted
        let noError = bitPattern.rangeOfCharacter(from: notBinaryCharacters) == nil || bitPattern.count == 12
        guard noError else{ throw ErrorFreeScale.wrongFormat }
        self.init(bitPattern: UInt16.init(strtoul(bitPattern, nil, 2) & 0xFFF))
    }
    
    init(bitPattern:UInt16){
//        var bIndex = 11
//        for i in (0...12).reversed(){
//            let note = bitPattern & (1 << i)
//            if note != 0{
//                bIndex = i
//                break
//            }
//        }
        for (n,i) in (0...11).reversed().enumerated(){
            let note = bitPattern & (1 << i)
            if  note != 0{
                self.notes.append(UInt8(n))
            }
        }
        self.setNotes = Set<UInt8>.init(self.notes)
    }
    var notes:[UInt8] = []
    var setNotes:Set<UInt8> = []
}
