//
//  BasicRecorder.swift
//  BookPractice2
//
//  Created by Moi on 19/5/18.
//  Copyright © 2018 Moi. All rights reserved.
//

import Foundation
import AudioToolbox

// Since it will be called in as a c function, this needs to be globally declared
fileprivate func myAQInputCallback(inUserData: UnsafeMutableRawPointer?, inQueue: AudioQueueRef, inBuffer: AudioQueueBufferRef, inStartTime: UnsafePointer<AudioTimeStamp>,inNumPackets: UInt32, inPacketDesc: UnsafePointer<AudioStreamPacketDescription>?){
    // Casting of User Info Pointer
    do{
        guard let recorder = inUserData?.assumingMemoryBound(to: BasicRecorder.MyRecorder.self) else{
            return
        }

        var inNumPackets = inNumPackets
        
        /*
             The function call of `AudioFileWritePackets has the following`
             - A file, which you put in the `MyRecorder` struct
             - A Boolean indicating whether you want to cache the data you're writing (you don't want in this case)
             - The size of the data buffer to write, which you get from the `inBuffer` parameter's `mAudioDataByteSize`
             - Packet descriptops, provided by the callback's `inPacketDesc` parameter
             - An index to which packet in the file to write, which is a running count that you keep track of in recorder's `recordPacket` field
             - The number of packets to write, provided by the callback's `inNumPackets` parameter
             - A pointer to the audio data, which is the `inBuffer.pointee.mAudioData` pointer
         */
        try SCoreAudioError.check(status:
            AudioFileWritePackets(recorder.pointee.recordFile!, false, inBuffer.pointee.mAudioDataByteSize, inPacketDesc, Int64(recorder.pointee.recordPacket), &inNumPackets, inBuffer.pointee.mAudioData)
        )
        
        // Increment the packet index
        recorder.pointee.recordPacket += inNumPackets
    
        //Re-enqueuing a Used Buffer
        if recorder.pointee.running{
            
            try SCoreAudioError.check(status: AudioQueueEnqueueBuffer(inQueue, inBuffer, 0, inPacketDesc))
        }
    }catch{
        if let fError = error as? SCoreAudioError{
            switch fError{
            case .audioFile_InvalidPacketOffset:
                return
            default:
                break
            }
        }
        fatalError(error.localizedDescription)
    }
    
}

struct BasicRecorder{

    //In core audio, it's common practice to use three buffers. The idea is, one buffer is being filled, one buffer is being drained, and the other is sitting in the queue as a spare, to account for lag.
    //You can use more, but using less than three could get you in trouble, With two buffers, you'd risk dropouts by not having a spare bufer while the other two are being used. With only one buffer, you'll almost certainly have dropouts because the one buffer the queue needs to record into will be unavaliable as your callback processes it
    let numberOfRecordBuffers = 3
    
    
    
    // MARK: - User data struct
    // Using info struct for recording audio queue callbacks
    struct MyRecorder{
        var recordFile: AudioFileID? = nil
        var recordPacket: UInt32 = 0
        var running: Bool = false
    }

    
    // MARK: - Utility functions
    private func myGetDefaultInputDeviceSampleRate(outSampleRate: inout Float64) throws{
        // Getting Current Audio Input Device Info from Audio Hardware Services
        var deviceID: AudioDeviceID = 0
        var propertySize: UInt32 = UInt32(MemoryLayout<AudioDeviceID>.size)
        var propertyAddress = AudioObjectPropertyAddress.init(mSelector: kAudioHardwarePropertyDefaultInputDevice, mScope: kAudioObjectPropertyScopeGlobal, mElement: 0)
        
        // vvv Doesnt exist on iOS devices, DEPRECATED
            // return AudioHardwareServiceGetPropertyData(AudioObjectID(bitPattern: kAudioObjectSystemObject), &propertyAddress, 0, NSNull, &propertySize, &deviceID)
        
        try SCoreAudioError.check(status:
            AudioObjectGetPropertyData(AudioObjectID(bitPattern: kAudioObjectSystemObject), &propertyAddress, 0, nil, &propertySize, &deviceID)
        )
        
        
        // Getting Input Device's Sample Rate
        propertyAddress.mSelector = kAudioDevicePropertyNominalSampleRate
        propertyAddress.mScope = kAudioObjectPropertyScopeGlobal
        propertyAddress.mElement = 0
        propertySize = UInt32(MemoryLayout<Float64>.size)
        
        try SCoreAudioError.check(status:
            AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, &outSampleRate)
        )
    }
    
    private func myCopyEncodercookieToFile(queue:AudioQueueRef?,theFile:AudioFileID?) throws{
        // Copying the magic cookie from Audio Queue to Audio File
        
        var propertySize: UInt32 = 0
        
        try SCoreAudioError.check(status:
            AudioQueueGetPropertySize(queue!, kAudioConverterCompressionMagicCookie, &propertySize)
        )
        
        guard propertySize > 0 else{ throw NSError.init(domain: "BasicRecorder", code: 0, userInfo: [NSLocalizedDescriptionKey : "Magic cookie couldnt be found"])}
        
        var magicCookie = ContiguousArray<UInt8>.init(repeating: 0, count: Int(propertySize))
        
        try SCoreAudioError.check(status:
            AudioQueueGetProperty(queue!, kAudioQueueProperty_MagicCookie, &magicCookie[0], &propertySize)
        )
        
        try SCoreAudioError.check(status:
            AudioFileSetProperty(theFile!, kAudioFilePropertyMagicCookieData, propertySize, &magicCookie[0])
        )
    }
    
    private func myComputeRecordBufferSize(format: inout AudioStreamBasicDescription, queue: AudioQueueRef,seconds:Float64) throws -> UInt32{
        var packets, frames, bytes: UInt32
        
        frames = UInt32(ceil(seconds * format.mSampleRate))
        
        
        /*
             1) You first need to know how many frames (one sample for everty channel) are in each buffer. You get this by multiplying the sample rate by the buffer duration. If the ASBD already has an `mBytesPerFrame` value, as in the case for constant bit rate formats such as PCM, you can trivially get the needed byte count by multiplying mBytesPerFrame by the frame count
         */
        if format.mBytesPerFrame > 0{
            bytes = frames * format.mBytesPerFrame
        }else{
            
            var maxPacketSize: UInt32 = 0
            if format.mBytesPerPacket > 0{
                /*
                   2) If that is not the case, you need to work at the packet level. The easy case for this is a constant packet size, indicated by a nonzero mBytesPerPacket
                 */
                // Constant packet size
                maxPacketSize = format.mBytesPerPacket
            }else{
                // Get the largest single packet size possible
                
                /*
                     3)  In the hard case, you get the audio queue property `kAudioConverterPropertyMaximunOutputPacketSize`, which gives upi an upper bound to work with. Either way, you have a `maxPacketSize`m which you'll need soon
                 */
                var propertySize:UInt32 = UInt32(MemoryLayout<UInt32>.size(ofValue: maxPacketSize))
                
                try SCoreAudioError.check(status:
                    AudioQueueGetProperty(queue, kAudioConverterPropertyMaximumOutputPacketSize, &maxPacketSize, &propertySize)
                )
            }
            
            if format.mFramesPerPacket > 0{
                /*
                 4) But how many packets are there? The ASBD might provide a mFramesPerPacket value; in that case, you divide the frame count by `mFramesPerPacket` to get a packet count (packets).
                 */
                packets = frames / format.mFramesPerPacket
            }else{
                // Worst case escenario: 1 frame in a packet
                
                /*
                     5) Otherwise asume the worst case oif one frame per packet
                 */
                packets = frames
            }
            
            // Sanity check
            if packets == 0{
                packets = 1
            }
            
            /*
                 6) Finally, with a frames-per-packet value (which you force to be nonzero, just to be safe) and a maximun size per packet, you can multiply the two to get a maximun buffer size.
             */
            bytes = packets * maxPacketSize
        }
        return bytes
    }
    
    
    
    
    
    init(){
        do{
            // Set up format
            
                //Creating MyRecorder struct and ASBD for Audio Queue
            var recorder: MyRecorder = MyRecorder.init()
            var recordFormat = AudioStreamBasicDescription.init()
            
                //Setting format of ASBD for Audio Queue
            recordFormat.mFormatID = kAudioFormatMPEG4AAC
            recordFormat.mChannelsPerFrame = 2
            
                //Function to correct sample rate
            try myGetDefaultInputDeviceSampleRate(outSampleRate: &recordFormat.mSampleRate)
            
                //Filling in ASBD with AudioFormatGetProperty
            var propSize:UInt32 = UInt32(MemoryLayout<AudioStreamBasicDescription>.size(ofValue: recordFormat))
            try SCoreAudioError.check(status: AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, 0, nil, &propSize, &recordFormat))
            
            
            // Set up queue
            
                //Creating new audio queue for input
            var queue: AudioQueueRef? = nil
            try SCoreAudioError.check(status:AudioQueueNewInput(&recordFormat, myAQInputCallback, &recorder, nil, nil, 0, &queue))
            
                //Retrieving Filled-Out ASBD from Audio Queue
            var size:UInt32 = UInt32(MemoryLayout<AudioStreamBasicDescription>.size(ofValue: recordFormat))
            try SCoreAudioError.check(status: AudioQueueGetProperty(queue!, kAudioConverterCurrentOutputStreamDescription, &recordFormat, &size))
            
            // Set up file
            
                //Creating Audio File for Output
            //let myFileURL: CFURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, CFStringCreateWithCString(kCFAllocatorDefault, "output.caf" , kCFStringEncodingASCII), CFURLPathStyle.cfurlposixPathStyle, false)
            let myFileURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("record-\(Date.init()).caf") as NSURL as CFURL
            try SCoreAudioError.check(status: AudioFileCreateWithURL(myFileURL, kAudioFileCAFType, &recordFormat, AudioFileFlags.eraseFile, &recorder.recordFile))
            
                //Calling a convenience method to handle the magic cookie
            try myCopyEncodercookieToFile(queue: queue,theFile: recorder.recordFile)
            
            // Other setup as needed
            
                // If it were PCM, we could easily get the buffer size by multiplying the SampleRate * Number of Channels * bytes per channel * duration of the buffer
                // When we use a non PCM type, we use a helper function (since the buffer size is variable)
                let bufferByteSize: UInt32 = try myComputeRecordBufferSize(format: &recordFormat, queue: queue!, seconds: 0.5)
            
            
                //Allocating and enqueuing buffers
            for _ in 0..<self.numberOfRecordBuffers{
                var buffer: AudioQueueBufferRef? = nil
                try SCoreAudioError.check(status: AudioQueueAllocateBuffer(queue!, bufferByteSize, &buffer))
                try SCoreAudioError.check(status: AudioQueueEnqueueBuffer(queue!, buffer!, 0, nil))
            }
            
            // Start queue
            
                //Starting audio queue
            recorder.running = true
            try SCoreAudioError.check(status: AudioQueueStart(queue!, nil))
            
                //Blocking on stdin to Continue Recording
            print("*Recording, press <return> to stop:*")
            getchar()
            
            // Stop queue
            
                //Stopping the audio queue
            print(" * Recording done *")
            recorder.running = false
            try SCoreAudioError.check(status: AudioQueueStop(queue!, true))
            
                //Resetting the cookie on the file
            try myCopyEncodercookieToFile(queue: queue,theFile: recorder.recordFile)
            
                //Cleaning up the Audio queue and Audio file
            AudioQueueDispose(queue!, true)
            AudioFileClose(recorder.recordFile!)
            
            exit(0)

        }catch{
            fatalError(error.localizedDescription)
        }
    }
}
