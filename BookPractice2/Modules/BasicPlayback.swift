//
//  Recorder.swift
//  BookPractice2
//
//  Created by Moi on 19/5/18.
//  Copyright © 2018 Moi. All rights reserved.
//

import Foundation
import AudioToolbox

private func myAQOutputCallback(inUserData:UnsafeMutableRawPointer?,inAQ: AudioQueueRef, inCompleteAQBuffer: AudioQueueBufferRef){
    
    
}


struct BasicPlayback{
    
    let bufferSize = 3
    
    // Path to the file to open
    let AudioFilePath: CFURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("261.63hz-101011010101scale.aif") as NSURL as CFURL
    
    // MARK: - User data struct
    final class MyPlayer{
        var playbackFile: AudioFileID? = nil
        var packetPosition: Int = 0
        var numPacketsToRead: UInt32 = 0
        var packetDescs: UnsafeMutableBufferPointer<AudioStreamPacketDescription>?
        var isDone: Bool = false
        
        deinit {
            
            guard let packetDescs = packetDescs else{
                return
            }
            
            let aligment = MemoryLayout<AudioStreamPacketDescription>.alignment(ofValue: packetDescs.baseAddress!.pointee)
            let size = MemoryLayout<AudioStreamPacketDescription>.size(ofValue: packetDescs.baseAddress!.pointee)
            packetDescs.baseAddress?.deinitialize(count: Int(self.numPacketsToRead)).deallocate(bytes: size * Int(self.numPacketsToRead), alignedTo: aligment)
        }
    }
    
    // MARK: - Utility functions
    // Insert Listing 4.2 here
    func calculateBytesForTime(fileID: AudioFileID,dataFormat: AudioStreamBasicDescription,time:Float,outBufferByteSize:inout UInt32,outNumPacketsToRead:inout UInt32){
        
    }
    
    func myCopyEncodedCookieToQueue(fileID: AudioFileID, queue: AudioQueueRef){
        
    }
    // Insert Listing 5.14 here
    // Insert Listing 5.15 here
    
    // MARK: - Playback callback function
    // Insert Listings 5.16-5.19 here
    
    
    init(){
        
        do{
            var player: MyPlayer = .init()
            
            // Open an audio file
            
                //Opening an audio file for input
            var audioFileID: AudioFileID?
            try SCoreAudioError.check(status: AudioFileOpenURL(self.AudioFilePath, AudioFilePermissions.readPermission, kAudioFileAIFFType, &audioFileID))
            
            player.playbackFile = audioFileID
            
            // Set up format
            
                // Getting the ASBD from an Audio File
            var dataFormat: AudioStreamBasicDescription?
            var propSize: UInt32 = UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
            try SCoreAudioError.check(status: AudioFileGetProperty(audioFileID!, kAudioFilePropertyDataFormat, &propSize, &dataFormat), "Couldn't get file's data format")

            // Set up queue
            
                // Creating a new Audio Queue for output
            var queue: AudioQueueRef?
            
            try SCoreAudioError.check(status: AudioQueueNewOutput(&dataFormat!, myAQOutputCallback, &player, nil, nil, 0, &queue),"`AudioQueueNewOutput`")
            
                // Calling a convenience function to calculate Palyback Buffer Size and Number of Packets to Read
            var bufferByteSize: UInt32 = 0
            calculateBytesForTime(fileID: player.playbackFile!, dataFormat: dataFormat!, time: 0.5, outBufferByteSize: &bufferByteSize, outNumPacketsToRead: &player.numPacketsToRead)
            
                //Allocating memory for Packet Descriptions Array
            let isFormatVBR = dataFormat!.mBytesPerPacket == 0 || dataFormat!.mBytesPerFrame == 0
            
            if isFormatVBR{
                player.packetDescs = UnsafeMutableBufferPointer<AudioStreamPacketDescription>.init(start: UnsafeMutablePointer<AudioStreamPacketDescription>.allocate(capacity: Int(player.numPacketsToRead)), count: Int(player.numPacketsToRead))
            }else{
                player.packetDescs = nil
            }
            
                // Calling a Convinence Method to Handle Magic Cookie
            myCopyEncodedCookieToQueue(fileID: player.playbackFile!, queue: queue!)
            
                // Allocating and Enqueuing Playback Buffers
            var buffers:[AudioQueueBufferRef?] = Array<AudioQueueBufferRef?>.init(repeating: nil, count: self.bufferSize)
            
            player.isDone = false
            player.packetPosition = 0
            
            for i in 0..<self.bufferSize{
                try SCoreAudioError.check(status: AudioQueueAllocateBuffer(queue!, bufferByteSize, &buffers[i]), "`AudioQueueAllocateBuffer` failed")
                myAQOutputCallback(inUserData: &player, inAQ: queue!, inCompleteAQBuffer: buffers[i]!)
                
                if player.isDone{
                    break
                }
            }
        
            // Start queue
                // Insert Listings 5.11-5.12 here
            
                // Starting the playback audio queue
            try SCoreAudioError.check(status: AudioQueueStart(queue!, nil),"`AudioQueueStart` failed")
            
            print("*Playing...\n*")
            repeat{
                CFRunLoopRunInMode(CFRunLoopMode.defaultMode, 0.25, false)
            } while !(player.isDone)
            
                // Delaying to ensure queue plays out buffered audio
            CFRunLoopRunInMode(CFRunLoopMode.defaultMode, 2, false)
            
            // Clean up queue when finished
            player.isDone = true
            
            try SCoreAudioError.check(status: AudioQueueStop(queue!, true),"`AudioQueueStop` failed")
            
            AudioQueueDispose(queue!, true)
            AudioFileClose(player.playbackFile!)
        
            exit(0)
            
        }catch{
            fatalError(error.localizedDescription)
        }

        
        
        
        
        
        
    }
}
