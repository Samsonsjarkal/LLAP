//
//  RangeFinder.h
//  llap
//
//  Created by Wei Wang on 2/19/16.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#ifndef RangeFinder_h
#define RangeFinder_h


#include <AudioToolbox/AudioToolbox.h>
#include <Accelerate/Accelerate.h>
#include <libkern/OSAtomic.h>

//max number of frequency
#define MAX_NUM_FREQS           16
//pi
#define PI                      3.1415926535
//audio sample rate
#define AUDIO_SAMPLE_RATE       48000  //should be the same as in controller, will add later
//default temperature
#define TEMPERATURE             20
//volume
#define VOLUME                  0.2
//cic filter stages
#define CIC_SEC                 4
//cic filter decimation
#define CIC_DEC                 16
//cic filter delay
#define CIC_DELAY               17
//socket buffer length
#define SOCKETBUFLEN            40960
//power threshold
#define POWER_THR               15000
//peak threshold
#define PEAK_THR                220
//dc_trend threshold
#define DC_TREND                0.25

class RangeFinder
{
public:
    RangeFinder( UInt32 inMaxFramesPerSlice, UInt32 inNumFreqs, Float32 inStartFreq, Float32 inFreqInterv );
    ~RangeFinder();
    
    int16_t*        GetPlayBuffer(UInt32 inSamples);
    int16_t*        GetRecDataBuffer(UInt32 inSamples);
    SInt16*         GetOutputData(UInt32 inDataBytes);
    Float32         GetDistanceChange(void);
    uint8_t*        GetSocketBuffer(void);
    void            AdvanceSocketBuffer(long length);
    UInt32          mSocBufPos;
    
private:
    void            InitBuffer();
    void            GetBaseBand();
    void            RemoveDC();
    void            SendSocketData();
    Float32         CalculateDistance();
    
    
    UInt32          mNumFreqs;//number of frequency
    UInt32          mCurPlayPos;//current play position
    UInt32          mCurProcPos;//current process position
    UInt32          mCurRecPos;//current receive position
    UInt32          mLastCICPos;//last cic filter position
    UInt32          mBufferSize;//buffer size
    UInt32          mRecDataSize;//receive data size
    UInt32          mDecsize;//buffer size after decimation
    Float32         mFreqInterv;//frequency interval
    Float32         mSoundSpeed;//sound speed
    Float32         mFreqs[MAX_NUM_FREQS];//frequency of the ultsound signal
    Float32         mWaveLength[MAX_NUM_FREQS];//wave length of the ultsound signal
    
    int16_t*        mPlayBuffer;
    int16_t*        mRecDataBuffer;
    Float32*        mFRecDataBuffer;
    Float32*        mSinBuffer[MAX_NUM_FREQS];
    Float32*        mCosBuffer[MAX_NUM_FREQS];
    Float32*        mBaseBandReal[MAX_NUM_FREQS];
    Float32*        mBaseBandImage[MAX_NUM_FREQS];
    Float32*        mTempBuffer;
    Float32*        mCICBuffer[MAX_NUM_FREQS][CIC_SEC][2];
    uint8_t         mSocketBuffer[SOCKETBUFLEN];
    Float32         mDCValue[2][MAX_NUM_FREQS];
    Float32         mMaxValue[2][MAX_NUM_FREQS];
    Float32         mMinValue[2][MAX_NUM_FREQS];
    Float32         mFreqPower[MAX_NUM_FREQS];
};

#endif /* RangeFinder_h */
