//
//  ScaleMakerApp.swift
//  BookPractice2
//
//  Created by Moi on 18/5/18.
//  Copyright © 2018 Moi. All rights reserved.
//

import Foundation
import AudioToolbox

// MARK: - Sample rate and duration
fileprivate let sampleRate = Float64(44100)
fileprivate let duration = Float64(22)


struct ScaleMakerApp{
    init(){
        // MARK: - Checks if input is well formated
        precondition(CommandLine.arguments.count > 3,"Error >> You must provide a frequency and a scale pattern in binary")
        guard let frequency = Double(CommandLine.arguments[2]) else{
            fatalError("Error >> The frequency doesnt have a floating point format")
        }
        let scalePattern = CommandLine.arguments[3]
        do{
            //Note generator based on the frequency and scale
            let noteGenerator = NotesGenerator.init(baseFrequency: frequency, scale: try .init(bitPattern:scalePattern))
            
            
            // MARK: - Generates properties
            print("Log >> Generating at \(frequency)hz with \(CommandLine.arguments[3]) pattern")
            
            let url = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("\(frequency)hz-\(scalePattern)scale.aif") as NSURL
            
            let framesPerPacket:UInt32 = 1
            let bytesPerFrame:UInt32 = 2
            
            var descriptor = AudioStreamBasicDescription.init(
                mSampleRate: sampleRate,
                mFormatID: UInt32(kAudioFormatLinearPCM),
                mFormatFlags: kAudioFormatFlagIsBigEndian | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked,
                mBytesPerPacket: framesPerPacket * bytesPerFrame,
                mFramesPerPacket: framesPerPacket,
                mBytesPerFrame: bytesPerFrame,
                mChannelsPerFrame: 1,
                mBitsPerChannel: 16,
                mReserved: 0
            )
            
            // MARK: - Set up the file
            var audioFile: AudioFileID? = nil
            try SCoreAudioError.check(status: AudioFileCreateWithURL(url, kAudioFileAIFFType, &descriptor, .eraseFile, &audioFile))
            
            // MARK: - Start writing samples
            let maxSampleCount: CLong = CLong(sampleRate * duration)
            var sampleCount:Int64 = 0
            var bytesToWrite:UInt32 = 2
            let samplePerNote: Int = Int.init(maxSampleCount/22)
            
            for note in 0..<Int(duration){
                let waveLenghtInSamples = sampleRate/noteGenerator[note]
                var samplePerNoteI = 0
                while samplePerNoteI < samplePerNote{
                    for i in 0..<Int(waveLenghtInSamples){
                        //var sample:Int16 = (i) < Int(sampleRate/noteGenerator[note])/2 ? Int16.max : Int16.min  // Square
                        var sample:Double = Double(i) / waveLenghtInSamples * Double(36000) // Sawtooth
                        //var sample: Double = 36000 * Double(sin(2 * Double.pi * Double(i) / waveLenghtInSamples)) // Wave
                        
                        let audioErr = AudioFileWriteBytes(audioFile!, false, sampleCount * Int64(2), &bytesToWrite, &sample)
                        precondition(audioErr == noErr,"There was an error writing on the file: \(SCoreAudioError.init(status: audioErr)!.localizedDescription)")
                        
                        sampleCount += 1
                        samplePerNoteI += 1
                        
                        guard samplePerNoteI < samplePerNote else{ break }
                    }
                }
            }
            try SCoreAudioError.check(status: AudioFileClose(audioFile!))
            print("Log >> Generated file at \(url.absoluteString!)")
        }catch{
            fatalError(error.localizedDescription)
        }
        exit(0)

    }
}
