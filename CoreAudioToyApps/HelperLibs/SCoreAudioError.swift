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
    case graph_NodeNotFound(message:String?)
    case graph_OutputNodeErr(message:String?)
    case graph_InvalidConnection(message:String?)
    case graph_CannotDoInCurrentContext(message:String?)
    case graph_InvalidAudioUnit(message:String?)
    case audioToolbox_InvalidSequenceType(message:String?)
    case audioToolbox_TrackIndexError(message:String?)
    case audioToolbox_TrackNotFound(message:String?)
    case audioToolbox_EndOfTrack(message:String?)
    case audioToolbox_StartOfTrack(message:String?)
    case audioToolbox_IlegalTrackDestination(message:String?)
    case audioToolbox_NoSequence(message:String?)
    case audioToolbox_InvalidEventType(message:String?)
    case audioToolbox_InvalidPlayerState(message:String?)
    case audioUnit_InvalidProperty(message:String?)
    case audioUnit_InvalidParameter(message:String?)
    case audioUnit_InvalidElement(message:String?)
    case audioUnit_NoConnection(message:String?)
    case audioUnit_FailedInitialization(message:String?)
    case audioUnit_TooManyFramesToProcess(message:String?)
    case audioUnit_InvalidFile(message:String?)
    case audioUnit_FormatNotSupported(message:String?)
    case audioUnit_Unitialized(message:String?)
    case audioUnit_InvalidScope(message:String?)
    case audioUnit_PropertyNotWritable(message:String?)
    case audioUnit_InvalidPropertyValue(message:String?)
    case audioUnit_PropertyNotInUse(message:String?)
    case audioUnit_Initialized(message:String?)
    case audioUnit_InvalidOfflineRender(message:String?)
    case audioUnit_Unauthorized(message:String?)
    case audioFile_UnsupportedDataFormat(message:String?)
    case audioFile_InvalidPacketOffset(message:String?)
    case audioFile_NotOpen(message:String?)
    case audioFile_EndOfFile(message:String?)
    case audioFile_Position(message:String?)
    case audioFile_InvalidFile(message:String?)
    case audioFile_Unspecified(message:String?)
    case audioFile_NotFound(message:String?)
    case audioFile_InvalidChunk(message:String?)
    case audioFile_NotOptimized(message:String?)
    case audioFile_UnsuportedFileType(message:String?)
    case audioFile_UnsuportedProperty(message:String?)
    case audioFile_DoesNotAllow64BitDataSize(message:String?)
    case audioFile_Permissions(message:String?)
    case audioFile_BadPropertySize(message:String?)
    case audioFile_OperationNotSupported(message:String?)
    case extAudioFile_InvalidSeek(message:String?)
    case extAudioFile_InvalidProperty(message:String?)
    case extAudioFile_InvalidChannelMap(message:String?)
    case extAudioFile_InvalidDataFormat(message:String?)
    case extAudioFile_AsyncWriteTooLarge(message:String?)
    case extAudioFile_NonPCMClientFormat(message:String?)
    case extAudioFile_InvalidPropertySize(message:String?)
    case extAudioFile_MaxPacketSizeUnknown(message:String?)
    case extAudioFile_InvalidOperationOrder(message:String?)
    case extAudioFile_AsyncWriteBufferOverflow(message:String?)
    case audio_ParamError(message:String?)
    case unknownError(message:String?)
    
    init?(status: OSStatus, message:String? = nil){
        
        
        if status == 0 {return nil}
        
        switch status {
        case kAUGraphErr_NodeNotFound:
            self = .graph_NodeNotFound(message: message)
        case kAUGraphErr_OutputNodeErr:
            self = .graph_OutputNodeErr(message: message)
        case kAUGraphErr_InvalidConnection:
            self = .graph_InvalidConnection(message: message)
        case kAUGraphErr_CannotDoInCurrentContext:
            self = .graph_CannotDoInCurrentContext(message: message)
        case kAUGraphErr_InvalidAudioUnit:
            self = .graph_InvalidAudioUnit(message: message)
        case kAudioToolboxErr_InvalidSequenceType:
            self = .audioToolbox_InvalidSequenceType(message: message)
        case kAudioToolboxErr_TrackIndexError:
            self = .audioToolbox_TrackIndexError(message: message)
        case kAudioToolboxErr_TrackNotFound:
            self = .audioToolbox_TrackNotFound(message: message)
        case kAudioToolboxErr_EndOfTrack:
            self = .audioToolbox_EndOfTrack(message: message)
        case kAudioToolboxErr_StartOfTrack:
            self = .audioToolbox_StartOfTrack(message: message)
        case kAudioToolboxErr_IllegalTrackDestination:
            self = .audioToolbox_IlegalTrackDestination(message: message)
        case kAudioToolboxErr_NoSequence:
            self = .audioToolbox_NoSequence(message: message)
        case kAudioToolboxErr_InvalidEventType:
            self = .audioToolbox_InvalidEventType(message: message)
        case kAudioToolboxErr_InvalidPlayerState:
            self = .audioToolbox_InvalidPlayerState(message: message)
        case kAudioUnitErr_InvalidProperty:
            self = .audioUnit_InvalidProperty(message: message)
        case kAudioUnitErr_InvalidParameter:
            self = .audioUnit_InvalidParameter(message: message)
        case kAudioUnitErr_InvalidElement:
            self = .audioUnit_InvalidElement(message: message)
        case kAudioUnitErr_NoConnection:
            self = .audioUnit_NoConnection(message: message)
        case kAudioUnitErr_FailedInitialization:
            self = .audioUnit_FailedInitialization(message: message)
        case kAudioUnitErr_TooManyFramesToProcess:
            self = .audioUnit_TooManyFramesToProcess(message: message)
        case kAudioUnitErr_InvalidFile:
            self = .audioUnit_InvalidFile(message: message)
        case kAudioUnitErr_FormatNotSupported:
            self = .audioUnit_FormatNotSupported(message: message)
        case kAudioUnitErr_Uninitialized:
            self = .audioUnit_Unitialized(message: message)
        case kAudioUnitErr_InvalidScope:
            self = .audioUnit_InvalidScope(message: message)
        case kAudioUnitErr_PropertyNotWritable:
            self = .audioUnit_PropertyNotWritable(message: message)
        case kAudioUnitErr_InvalidPropertyValue:
            self = .audioUnit_InvalidPropertyValue(message: message)
        case kAudioUnitErr_PropertyNotInUse:
            self = .audioUnit_PropertyNotInUse(message: message)
        case kAudioUnitErr_Initialized:
            self = .audioUnit_Initialized(message: message)
        case kAudioUnitErr_InvalidOfflineRender:
            self = .audioUnit_InvalidOfflineRender(message: message)
        case kAudioUnitErr_Unauthorized:
            self = .audioUnit_Unauthorized(message: message)
        case kAudioFileUnsupportedDataFormatError:
            self = .audioFile_UnsupportedDataFormat(message: message)
        case kAudioFileInvalidPacketOffsetError:
            self = .audioFile_InvalidPacketOffset(message: message)
        case kAudioFileNotOpenError:
            self = .audioFile_NotOpen(message: message)
        case kAudioFileEndOfFileError:
            self = .audioFile_EndOfFile(message: message)
        case kAudioFilePositionError:
            self = .audioFile_Position(message: message)
        case kAudioFileInvalidFileError:
            self = .audioFile_InvalidFile(message: message)
        case kAudioFileUnspecifiedError:
            self = .audioFile_Unspecified(message: message)
        case kAudioFileFileNotFoundError:
            self = .audioFile_NotFound(message: message)
        case kAudioFileInvalidChunkError:
            self = .audioFile_InvalidChunk(message: message)
        case kAudioFileNotOptimizedError:
            self = .audioFile_NotOptimized(message: message)
        case kAudioFileUnsupportedFileTypeError:
            self = .audioFile_UnsuportedFileType(message: message)
        case kAudioFileUnsupportedPropertyError:
            self = .audioFile_UnsuportedProperty(message: message)
        case kAudioFileDoesNotAllow64BitDataSizeError:
            self = .audioFile_DoesNotAllow64BitDataSize(message: message)
        case kAudioFilePermissionsError:
            self = .audioFile_Permissions(message: message)
        case kAudioFileBadPropertySizeError:
            self = .audioFile_BadPropertySize(message: message)
        case kAudioFileOperationNotSupportedError:
            self = .audioFile_OperationNotSupported(message: message)
        case kExtAudioFileError_InvalidSeek:
            self = .extAudioFile_InvalidSeek(message: message)
        case kExtAudioFileError_InvalidProperty:
            self = .extAudioFile_InvalidProperty(message: message)
        case kExtAudioFileError_InvalidChannelMap:
            self = .extAudioFile_InvalidChannelMap(message: message)
        case kExtAudioFileError_InvalidDataFormat:
            self = .extAudioFile_InvalidDataFormat(message: message)
        case kExtAudioFileError_AsyncWriteTooLarge:
            self = .extAudioFile_AsyncWriteTooLarge(message: message)
        case kExtAudioFileError_NonPCMClientFormat:
            self = .extAudioFile_NonPCMClientFormat(message: message)
        case kExtAudioFileError_InvalidPropertySize:
            self = .extAudioFile_InvalidPropertySize(message: message)
        case kExtAudioFileError_MaxPacketSizeUnknown:
            self = .extAudioFile_MaxPacketSizeUnknown(message: message)
        case kExtAudioFileError_InvalidOperationOrder:
            self = .extAudioFile_InvalidOperationOrder(message: message)
        case kExtAudioFileError_AsyncWriteBufferOverflow:
            self = .extAudioFile_AsyncWriteBufferOverflow(message: message)
        case kAudio_ParamError:
            self = .audio_ParamError(message: message)
        default:
            self = .unknownError(message: message)
        }
        
        
    }
    
    static public func check(status:OSStatus, _ message: String? = nil) throws{
        guard let error = SCoreAudioError.init(status: status, message: message) else{
            return
        }
        throw error
    }
    
    
    var message: String?{
        get{
            switch self {
            case .audioToolbox_EndOfTrack(let message),
                 .audioToolbox_IlegalTrackDestination(let message),
                 .audioToolbox_InvalidEventType(let message),
                 .audioToolbox_InvalidPlayerState(let message),
                 .audioToolbox_InvalidSequenceType(let message),
                 .audioToolbox_NoSequence(let message),
                 .audioToolbox_StartOfTrack(let message),
                 .audioToolbox_TrackIndexError(let message),
                 .audioToolbox_TrackNotFound(let message),
                 .audioUnit_FailedInitialization(let message),
                 .audioUnit_Unauthorized(let message),
                 .audioUnit_InvalidOfflineRender(let message),
                 .audioUnit_Initialized(let message),
                 .audioUnit_PropertyNotInUse(let message),
                 .audioUnit_InvalidPropertyValue(let message),
                 .audioUnit_PropertyNotWritable(let message),
                 .audioUnit_InvalidScope(let message),
                 .audioUnit_Unitialized(let message),
                 .audioUnit_FormatNotSupported(let message),
                 .audioUnit_InvalidFile(let message),
                 .audioUnit_TooManyFramesToProcess(let message),
                 .audioUnit_NoConnection(let message),
                 .audioUnit_InvalidElement(let message),
                 .audioUnit_InvalidParameter(let message),
                 .audioUnit_InvalidProperty(let message),
                 .graph_CannotDoInCurrentContext(let message),
                 .graph_InvalidConnection(let message),
                 .graph_InvalidAudioUnit(let message),
                 .graph_OutputNodeErr(let message),
                 .graph_NodeNotFound(let message),
                 .audioFile_UnsupportedDataFormat(let message),
                 .audioFile_InvalidPacketOffset(let message),
                 .audioFile_NotOpen(let message),
                 .audioFile_EndOfFile(let message),
                 .audioFile_Position(let message),
                 .audioFile_InvalidFile(let message),
                 .audioFile_Unspecified(let message),
                 .audioFile_NotFound(let message),
                 .audioFile_InvalidChunk(let message),
                 .audioFile_NotOptimized(let message),
                 .audioFile_UnsuportedFileType(let message),
                 .audioFile_UnsuportedProperty(let message),
                 .audioFile_DoesNotAllow64BitDataSize(let message),
                 .audioFile_Permissions(let message),
                 .audioFile_BadPropertySize(let message),
                 .audioFile_OperationNotSupported(let message),
                 .extAudioFile_InvalidSeek(let message),
                 .extAudioFile_InvalidProperty(let message),
                 .extAudioFile_InvalidChannelMap(let message),
                 .extAudioFile_InvalidDataFormat(let message),
                 .extAudioFile_AsyncWriteTooLarge(let message),
                 .extAudioFile_NonPCMClientFormat(let message),
                 .extAudioFile_InvalidPropertySize(let message),
                 .extAudioFile_MaxPacketSizeUnknown(let message),
                 .extAudioFile_InvalidOperationOrder(let message),
                 .extAudioFile_AsyncWriteBufferOverflow(let message),
                 .audio_ParamError(let message),
                 .unknownError(let message):
                return message
            }
        }
    }
    
    var isAudioFileError:Bool{
        get{
            
            
            switch self {
            case .audioFile_UnsupportedDataFormat,
                 .audioFile_InvalidPacketOffset,
                 .audioFile_NotOpen,
                 .audioFile_EndOfFile,
                 .audioFile_Position,
                 .audioFile_InvalidFile,
                 .audioFile_Unspecified,
                 .audioFile_NotFound,
                 .audioFile_InvalidChunk,
                 .audioFile_NotOptimized,
                 .audioFile_UnsuportedFileType,
                 .audioFile_UnsuportedProperty,
                 .audioFile_DoesNotAllow64BitDataSize,
                 .audioFile_Permissions,
                 .audioFile_BadPropertySize,
                 .audioFile_OperationNotSupported:
                return true
            default:
                return false
            }
        }
    }
    
    var isExtAudioFileError:Bool{
        switch self {
        case .extAudioFile_InvalidSeek,
             .extAudioFile_InvalidProperty,
             .extAudioFile_InvalidChannelMap,
             .extAudioFile_InvalidDataFormat,
             .extAudioFile_AsyncWriteTooLarge,
             .extAudioFile_NonPCMClientFormat,
             .extAudioFile_InvalidPropertySize,
             .extAudioFile_MaxPacketSizeUnknown,
             .extAudioFile_InvalidOperationOrder,
             .extAudioFile_AsyncWriteBufferOverflow:
            return true
        default:
            return false
        }
    }
    
    var isGraphError:Bool{
        switch self {
        case .graph_CannotDoInCurrentContext,
             .graph_InvalidConnection,
             .graph_InvalidAudioUnit,
             .graph_OutputNodeErr,
             .graph_NodeNotFound:
            return true
        default:
            return false
        }
    }
    
    var isAudioUnitError:Bool{
        switch self {
        case .audioUnit_FailedInitialization,
             .audioUnit_Unauthorized,
             .audioUnit_InvalidOfflineRender,
             .audioUnit_Initialized,
             .audioUnit_PropertyNotInUse,
             .audioUnit_InvalidPropertyValue,
             .audioUnit_PropertyNotWritable,
             .audioUnit_InvalidScope,
             .audioUnit_Unitialized,
             .audioUnit_FormatNotSupported,
             .audioUnit_InvalidFile,
             .audioUnit_TooManyFramesToProcess,
             .audioUnit_NoConnection,
             .audioUnit_InvalidElement,
             .audioUnit_InvalidParameter,
             .audioUnit_InvalidProperty:
            return true
        default:
            return false
        }
    }
    
    var isAudioToolboxError:Bool{
        switch self {
        case .audioToolbox_EndOfTrack,
             .audioToolbox_IlegalTrackDestination,
             .audioToolbox_InvalidEventType,
             .audioToolbox_InvalidPlayerState,
             .audioToolbox_InvalidSequenceType,
             .audioToolbox_NoSequence,
             .audioToolbox_StartOfTrack,
             .audioToolbox_TrackIndexError,
             .audioToolbox_TrackNotFound:
            return true
        default:
            return false
        }
    }
    
    var isGeneralAudioError:Bool{
        switch self {
        case .audio_ParamError:
            return true
        default:
            return false
        }
    }
    
    var localizedDescription: String{
        get{
            var error: String = "Unknown Error"
            switch self{
            case .audioToolbox_EndOfTrack:
                error = "audioToolbox_EndOfTrack"
            case .audioToolbox_IlegalTrackDestination:
                error = "audioToolbox_IlegalTrackDestination"
            case .audioToolbox_InvalidEventType:
                error = "audioToolbox_InvalidEventType"
            case .audioToolbox_InvalidPlayerState:
                error = "audioToolbox_InvalidPlayerState"
            case .audioToolbox_InvalidSequenceType:
                error = "audioToolbox_InvalidSequenceType"
            case .audioToolbox_NoSequence:
                error = "audioToolbox_NoSequence"
            case .audioToolbox_StartOfTrack:
                error = "audioToolbox_StartOfTrack"
            case .audioToolbox_TrackIndexError:
                error = "audioToolbox_TrackIndexError"
            case .audioToolbox_TrackNotFound:
                error = "audioToolbox_TrackNotFound"
            case .audioUnit_FailedInitialization:
                error = "audioUnit_FailedInitialization"
            case .audioUnit_Unauthorized:
                error = "audioUnit_Unauthorized"
            case .audioUnit_InvalidOfflineRender:
                error = "audioUnit_InvalidOfflineRender"
            case .audioUnit_Initialized:
                error = "audioUnit_Initialized"
            case .audioUnit_PropertyNotInUse:
                error = "audioUnit_PropertyNotInUse"
            case .audioUnit_InvalidPropertyValue:
                error = "audioUnit_InvalidPropertyValue"
            case .audioUnit_PropertyNotWritable:
                error = "audioUnit_PropertyNotWritable"
            case .audioUnit_InvalidScope:
                error = "audioUnit_InvalidScope"
            case .audioUnit_Unitialized:
                error = "audioUnit_Unitialized"
            case .audioUnit_FormatNotSupported:
                error = "audioUnit_FormatNotSupported"
            case .audioUnit_InvalidFile:
                error = "audioUnit_InvalidFile"
            case .audioUnit_TooManyFramesToProcess:
                error = "audioUnit_TooManyFramesToProcess"
            case .audioUnit_NoConnection:
                error = "audioUnit_NoConnection"
            case .audioUnit_InvalidElement:
                error = "audioUnit_InvalidElement"
            case .audioUnit_InvalidParameter:
                error = "audioUnit_InvalidParameter"
            case .audioUnit_InvalidProperty:
                error = "audioUnit_InvalidProperty"
            case .graph_CannotDoInCurrentContext:
                error = "graph_CannotDoInCurrentContext"
            case .graph_InvalidConnection:
                error = "graph_InvalidConnection"
            case .graph_InvalidAudioUnit:
                error = "graph_InvalidAudioUnit"
            case .graph_OutputNodeErr:
                error = "graph_OutputNodeErr"
            case .graph_NodeNotFound:
                error = "graph_NodeNotFound"
            case .audioFile_UnsupportedDataFormat:
                error = "audioFile_UnsuportedDataFormat"
            case .audioFile_InvalidPacketOffset:
                error = "audioFile_InvalidPacketOffset"
            case .audioFile_NotOpen:
                error = "audioFile_NotOpen"
            case .audioFile_EndOfFile:
                error = "audioFile_EndOfFile"
            case .audioFile_Position:
                error = "audioFile_Position"
            case .audioFile_InvalidFile:
                error = "audioFile_InvalidFile"
            case .audioFile_Unspecified:
                error = "audioFile_Unspecified"
            case .audioFile_NotFound:
                error = "audioFile_NotFound"
            case .audioFile_InvalidChunk:
                error = "audioFile_InvalidChunk"
            case .audioFile_NotOptimized:
                error = "audioFile_NotOptimized"
            case .audioFile_UnsuportedFileType:
                error = "audioFile_UnsuportedFileType"
            case .audioFile_UnsuportedProperty:
                error = "audioFile_UnsuportedProperty"
            case .audioFile_DoesNotAllow64BitDataSize:
                error = "audioFile_DoesNotAllow64BitDataSize"
            case .audioFile_Permissions:
                error = "audioFile_Permissions"
            case .audioFile_BadPropertySize:
                error = "audioFile_BadPropertySize"
            case .audioFile_OperationNotSupported:
                error = "audioFile_OperationNotSupported"
            case .extAudioFile_InvalidSeek:
                error = "extAudioFile_InvalidSeek"
            case .extAudioFile_InvalidProperty:
                error = "extAudioFile_InvalidProperty"
            case .extAudioFile_InvalidChannelMap:
                error = "extAudioFile_InvalidChannelMap"
            case .extAudioFile_InvalidDataFormat:
                error = "extAudioFile_InvalidDataFormat"
            case .extAudioFile_AsyncWriteTooLarge:
                error = "extAudioFile_AsyncWriteTooLarge"
            case .extAudioFile_NonPCMClientFormat:
                error = "extAudioFile_NonPCMClientFormat"
            case .extAudioFile_InvalidPropertySize:
                error = "extAudioFile_InvalidPropertySize"
            case .extAudioFile_MaxPacketSizeUnknown:
                error = "extAudioFile_MaxPacketSizeUnknown"
            case .extAudioFile_InvalidOperationOrder:
                error = "extAudioFile_InvalidOperationOrder"
            case .extAudioFile_AsyncWriteBufferOverflow:
                error = "extAudioFile_AsyncWriteBufferOverflow"
            case .audio_ParamError:
                error = "audio_ParamError"
            case .unknownError:
                error = "unknownError, \(statusErr)"
            }
            return error.appending("\nNotes: \(String(describing: self.message))")
        }
    }
}


/*
     Next ones to type
 
 kAudioQueueErr_PrimeTimedOut
 kAudioQueueErr_BufferEmpty
 kAudioQueueErr_CannotStart
 kAudioQueueErr_Permissions
 kAudioQueueErr_TooManyTaps
 kAudioQueueErr_BufferInQueue
 kAudioQueueErr_CodecNotFound
 kAudioQueueErr_InvalidBuffer
 kAudioQueueErr_InvalidDevice
 kAudioQueueErr_CannotStartYet
 kAudioQueueErr_InvalidTapType
 kAudioQueueErr_RecordUnderrun
 kAudioQueueErr_DisposalPending
 kAudioQueueErr_InvalidProperty
 kAudioQueueErr_InvalidRunState
 kAudioQueueErr_InvalidParameter
 kAudioQueueErr_InvalidQueueType
 kAudioQueueErr_QueueInvalidated
 kAudioQueueErr_InvalidTapContext
 kAudioQueueErr_EnqueueDuringReset
 kAudioQueueErr_InvalidCodecAccess
 kAudioQueueErr_InvalidOfflineMode
 kAudioQueueErr_BufferEnqueuedTwice
 kAudioQueueErr_InvalidPropertySize
 kAudioQueueErr_InvalidPropertyValue
 */
