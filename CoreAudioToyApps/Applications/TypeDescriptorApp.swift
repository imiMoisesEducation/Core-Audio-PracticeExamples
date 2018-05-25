//
//  FileDescriptorApp.swift
//  BookPractice2
//
//  Created by Moi on 18/5/18.
//  Copyright © 2018 Moi. All rights reserved.
//

import Foundation
import AudioToolbox

struct TypeDescriptorApp{
    init(){
        do
        {
            // MARK: - Choosing appropiate format
            var fileTypeAndFormat: AudioFileTypeAndFormatID = AudioFileTypeAndFormatID.init(mFileType: kAudioFileWAVEType, mFormatID: kAudioFormatLinearPCM)
            
            var infoSize:UInt32 = 0
            
            try SCoreAudioError.check(status: AudioFileGetGlobalInfoSize(kAudioFileGlobalInfo_AvailableStreamDescriptionsForFormat, UInt32(MemoryLayout<AudioFileTypeAndFormatID>.size(ofValue: fileTypeAndFormat)), &fileTypeAndFormat, &infoSize))
            
            let count = Int(exactly:infoSize)! / MemoryLayout<AudioStreamBasicDescription>.size
            var bufferArray = ContiguousArray<AudioStreamBasicDescription>.init(repeating: AudioStreamBasicDescription.init(), count: count)
            try SCoreAudioError.check(status: AudioFileGetGlobalInfo(kAudioFileGlobalInfo_AvailableStreamDescriptionsForFormat, UInt32(MemoryLayout<AudioFileTypeAndFormatID>.size(ofValue: fileTypeAndFormat)), &fileTypeAndFormat, &infoSize, &bufferArray[0]))
            
            for i in 0..<count{
                bufferArray[i].mFormatID = CFSwapInt32HostToBig(bufferArray[i].mFormatID)
                print("Setting \(i):")
                dump(bufferArray[i])
                print("-------------")
            }
        }
        catch{
            fatalError(error.localizedDescription)
        }
    }
}


