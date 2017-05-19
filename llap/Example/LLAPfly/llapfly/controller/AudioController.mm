//
//  AudioController.m
//  llap
//
//  Created by Wei Wang on 2/18/16.
//  Copyright © 2016 Nanjing University. All rights reserved.
//
#import <Accelerate/Accelerate.h>
#import "AudioController.h"
#import <AVFoundation/AVFoundation.h>

// Utility file includes
#import "CAXException.h"
#import "CAStreamBasicDescription.h"

#include "RangeFinder.h"



struct CallbackData {
    AudioUnit               rioUnit;
    RangeFinder*            rangeFinder;
    BOOL*                   audioChainIsBeingReconstructed;
    BOOL                    canSendData;
    NSOutputStream*         dataOutStream;
    UInt64                  mtime;
    UInt64                  mUIUpdateTime;
    AVAudioPlayer*          audioPlayer;  //for soundplay remove clicks
    Float32                 distance;
    CallbackData(): rioUnit(NULL), rangeFinder(NULL) , audioChainIsBeingReconstructed(NULL), canSendData(false), dataOutStream(NULL), mtime(0),mUIUpdateTime(0),audioPlayer(NULL),distance(0) {}
} cd;


static OSStatus	performRender (void                         *inRefCon,
                               AudioUnitRenderActionFlags 	*ioActionFlags,
                               const AudioTimeStamp 		*inTimeStamp,
                               UInt32 						inBusNumber,
                               UInt32 						inNumberFrames,
                               AudioBufferList              *ioData)
{
    int16_t*    recorddata;
    Float32     distancechange;
    OSStatus err = noErr;
    if (*cd.audioChainIsBeingReconstructed == NO)
    {
        mach_timebase_info_data_t info;
        if (mach_timebase_info(&info) != KERN_SUCCESS) return -1.0;
        UInt64 startTime = mach_absolute_time();
        
        
        // we are calling AudioUnitRender on the input bus of AURemoteIO
        // this will store the audio data captured by the microphone in ioData
        err = AudioUnitRender(cd.rioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);

        recorddata= (int16_t*) ioData->mBuffers[0].mData;
        

        //Copy recorddata to RangeFinder buffer
        
        memcpy((void*) cd.rangeFinder->GetRecDataBuffer(inNumberFrames), (void*) ioData->mBuffers[0].mData, sizeof(int16_t)*inNumberFrames);
        
        // Get the distance back
        distancechange= cd.rangeFinder->GetDistanceChange();
        
        cd.distance=cd.distance+distancechange*SPEED_ADJ;
        if(cd.distance<0)
        {cd.distance=0;
        }
        if(cd.distance>500)
        {
            cd.distance=500;
        }
        
        memcpy((void*) ioData->mBuffers[0].mData, (void*) cd.rangeFinder->GetPlayBuffer(inNumberFrames), sizeof(int16_t)*inNumberFrames);
        if(cd.canSendData&&SEND_SOCKET_DATA)
        {
            if(cd.rangeFinder->mSocBufPos>0)
            {
                long len=(cd.rangeFinder->mSocBufPos+1>=SOCKET_SIZE) ? SOCKET_SIZE : cd.rangeFinder->mSocBufPos+1;
                uint8_t buf[len];
                memcpy(buf,cd.rangeFinder->GetSocketBuffer(), len);
                len=[cd.dataOutStream write:(const uint8_t*)buf maxLength:len];
                cd.rangeFinder->AdvanceSocketBuffer(len);
            }
        }
        
        cd.mtime=startTime;
        
        if(fabs(distancechange)>0.06&& (startTime-cd.mUIUpdateTime)/1.0e6*info.numer/info.denom>10)
        {
          [[NSNotificationCenter defaultCenter] postNotificationName:@"AudioDisUpdate" object:nil];
            cd.mUIUpdateTime=startTime;
        }
        
    }
    
    return err;
}



@interface AudioController(){
        AudioUnit       _myioUnit;
        RangeFinder*    _myRangeFinder;
        BOOL            _audioChainIsBeingReconstructed;
}
- (void)setupAudioSession;
- (void)setupIOUnit;
- (void)setupAudioChain;

@end

@implementation AudioController

- (instancetype) init
{
    self = [super init];
    if(self)
    {   _myRangeFinder = NULL;
        [self setupAudioChain];
    }
    
    return self;
}

@synthesize audiodistance = _audiodistance;

- (void) setAudiodistance:(Float32) d
{
    _audiodistance=d;
    cd.distance=d;
}


- (Float32) audiodistance
{
    _audiodistance=cd.distance;
    return cd.distance;
}

#pragma mark-

- (void)handleInterruption:(NSNotification *)notification
{   DebugLog(@"Interruption");
    try {
        UInt8 theInterruptionType = [[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] intValue];
        DebugLog(@"Session interrupted > --- %s ---\n", theInterruptionType == AVAudioSessionInterruptionTypeBegan ? "Begin Interruption" : "End Interruption");
        
        if (theInterruptionType == AVAudioSessionInterruptionTypeBegan) {
            [self stopIOUnit];
            //[self stopMySound];
        }
        
        if (theInterruptionType == AVAudioSessionInterruptionTypeEnded) {
            // make sure to activate the session
            NSError *error = nil;
            [[AVAudioSession sharedInstance] setActive:YES error:&error];
            if (nil != error) DebugLog(@"AVAudioSession set active failed with error: %@", error);
            
            [self startIOUnit];
         
        }
    } catch (CAXException e) {
        fprintf(stderr, "Error: %s \n", e.mOperation);
    }
}


- (void)handleRouteChange:(NSNotification *)notification
{
    UInt8 reasonValue = [[notification.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] intValue];
    AVAudioSessionRouteDescription *routeDescription = [notification.userInfo valueForKey:AVAudioSessionRouteChangePreviousRouteKey];
    
    DebugLog(@"Route change:");
    switch (reasonValue) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            DebugLog(@"     NewDeviceAvailable");
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            DebugLog(@"     OldDeviceUnavailable");
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            DebugLog(@"     CategoryChange");
            DebugLog(@" New Category: %@", [[AVAudioSession sharedInstance] category]);
            break;
        case AVAudioSessionRouteChangeReasonOverride:
            DebugLog(@"     Override");
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            DebugLog(@"     WakeFromSleep");
            break;
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            DebugLog(@"     NoSuitableRouteForCategory");
            break;
        default:
            DebugLog(@"     ReasonUnknown");
    }
    
    DebugLog(@"Previous route:\n");
    DebugLog(@"%@", routeDescription);
}

- (void)handleMediaServerReset:(NSNotification *)notification
{
    DebugLog(@"Media server has reset");
    _audioChainIsBeingReconstructed = YES;
    
    usleep(25000); //wait here for some time to ensure that we don't delete these objects while they are being accessed elsewhere
    
    // rebuild the audio chain
    delete _myRangeFinder;      _myRangeFinder = NULL;
    
    [self setupAudioChain];
    [self startIOUnit];
    
    _audioChainIsBeingReconstructed = NO;
}


#pragma mark-


- (void)setupAudioSession
{
    try {
        // Configure the audio session
        AVAudioSession *sessionInstance = [AVAudioSession sharedInstance];
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                NSLog(@"Permission granted");
            }
            else {
                NSLog(@"Permission denied");
            }
        }];
        // we are going to play and record so we pick that category
        NSError *error = nil;
        [sessionInstance setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];//AVAudioSessionCategoryPlayAndRecord
        XThrowIfError((OSStatus)error.code, "couldn't set session's audio category");
        
        // set the buffer duration to 10 ms
        NSTimeInterval bufferDuration = .01;
        [sessionInstance setPreferredIOBufferDuration:bufferDuration error:&error];
        XThrowIfError((OSStatus)error.code, "couldn't set session's I/O buffer duration");
        
        // set the session's sample rate
        [sessionInstance setPreferredSampleRate:AUDIO_SAMPLE_RATE error:&error];
        XThrowIfError((OSStatus)error.code, "couldn't set session's preferred sample rate");
        
        // add interruption handler
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleInterruption:)
                                                     name:AVAudioSessionInterruptionNotification
                                                   object:sessionInstance];
        
        // we don't do anything special in the route change notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRouteChange:)
                                                     name:AVAudioSessionRouteChangeNotification
                                                   object:sessionInstance];
        
        // if media services are reset, we need to rebuild our audio chain
        [[NSNotificationCenter defaultCenter]	addObserver:	self
                                                 selector:	@selector(handleMediaServerReset:)
                                                     name:	AVAudioSessionMediaServicesWereResetNotification
                                                   object:	sessionInstance];
        
        // activate the audio session
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
        XThrowIfError((OSStatus)error.code, "couldn't set session active");

    }
    
    catch (CAXException &e) {
        DebugLog(@"Error returned from setupAudioSession: %d: %s", (int)e.mError, e.mOperation);
    }
    catch (...) {
        DebugLog(@"Unknown error returned from setupAudioSession");
    }
    
    return;
}




- (void)setupIOUnit
{
    try {
        // Create a new instance of AURemoteIO
        
        AudioComponentDescription desc;
        desc.componentType = kAudioUnitType_Output;
        desc.componentSubType = kAudioUnitSubType_RemoteIO;
        desc.componentManufacturer = kAudioUnitManufacturer_Apple;
        desc.componentFlags = 0;
        desc.componentFlagsMask = 0;
        
        AudioComponent comp = AudioComponentFindNext(NULL, &desc);
        XThrowIfError(AudioComponentInstanceNew(comp, &_myioUnit), "couldn't create a new instance of AURemoteIO");
        
        //  Enable input and output on AURemoteIO
        //  Input is enabled on the input scope of the input element
        //  Output is enabled on the output scope of the output element
        
        UInt32 one = 1;
        XThrowIfError(AudioUnitSetProperty(_myioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &one, sizeof(one)), "could not enable input on AURemoteIO");
        XThrowIfError(AudioUnitSetProperty(_myioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, 0, &one, sizeof(one)), "could not enable output on AURemoteIO");
        
        // Explicitly set the input and output client formats
        // sample rate = 44100, num channels = 1, format = 16 bit Int
        
        CAStreamBasicDescription ioFormat = CAStreamBasicDescription(AUDIO_SAMPLE_RATE, 1, CAStreamBasicDescription::kPCMFormatInt16, false);
        XThrowIfError(AudioUnitSetProperty(_myioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &ioFormat, sizeof(ioFormat)), "couldn't set the input client format on AURemoteIO");
        XThrowIfError(AudioUnitSetProperty(_myioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &ioFormat, sizeof(ioFormat)), "couldn't set the output client format on AURemoteIO");
        
        // Set the MaximumFramesPerSlice property. This property is used to describe to an audio unit the maximum number
        // of samples it will be asked to produce on any single given call to AudioUnitRender
        UInt32 maxFramesPerSlice = MAX_FRAME_SIZE;
        XThrowIfError(AudioUnitSetProperty(_myioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFramesPerSlice, sizeof(UInt32)), "couldn't set max frames per slice on AURemoteIO");
        
        // Get the property value back from AURemoteIO. We are going to use this value to allocate buffers accordingly
        UInt32 propSize = sizeof(UInt32);
        XThrowIfError(AudioUnitGetProperty(_myioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFramesPerSlice, &propSize), "couldn't get max frames per slice on AURemoteIO");
        DebugLog(@"frame per slice %d",maxFramesPerSlice);
        _myRangeFinder = new RangeFinder(maxFramesPerSlice, NUM_FREQ, START_FREQ, FREQ_INTERVAL);
        
        // We need references to certain data in the render callback
        // This simple struct is used to hold that information
        
        cd.rioUnit = _myioUnit;
        cd.rangeFinder = _myRangeFinder;
        cd.audioChainIsBeingReconstructed = &_audioChainIsBeingReconstructed;
        
        // Set the render callback on AURemoteIO
        AURenderCallbackStruct renderCallback;
        renderCallback.inputProc = performRender;
        renderCallback.inputProcRefCon = NULL;
        XThrowIfError(AudioUnitSetProperty(_myioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &renderCallback, sizeof(renderCallback)), "couldn't set render callback on AURemoteIO");
        
        // Initialize the AURemoteIO instance
        XThrowIfError(AudioUnitInitialize(_myioUnit), "couldn't initialize AURemoteIO instance");
    }
    
    catch (CAXException &e) {
        DebugLog(@"Error returned from setupIOUnit: %d: %s", (int)e.mError, e.mOperation);
    }
    catch (...) {
        DebugLog(@"Unknown error returned from setupIOUnit");
    }
    
    return;
}


- (void)setupAudioChain
{
    [self setupAudioSession];
    [self setupIOUnit];
    if(SEND_SOCKET_DATA)
        [self setupNetwork];
    [self setupAudioPlayer];
}

#pragma mark-

-(void) setupAudioPlayer
{
    NSError *error;
    //Add background music
    //CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, CFStringRef([[NSBundle mainBundle] pathForResource:@"background" ofType:@"m4a"]), kCFURLPOSIXPathStyle, false);
    //cd.audioPlayer=[[AVAudioPlayer alloc] initWithContentsOfURL:(__bridge NSURL*)url error:&error];
  
    if(error!=nil)
    {
       XThrowIfError((OSStatus)error.code, "couldn't create AVAudioPlayer");
    }
    else{
        [cd.audioPlayer setNumberOfLoops: -1];
    }
    [cd.audioPlayer setVolume:0.01];
    //CFRelease(url);
}

-(void) playMySound
{
    [cd.audioPlayer play];
}

-(void) stopMySound
{
    [cd.audioPlayer stop];
}

#pragma mark-

- (void) setupNetwork
{
    if(!cd.dataOutStream)
    {
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef) CFSTR("192.168.1.5"), 12345, NULL, &writeStream);
    
    cd.dataOutStream = (__bridge_transfer NSOutputStream *)writeStream;
    [cd.dataOutStream setDelegate:self];

    [cd.dataOutStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [cd.dataOutStream open];
    }
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    switch(eventCode) {
        case NSStreamEventHasSpaceAvailable:
        {
            if(SEND_SOCKET_DATA)
            {
                if(cd.rangeFinder->mSocBufPos>0)
                {
                    long len=(cd.rangeFinder->mSocBufPos+1>=SOCKET_SIZE) ? SOCKET_SIZE : cd.rangeFinder->mSocBufPos+1;
                    uint8_t buf[len];
                    memcpy(buf,cd.rangeFinder->GetSocketBuffer(), len);
                    len=[cd.dataOutStream write:(const uint8_t*)buf maxLength:len];
                    cd.rangeFinder->AdvanceSocketBuffer(len);
                    cd.canSendData=false;
                }
                else
                {
                    cd.canSendData=true;
                }
            }

            break;
        }
        case NSStreamEventEndEncountered:
        {

            [cd.dataOutStream close];
            [cd.dataOutStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
            cd.dataOutStream = nil; // oStream is instance variable
            break;
        }

        
    }
    
}

#pragma mark-
- (OSStatus)startIOUnit
{
    
    OSStatus err = AudioOutputUnitStart(_myioUnit);
    return err;
}

- (OSStatus)stopIOUnit
{
    OSStatus err = AudioOutputUnitStop(_myioUnit);
    return err;
}

#pragma mark-

- (void) dealloc
{
    delete _myRangeFinder;      _myRangeFinder = NULL;
    [self stopMySound];
    if(cd.dataOutStream)
    {   [cd.dataOutStream close];
        [cd.dataOutStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                    forMode:NSDefaultRunLoopMode];
        cd.dataOutStream = nil;
    }
    
}


@end
