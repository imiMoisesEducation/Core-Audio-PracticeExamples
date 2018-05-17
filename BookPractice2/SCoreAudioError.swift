//
//  ErrorHandler.swift
//  BookPractice2
//
//  Created by Moi on 17/5/18.
//  Copyright © 2018 Moi. All rights reserved.
//

import Foundation
import AudioToolbox

enum SCoreAudioError:Error{
    case graph_NodeNotFound
    case graph_OutputNodeErr
    case graph_InvalidConnection
    case graph_CannotDoInCurrentContext
    case graph_InvalidAudioUnit
    case audioToolbox_InvalidSequenceType
    case audioToolbox_TrackIndexError
    case audioToolbox_TrackNotFound
    case audioToolbox_EndOfTrack
    case audioToolbox_StartOfTrack
    case audioToolbox_IlegalTrackDestination
    case audioToolbox_NoSequence
    case audioToolbox_InvalidEventType
    case audioToolbox_InvalidPlayerState
    case audioUnit_InvalidProperty
    case audioUnit_InvalidParameter
    case audioUnit_InvalidElement
    case audioUnit_NoConnection
    case audioUnit_FailedInitialization
    case audioUnit_TooManyFramesToProcess
    case audioUnit_InvalidFile
    case audioUnit_FormatNotSupported
    case audioUnit_Unitialized
    case audioUnit_InvalidScope
    case audioUnit_PropertyNotWritable
    case audioUnit_InvalidPropertyValue
    case audioUnit_PropertyNotInUse
    case audioUnit_Initialized
    case audioUnit_InvalidOfflineRender
    case audioUnit_Unauthorized
    case unknownError
    
    init?(status: OSStatus){
        if status == 0 {return nil}
        switch status {
        case kAUGraphErr_NodeNotFound:
            self = .graph_NodeNotFound
        case kAUGraphErr_OutputNodeErr:
            self = .graph_OutputNodeErr
        case kAUGraphErr_InvalidConnection:
            self = .graph_InvalidConnection
        case kAUGraphErr_CannotDoInCurrentContext:
            self = .graph_CannotDoInCurrentContext
        case kAUGraphErr_InvalidAudioUnit:
            self = .graph_InvalidAudioUnit
        case kAudioToolboxErr_InvalidSequenceType:
            self = .audioToolbox_InvalidSequenceType
        case kAudioToolboxErr_TrackIndexError:
            self = .audioToolbox_TrackIndexError
        case kAudioToolboxErr_TrackNotFound:
            self = .audioToolbox_TrackNotFound
        case kAudioToolboxErr_EndOfTrack:
            self = .audioToolbox_EndOfTrack
        case kAudioToolboxErr_StartOfTrack:
            self = .audioToolbox_StartOfTrack
        case kAudioToolboxErr_IllegalTrackDestination:
            self = .audioToolbox_IlegalTrackDestination
        case kAudioToolboxErr_NoSequence:
            self = .audioToolbox_NoSequence
        case kAudioToolboxErr_InvalidEventType:
            self = .audioToolbox_InvalidEventType
        case kAudioToolboxErr_InvalidPlayerState:
            self = .audioToolbox_InvalidPlayerState
        case kAudioUnitErr_InvalidProperty:
            self = .audioUnit_InvalidProperty
        case kAudioUnitErr_InvalidParameter:
            self = .audioUnit_InvalidParameter
        case kAudioUnitErr_InvalidElement:
            self = .audioUnit_InvalidElement
        case kAudioUnitErr_NoConnection:
            self = .audioUnit_NoConnection
        case kAudioUnitErr_FailedInitialization:
            self = .audioUnit_FailedInitialization
        case kAudioUnitErr_TooManyFramesToProcess:
            self = .audioUnit_TooManyFramesToProcess
        case kAudioUnitErr_InvalidFile:
            self = .audioUnit_InvalidFile
        case kAudioUnitErr_FormatNotSupported:
            self = .audioUnit_FormatNotSupported
        case kAudioUnitErr_Uninitialized:
            self = .audioUnit_Unitialized
        case kAudioUnitErr_InvalidScope:
            self = .audioUnit_InvalidScope
        case kAudioUnitErr_PropertyNotWritable:
            self = .audioUnit_PropertyNotWritable
        case kAudioUnitErr_InvalidPropertyValue:
            self = .audioUnit_InvalidPropertyValue
        case kAudioUnitErr_PropertyNotInUse:
            self = .audioUnit_PropertyNotInUse
        case kAudioUnitErr_Initialized:
            self = .audioUnit_Initialized
        case kAudioUnitErr_InvalidOfflineRender:
            self = .audioUnit_InvalidOfflineRender
        case kAudioUnitErr_Unauthorized:
            self = .audioUnit_Unauthorized
        default:
            self = .unknownError
        }
    }
    
    static public func check(status:OSStatus) throws{
        guard let error = SCoreAudioError.init(status: status) else{
            return
        }
        throw error
    }
    
    static private let strMap:[SCoreAudioError:String] = [
        .audioToolbox_EndOfTrack:"audioToolbox_EndOfTrack",
        .audioToolbox_IlegalTrackDestination:"audioToolbox_IlegalTrackDestination",
        .audioToolbox_InvalidEventType:"audioToolbox_InvalidEventType",
        .audioToolbox_InvalidPlayerState:"audioToolbox_InvalidPlayerState",
        .audioToolbox_InvalidSequenceType:"audioToolbox_InvalidSequenceType",
        .audioToolbox_NoSequence:"audioToolbox_NoSequence",
        .audioToolbox_StartOfTrack:"audioToolbox_StartOfTrack",
        .audioToolbox_TrackIndexError:"audioToolbox_TrackIndexError",
        .audioToolbox_TrackNotFound:"audioToolbox_TrackNotFound",
        .audioUnit_FailedInitialization:"audioUnit_FailedInitialization",
        .audioUnit_Unauthorized:"audioUnit_Unauthorized",
        .audioUnit_InvalidOfflineRender:"audioUnit_InvalidOfflineRender",
        .audioUnit_Initialized:"audioUnit_Initialized",
        .audioUnit_PropertyNotInUse:"audioUnit_PropertyNotInUse",
        .audioUnit_InvalidPropertyValue:"audioUnit_InvalidPropertyValue",
        .audioUnit_PropertyNotWritable:"audioUnit_PropertyNotWritable",
        .audioUnit_InvalidScope:"audioUnit_InvalidScope",
        .audioUnit_Unitialized:"audioUnit_Unitialized",
        .audioUnit_FormatNotSupported:"audioUnit_FormatNotSupported",
        .audioUnit_InvalidFile:"audioUnit_InvalidFile",
        .audioUnit_TooManyFramesToProcess:"audioUnit_TooManyFramesToProcess",
        .audioUnit_FailedInitialization:"audioUnit_FailedInitialization",
        .audioUnit_NoConnection:"audioUnit_NoConnection",
        .audioUnit_InvalidElement: "audioUnit_InvalidElement",
        .audioUnit_InvalidParameter: "audioUnit_InvalidParameter",
        .audioUnit_InvalidProperty: "audioUnit_InvalidProperty",
        .graph_CannotDoInCurrentContext: "graph_CannotDoInCurrentContext",
        .graph_InvalidConnection: "graph_InvalidConnection",
        .graph_InvalidAudioUnit:"graph_InvalidAudioUnit",
        .graph_OutputNodeErr:"graph_OutputNodeErr",
        .graph_NodeNotFound:"graph_NodeNotFound",
        .unknownError:"unknownError"
    ]
    
    var localizedDescription: String{
        get{
            return SCoreAudioError.strMap[self]!
        }
    }
}
