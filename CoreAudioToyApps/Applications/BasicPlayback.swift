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
    
    do{
        // Cast the User Info Pointer
        guard let player = inUserData?.assumingMemoryBound(to: BasicPlayback.MyPlayer.self) else{
            return
        }
        guard !player.pointee.isDone else{
            return
        }
        
        // Reading packets from audio file
        var numBytes:UInt32 = player.pointee.buffSize // THIS CAUSED ME A LOT OF PROBLEMS
        var nPackets = player.pointee.numPacketsToRead
        
        
        
        try SCoreAudioError.check(status: AudioFileReadPacketData(player.pointee.playbackFile!, false, &numBytes, player.pointee.packetDescs?.baseAddress, player.pointee.packetPosition, &nPackets, inCompleteAQBuffer.pointee.mAudioData), "Couldnt read packet data, \(#file) \(#function) \(#line)")
        
        player.pointee.packetPosition += Int64(nPackets) // If I delete this line, it will read the same packet over and over again
        // Enqueueing packets for Playback
        guard nPackets > 0 else{
            try SCoreAudioError.check(status: AudioQueueStop(inAQ, false), "`AudioQueueStop` failed, \(#file) \(#function) \(#line)")
            player.pointee.isDone = true
            return
        }
        
        inCompleteAQBuffer.pointee.mAudioDataByteSize = numBytes
        try SCoreAudioError.check(status: AudioQueueEnqueueBuffer(inAQ, inCompleteAQBuffer, player.pointee.packetDescs != nil ? nPackets : 0, player.pointee.packetDescs?.baseAddress), "Couldn't enqueue new packet to the playback queue,  \(#file) \(#function) \(#line)")
        
    }catch{
        fatalError(error.localizedDescription)
    }
    
}


struct BasicPlayback{
    
    let bufferSize = 3
    
    // Path to the file to open
    let AudioFilePath: CFURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("261.63hz-101011010101scale.aif") as NSURL as CFURL
    
    // MARK: - User data struct
    final class MyPlayer{
        var playbackFile: AudioFileID? = nil
        var packetPosition: Int64 = 0
        var numPacketsToRead: UInt32 = 0
        var packetDescs: UnsafeMutableBufferPointer<AudioStreamPacketDescription>?
        var isDone: Bool = false
        var buffSize: UInt32 = 0
        deinit {
            
            guard let packetDescs = packetDescs else{
                return
            }
            
            let size = Int(self.numPacketsToRead)
            packetDescs.baseAddress?.deinitialize(count: size)
            packetDescs.baseAddress?.deallocate(capacity: size)
        }
    }
    
    // MARK: - Utility functions
    // Calculating buffer size and maximun Number of Packets that can be read into the buffer
    func calculateBytesForTime(fileID: AudioFileID, dataFormat: AudioStreamBasicDescription,time:Float,outBufferByteSize:inout UInt32,outNumPacketsToRead:inout UInt32) throws->(){
        var maxPacketSize: UInt32 = 0
        var propSize = UInt32(MemoryLayout<UInt32>.size)
        try SCoreAudioError.check(status: AudioFileGetProperty(fileID, kAudioFilePropertyPacketSizeUpperBound, &propSize, &maxPacketSize), "Error getting the Packet size upper bound property, \(#file) \(#function) \(#line)")
        let maxBufferSize = 0x10000
        let minBufferSize = 0x4000
        if dataFormat.mFramesPerPacket != 0{
            let numPacketsForTime = (Float64(dataFormat.mSampleRate) / Float64(dataFormat.mFramesPerPacket)) * Float64(time)
            outBufferByteSize = UInt32(numPacketsForTime)
        }else{
            outBufferByteSize = maxBufferSize > maxPacketSize ? UInt32(maxBufferSize) : UInt32(maxPacketSize)
        }
        
        if outBufferByteSize > maxBufferSize && outBufferByteSize > maxPacketSize{
            outBufferByteSize = UInt32(maxBufferSize)
        }else{
            if outBufferByteSize < minBufferSize{
                outBufferByteSize = UInt32(minBufferSize)
            }
        }
        outNumPacketsToRead = outBufferByteSize / maxPacketSize
    }
    
    // Copying magic cookie from Audio File to Audio Queue
    func myCopyEncodedCookieToQueue(fileID: AudioFileID, queue: AudioQueueRef) throws{
        var propertySize: UInt32 = 0
        
        try SCoreAudioError.check(status: AudioFileGetPropertyInfo(fileID, kAudioFilePropertyMagicCookieData, &propertySize, nil),"Error getting magic cookie in \(#file) \(#function) \(#line)")
        
        guard propertySize > 0 else{
            return
        }
        
        let size = Int(propertySize)
        let magicCookie = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        try SCoreAudioError.check(status: AudioFileGetProperty(fileID, kAudioFilePropertyMagicCookieData, &propertySize, magicCookie),"Error getting the magic cookie from the file, \(#file) \(#function) \(#line)")
        try SCoreAudioError.check(status: AudioQueueSetProperty(queue, kAudioQueueProperty_MagicCookie, UnsafeRawPointer(magicCookie.advanced(by: 0)), propertySize), "Couldnt set the magic cookie into the queue, \(#file) \(#function) \(#line)")
        magicCookie.deinitialize(count: size)
        magicCookie.deallocate(capacity: size)
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
            var dataFormat = AudioStreamBasicDescription.init()
            var propSize: UInt32 = UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
            try SCoreAudioError.check(status: AudioFileGetProperty(audioFileID!, kAudioFilePropertyDataFormat, &propSize, &dataFormat), "Couldn't get file's data format")
            // Set up queue
            
                // Creating a new Audio Queue for output
            var queue: AudioQueueRef?
            try SCoreAudioError.check(status: AudioQueueNewOutput(&dataFormat, myAQOutputCallback, &player, nil, nil, 0, &queue),"`AudioQueueNewOutput` had an error")
            
                // Calling a convenience function to calculate Palyback Buffer Size and Number of Packets to Read
            var bufferByteSize: UInt32 = 0
            try calculateBytesForTime(fileID: player.playbackFile!, dataFormat: dataFormat, time: 0.5, outBufferByteSize: &bufferByteSize, outNumPacketsToRead: &player.numPacketsToRead)
            player.buffSize = bufferByteSize
                //Allocating memory for Packet Descriptions Array
            let isFormatVBR = dataFormat.mBytesPerPacket == 0 || dataFormat.mBytesPerFrame == 0
            
            if isFormatVBR{
                player.packetDescs = UnsafeMutableBufferPointer<AudioStreamPacketDescription>.init(start: UnsafeMutablePointer<AudioStreamPacketDescription>.allocate(capacity: Int(player.numPacketsToRead)), count: Int(player.numPacketsToRead))
            }else{
                player.packetDescs = nil
            }
            
                // Calling a Convinence Method to Handle Magic Cookie
            try myCopyEncodedCookieToQueue(fileID: player.playbackFile!, queue: queue!)
            
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
