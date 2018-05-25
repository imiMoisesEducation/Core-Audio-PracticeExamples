//
//  main.swift
//  BookPractice2
//
//  Created by Moi on 12/5/18.
//  Copyright © 2018 Moi. All rights reserved.
//

import Foundation


precondition(CommandLine.argc > 1,"You didn't supply any argument")
var app: Any
switch CommandLine.arguments[1]{
case "scaleoutput":
    app = ScaleMakerApp()
case "typeDescriptor":
    app = TypeDescriptorApp()
case "basicRecorder":
    app = BasicRecorder()
case "basicPlayback":
    app = BasicPlayback()
    break
default:
    break
}

