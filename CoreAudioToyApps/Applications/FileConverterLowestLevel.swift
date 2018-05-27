//
//  FileConverter.swift
//  CoreAudioToyApps
//
//  Created by Moi on 26/5/18.
//  Copyright © 2018 Moi. All rights reserved.
//

import Foundation
import AudioToolbox

// MARK : - Converter callback function
func myAudioConverterCallback(inAudioConverter:AudioConverterRef,ioDataPacketCount:UnsafeMutablePointer<UInt32>,ioData:UnsafeMutablePointer<AudioBufferList>,outDataPacketDescription: UnsafeMutablePointer<UnsafeMutablePointer<AudioStreamPacketDescription>?>?,userData:UnsafeMutableRawPointer?)->OSStatus{
    let converterSettings = userData!.assumingMemoryBound(to: FileConverterLowestLevel.MyAudioConverterSettings.self)
    //Zeroing audio buffers
    ioData.pointee.mBuffers.mData = nil
    ioData.pointee.mBuffers.mDataByteSize = 0
    
    
    //Determining how many packets can be read from the input file
        //If there are not enough packets to satisfy the request, then read what's left
    if (converterSettings.pointee.inputFilePacketIndex + UInt64(ioDataPacketCount.pointee) > converterSettings.pointee.inputFilePacketCount){
        ioDataPacketCount.pointee = UInt32(converterSettings.pointee.inputFilePacketIndex)
    }
    
    guard ioDataPacketCount.pointee != 0 else{ return noErr }
    
    
    //Allocating a buffer to fill and convert
    if converterSettings.pointee.sourceBuffer != nil{
        free(converterSettings.pointee.sourceBuffer!)
        converterSettings.pointee.sourceBuffer = nil
    }
    
    converterSettings.pointee.sourceBuffer = calloc(1, Int(ioDataPacketCount.pointee) * Int(converterSettings.pointee.inputFileMaxSize))
    
    //Read packets into the conversion buffer
    var outByteCount:UInt32 = 0
    
    var result = AudioFileReadPacketData(converterSettings.pointee.inputFile!, true, &outByteCount, converterSettings.pointee.inputAudioStreamPacketDescription, Int64(converterSettings.pointee.inputFilePacketIndex), ioDataPacketCount, converterSettings.pointee.sourceBuffer)
 
    if #available(OSX 10.7, *) {
        if result == kAudioFileEndOfFileError && ioDataPacketCount.pointee != 0{ result = noErr}
    }else {
        if result == eofErr && ioDataPacketCount.pointee == 0 {result = noErr}
    }
    guard result == noErr else{ return result }
    
    // Updating the Source File Position and AudioBuffer Members with the Results of Read
    converterSettings.pointee.inputFilePacketIndex += UInt64(ioDataPacketCount.pointee)
    ioData.pointee.mBuffers.mData = converterSettings.pointee.sourceBuffer
    ioData.pointee.mBuffers.mDataByteSize = outByteCount
    
    if outDataPacketDescription != nil{
        outDataPacketDescription?.pointee = converterSettings.pointee.inputAudioStreamPacketDescription
    }
    
    return result
}




struct FileConverterLowestLevel{
    
    // MARK : - Data struct
    struct MyAudioConverterSettings{
        var inputFormat = AudioStreamBasicDescription.init()
        var outputFormat = AudioStreamBasicDescription.init()
        var inputFile: AudioFileID?
        var outputFile: AudioFileID?
        var inputFilePacketIndex: UInt64 = 0
        var inputFilePacketCount: UInt64 = 0
        var inputFileMaxSize: UInt64 = 0
        var inputAudioStreamPacketDescription: UnsafeMutablePointer<AudioStreamPacketDescription>?
        var sourceBuffer: UnsafeMutableRawPointer?
    }
    
    // MARK : - Utility Functions
    func Convert(_ converterSettings: inout MyAudioConverterSettings) throws{
        var audioConverter: AudioConverterRef?
        
        try SCoreAudioError.check(status: AudioConverterNew(&converterSettings.inputFormat, &converterSettings.outputFormat, &audioConverter), "Couldnt initialze the Audio Converter service")
        
        var packetsPerBuffer : UInt32 = 0
        var outputBufferSize: UInt32 = 32 * 1024 // 32kb is a good starting point
        var sizePerPacket = converterSettings.inputFormat.mBytesPerPacket
        
        if sizePerPacket == 0{
            //Determining the Size of a Packet Buffer Array and Packets-per-Buffer Count for Variable Bit Rate Data
            var size: UInt32 = UInt32(MemoryLayout<UInt32>.size)
            try SCoreAudioError.check(status: AudioConverterGetProperty(audioConverter!, kAudioConverterPropertyMaximumOutputPacketSize, &size, &sizePerPacket), "Couldn't get the maximun output packet size from the Audio Converter")
            
                if sizePerPacket > outputBufferSize{
                    outputBufferSize = sizePerPacket
                }
            
                packetsPerBuffer = outputBufferSize / sizePerPacket
                converterSettings.inputAudioStreamPacketDescription = UnsafeMutablePointer<AudioStreamPacketDescription>.allocate(capacity: Int(packetsPerBuffer))
            }else{
                //Determining the Size of a Packet Buffer for Constant Bit Rate
                packetsPerBuffer = outputBufferSize / sizePerPacket
            }
        
    
        //Allocating memory for audio conversion Buffer
        let outputBuffer = UnsafeMutableRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: Int(outputBufferSize)))
        
        // Loop to convert and Write Data
        var outputFilePacketPosition:UInt32  = 0
        
        repeat{
            //Preparing audio buffer to recieve Converted Data
            var convertedData = AudioBufferList.init()
            convertedData.mNumberBuffers = 1
            convertedData.mBuffers.mNumberChannels = converterSettings.inputFormat.mChannelsPerFrame
            convertedData.mBuffers.mDataByteSize = outputBufferSize
            convertedData.mBuffers.mData = outputBuffer
            
            //Calling AudioConverterFillComplexBuffer
            var ioOutputDataPackets: UInt32 = packetsPerBuffer
            guard (try? SCoreAudioError.check(status: AudioConverterFillComplexBuffer(audioConverter!, myAudioConverterCallback, &converterSettings, &ioOutputDataPackets, &convertedData, converterSettings.inputAudioStreamPacketDescription))) != nil,
                ioOutputDataPackets != 0 else{ break }
            
            
            //Write the converted data to the output file
            try SCoreAudioError.check(status: AudioFileWriteBytes(converterSettings.outputFile!, false, (Int64(outputFilePacketPosition) / Int64(converterSettings.outputFormat.mBytesPerPacket)), &ioOutputDataPackets, &convertedData.mBuffers.mData), "Couldnt write bytes to the file")
            outputFilePacketPosition += ioOutputDataPackets * converterSettings.outputFormat.mBytesPerPacket
            
       }while(true)
        //Cleaningup the Audio Converter
        AudioConverterDispose(audioConverter!)
        
        
        
    }
    
    
    init(){
        
        do{
            var fileConverterModel = MyAudioConverterSettings.init()
            
            //Open Input file
            let audioInputFilePath: CFURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("261.63hz-101011010101scale.aif") as NSURL as CFURL
            
            try SCoreAudioError.check(status:
                AudioFileOpenURL(audioInputFilePath, AudioFilePermissions.readPermission, kAudioFileCAFType, &fileConverterModel.inputFile),"Error opening the input file"
            )
            
            //Get Input format
            var asbdSize = UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
            
            try SCoreAudioError.check(status: AudioFileGetProperty(fileConverterModel.inputFile!, kAudioFilePropertyDataFormat, &asbdSize, &fileConverterModel.inputFormat), "Couldnt get the data format of the input file")
            
            var int64max = UInt32(MemoryLayout<UInt64>.size)
            
            try SCoreAudioError.check(status:  AudioFileGetProperty(fileConverterModel.inputFile!, kAudioFilePropertyAudioDataPacketCount, &int64max , &fileConverterModel.inputFilePacketCount), "Couldnt get the input file packet count")
            
            var uint32max = UInt32(MemoryLayout<UInt32>.size)
            
            try SCoreAudioError.check(status: AudioFileGetProperty(fileConverterModel.inputFile!, kAudioFilePropertyMaximumPacketSize, &uint32max, &fileConverterModel.inputFileMaxSize), "Couldnt get the maximun packet size")
            
            //Set up output file
            
            fileConverterModel.outputFormat.mSampleRate = 44100.0
            fileConverterModel.outputFormat.mFormatID = kAudioFormatLinearPCM
            fileConverterModel.outputFormat.mFormatFlags = kAudioFormatFlagIsBigEndian | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked
            fileConverterModel.outputFormat.mBytesPerPacket = 4
            fileConverterModel.outputFormat.mFramesPerPacket = 1
            fileConverterModel.outputFormat.mBytesPerFrame = 4
            fileConverterModel.outputFormat.mChannelsPerFrame = 2
            fileConverterModel.outputFormat.mBitsPerChannel = 16
            
            let audioOutputFilePath: CFURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Converted-261.63hz-101011010101scale.aif") as NSURL as CFURL
            
            try SCoreAudioError.check(status: AudioFileCreateWithURL(audioOutputFilePath, kAudioFileAIFFType, &fileConverterModel.outputFormat, AudioFileFlags.eraseFile, &fileConverterModel.outputFile), "Couldnt create a new file")
            //Perform coversion
            print("Converting...\n")
            try Convert(&fileConverterModel)
            
            AudioFileClose(fileConverterModel.inputFile!)
            AudioFileClose(fileConverterModel.outputFile!)
            
            
        }catch{
            print(error.localizedDescription)
            fatalError(error.localizedDescription)
        }
        
        
    }
}
