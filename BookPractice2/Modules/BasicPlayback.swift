//
//  Recorder.swift
//  BookPractice2
//
//  Created by Moi on 19/5/18.
//  Copyright © 2018 Moi. All rights reserved.
//

import Foundation
import AudioToolbox




struct BasicPlayback{
    
    // MARK: - User data struct
    struct MyPlayer{
        var playbackFile: AudioFileID
        var packetPosition: Int
        var numPacketsToRead: UInt32
        var packetDescs: UnsafeMutablePointer<AudioStreamPacketDescription>
        var isDone: Bool
    }
    
    // MARK: - Utility functions
    // Insert Listing 4.2 here
    // Insert Listing 5.14 here
    // Insert Listing 5.15 here
    
    // MARK: - Playback callback function
    // Insert Listings 5.16-5.19 here
    private func MyAQOutputCallback(inUserData:OpaquePointer,inAQ: AudioQueueRef, inCompleteAQBuffer: AudioQueueBufferRef){
        
    }
    
    init(){
        
        var myPlayer: MyPlayer
        // Open an audio file
        // Insert Listings 5.3-5.4 here
        
        // Set up format
        // Insert Listing 5.5 here
        
        // Set up queue
        // Insert Listings 5.6-5.10 here
        
        // Start queue
        // Insert Listings 5.11-5.12 here
        
        // Clean up queue when finished
        // Insert Listing 5.13 here
        
    }
}
