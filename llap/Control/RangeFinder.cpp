//
//  RangeFinder.cpp
//  llap
//
//  Created by Wei Wang on 2/19/16.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#include "RangeFinder.h"


#include <stdlib.h>


RangeFinder::RangeFinder( UInt32 inMaxFramesPerSlice , UInt32 inNumFreq, Float32 inStartFreq, Float32 inFreqInterv )
{
    //Number of frequency
    mNumFreqs = inNumFreq;
    //Buffer size
    mBufferSize = inMaxFramesPerSlice;
    //Frequency interval
    mFreqInterv = inFreqInterv;
    //Receive data size
    mRecDataSize = 4*inMaxFramesPerSlice;
    //Sound speed
    mSoundSpeed = 331.3 + 0.606 * TEMPERATURE;
    //Init buffer
    for(UInt32 i=0; i<MAX_NUM_FREQS; i++){
        mSinBuffer[i]=(Float32*) calloc(2*inMaxFramesPerSlice, sizeof(Float32));
        mCosBuffer[i]=(Float32*) calloc(2*inMaxFramesPerSlice, sizeof(Float32));
        
        mFreqs[i]=inStartFreq+i*inFreqInterv;
        
        mWaveLength[i]=mSoundSpeed/mFreqs[i]*1000; //all distance is in mm
        
        mBaseBandReal[i]=(Float32*) calloc(mRecDataSize/CIC_DEC, sizeof(Float32));
        mBaseBandImage[i]=(Float32*) calloc(mRecDataSize/CIC_DEC, sizeof(Float32));
        for(UInt32 k=0;k<CIC_SEC;k++)
        {
            mCICBuffer[i][k][0]=(Float32*) calloc(mRecDataSize/CIC_DEC+CIC_DELAY, sizeof(Float32));
            mCICBuffer[i][k][1]=(Float32*) calloc(mRecDataSize/CIC_DEC+CIC_DELAY, sizeof(Float32));
        }
    }
    
    mPlayBuffer = (int16_t*) calloc(2*inMaxFramesPerSlice, sizeof(int16_t));
    
    mRecDataBuffer = (int16_t*) calloc(mRecDataSize, sizeof(int16_t));
    mFRecDataBuffer = (Float32*) calloc(mRecDataSize, sizeof(Float32));
    mTempBuffer = (Float32*) calloc(mRecDataSize, sizeof(Float32));
    mCurPlayPos = 0;
    mCurRecPos = 0;
    mCurProcPos= 0;
    mLastCICPos =0;
    mDecsize=0;
    mSocBufPos=0;
    
    
    InitBuffer();
    
}

void RangeFinder::InitBuffer()
{
    for(UInt32 i=0; i<mNumFreqs; i++){
        for(UInt32 n=0;n<mBufferSize*2;n++){
            mCosBuffer[i][n]=cos(2*PI*n/AUDIO_SAMPLE_RATE*mFreqs[i]);
            mSinBuffer[i][n]=-sin(2*PI*n/AUDIO_SAMPLE_RATE*mFreqs[i]);
        }
        mDCValue[0][i]=0;
        mMaxValue[0][i]=0;
        mMinValue[0][i]=0;
        mDCValue[1][i]=0;
        mMaxValue[1][i]=0;
        mMinValue[1][i]=0;
    }
    
    Float32 mTempSample;
    for(UInt32 n=0;n<mBufferSize*2;n++){
        mTempSample=0;
        for(UInt32 i=0; i<mNumFreqs; i++){
            mTempSample+=mCosBuffer[i][n]*VOLUME;
        }
        mPlayBuffer[n]=(int16_t) (mTempSample/mNumFreqs*32767);
    }
    
}

RangeFinder::~RangeFinder()
{
    for (UInt32 i=0;i<mNumFreqs; i++)
    {
        if(mSinBuffer[i]!=NULL)
        {
            free(mSinBuffer[i]);
            mSinBuffer[i]=NULL;
        }
        if(mCosBuffer[i]!=NULL)
        {
            free(mCosBuffer[i]);
            mCosBuffer[i]=NULL;
        }
        if(mBaseBandReal[i]!=NULL)
        {
            free(mBaseBandReal[i]);
            mBaseBandReal[i]=NULL;
        }
        if(mBaseBandImage[i]!=NULL)
        {
            free(mBaseBandImage[i]);
            mBaseBandImage[i]=NULL;
        }
        for(UInt32 k=0;k<CIC_SEC;k++)
        {
            if(mCICBuffer[i][k][0]!=NULL)
            {
                free(mCICBuffer[i][k][0]);
                mCICBuffer[i][k][0]=NULL;
            }
            if(mCICBuffer[i][k][1]!=NULL)
            {
                free(mCICBuffer[i][k][1]);
                mCICBuffer[i][k][1]=NULL;
            }
        }
    }
    if(mPlayBuffer!=NULL)
    {
        free(mPlayBuffer);
        mPlayBuffer= NULL;
    }
    if(mTempBuffer!=NULL)
    {
        free(mTempBuffer);
        mTempBuffer= NULL;
    }
    
    if(mRecDataBuffer!=NULL)
    {
        free(mRecDataBuffer);
        mRecDataBuffer= NULL;
    }
    if(mFRecDataBuffer!=NULL)
    {
        free(mFRecDataBuffer);
        mFRecDataBuffer= NULL;
    }
    
}

int16_t* RangeFinder::GetPlayBuffer(UInt32 inSamples)
{
    int16_t* playDataPointer = mPlayBuffer + mCurPlayPos;
    
    mCurPlayPos += inSamples;
    
    if(mCurPlayPos >=mBufferSize)
        mCurPlayPos =mCurPlayPos -mBufferSize;
    
    return playDataPointer;
}

uint8_t* RangeFinder::GetSocketBuffer(void)
{
    return mSocketBuffer;
}

void RangeFinder::AdvanceSocketBuffer(long length)
{
    if(length>0)
    {
        if(length>=mSocBufPos)
        {
            mSocBufPos=0;
            return;
        }
        else
        {   mSocBufPos= mSocBufPos-(UInt32) length;
            memmove(mSocketBuffer,mSocketBuffer+length,mSocBufPos);
            return;
        }
    }
    
}


int16_t* RangeFinder::GetRecDataBuffer(UInt32 inSamples)
{
    int16_t* RecDataPointer = mRecDataBuffer + mCurRecPos;
    
    mCurRecPos += inSamples;
    
    if(mCurRecPos >= mRecDataSize) //over flowed RecBuffer
    {
        mCurRecPos=0;
        RecDataPointer = mRecDataBuffer;
    }
    
    return RecDataPointer;
}

SInt16* RangeFinder::GetOutputData(UInt32 inDataBytes)
{
    return NULL;
}

Float32 RangeFinder::GetDistanceChange(void)
{
    Float32 distancechange=0;
    
    //each time we process the data in the RecDataBuffer and clear the mCurRecPos
    
    //Get base band signal
    GetBaseBand();
    
    //Remove dcvalue from the baseband signal
    RemoveDC();
    
    //Send baseband singal via socket
    SendSocketData();
    
    //Calculate distance from the phase change
    distancechange=CalculateDistance();
    
    return distancechange;
}

Float32 RangeFinder::CalculateDistance()
{
    Float32 distance=0;
    DSPSplitComplex tempcomplex;
    Float32 tempdata[4096],tempdata2[4096],tempdata3[4096],temp_val;
    Float32 phasedata[MAX_NUM_FREQS][4096];
    int     ignorefreq[MAX_NUM_FREQS];
    
    
    if(mDecsize>4096)
        return 0;
    
    for(int f=0;f<mNumFreqs;f++)
    {
        ignorefreq[f]=0;
        //get complex number
        tempcomplex.realp=mBaseBandReal[f];
        tempcomplex.imagp=mBaseBandImage[f];
        
        //get magnitude
        vDSP_zvmags(&tempcomplex, 1, tempdata,1, mDecsize);
        vDSP_sve(tempdata,1,&temp_val,mDecsize);
        if(temp_val/mDecsize>POWER_THR) //only calculate the high power vectors
        {
            vDSP_zvphas(&tempcomplex,1, phasedata[f], 1, mDecsize);
            //phase unwarp
            for(int i=1;i<mDecsize;i++)
            {
                while(phasedata[f][i]-phasedata[f][i-1]>PI)
                    phasedata[f][i]=phasedata[f][i]-2*PI;
                while(phasedata[f][i]-phasedata[f][i-1]<-PI)
                    phasedata[f][i]=phasedata[f][i]+2*PI;
            }
            if(fabs(phasedata[f][mDecsize-1]-phasedata[f][0])>PI/4)
            {
                for(int i=0;i<=1;i++)
                    mDCValue[i][f]=(1-DC_TREND*2)*mDCValue[i][f]+
                    (mMinValue[i][f]+mMaxValue[i][f])/2*DC_TREND*2;
            }
            
            //prepare linear regression
            //remove start phase
            temp_val=-phasedata[f][0];
            vDSP_vsadd(phasedata[f],1,&temp_val,tempdata,1,mDecsize);
            //divide the constants
            temp_val=2*PI/mWaveLength[f];
            vDSP_vsdiv(tempdata,1,&temp_val,phasedata[f],1,mDecsize);
        }
        else //ignore the low power vectors
        {
            ignorefreq[f]=1;
        }
        
    }
    
    //linear regression
    for(int i=0;i<mDecsize;i++)
        tempdata2[i]=i;
    Float32 sumxy=0;
    Float32 sumy=0;
    int     numfreqused=0;
    for(int f=0;f<mNumFreqs;f++)
    {
        if(ignorefreq[f])
        {
            continue;
        }
        
        numfreqused++;
        
        vDSP_vmul(phasedata[f],1,tempdata2,1,tempdata,1,mDecsize);
        vDSP_sve(tempdata,1,&temp_val,mDecsize);
        sumxy+=temp_val;
        vDSP_sve(phasedata[f],1,&temp_val,mDecsize);
        sumy+=temp_val;
        
    }
    if(numfreqused==0)
    {
        distance=0;
        return distance;
    }
    
    Float32 deltax=deltax=mNumFreqs*((mDecsize-1)*mDecsize*(2*mDecsize-1)/6-(mDecsize-1)*mDecsize*(mDecsize-1)/4);
    Float32 delta=(sumxy-sumy*(mDecsize-1)/2.0)/deltax*mNumFreqs/numfreqused;
    
    Float32 varsum=0;
    Float32 var_val[MAX_NUM_FREQS];
    for(int i=0;i<mDecsize;i++)
        tempdata2[i]=i*delta;
    
    //get variance of each freq;
    for(int f=0;f<mNumFreqs;f++)
    {   var_val[f]=0;
        if(ignorefreq[f])
        {
            continue;
        }
        vDSP_vsub(tempdata2,1,phasedata[f],1,tempdata,1,mDecsize);
        vDSP_vsq(tempdata,1,tempdata3,1,mDecsize);
        vDSP_sve(tempdata3,1,var_val+f,mDecsize);
        varsum+=var_val[f];
    }
    varsum=varsum/numfreqused;
    for(int f=0;f<mNumFreqs;f++)
    {
        if(ignorefreq[f])
        {
            continue;
        }
        if(var_val[f]>varsum)
            ignorefreq[f]=1;
    }
    
    //linear regression
    for(int i=0;i<mDecsize;i++)
        tempdata2[i]=i;
    
    sumxy=0;
    sumy=0;
    numfreqused=0;
    for(int f=0;f<mNumFreqs;f++)
    {
        if(ignorefreq[f])
        {
            continue;
        }
        
        numfreqused++;
        
        vDSP_vmul(phasedata[f],1,tempdata2,1,tempdata,1,mDecsize);
        vDSP_sve(tempdata,1,&temp_val,mDecsize);
        sumxy+=temp_val;
        vDSP_sve(phasedata[f],1,&temp_val,mDecsize);
        sumy+=temp_val;
        
    }
    if(numfreqused==0)
    {
        distance=0;
        return distance;
    }
    
    delta=(sumxy-sumy*(mDecsize-1)/2.0)/deltax*mNumFreqs/numfreqused;
    
    distance=-delta*mDecsize/2;
    return distance;
}

void RangeFinder::RemoveDC(void)
{
    int f,i;
    Float32 tempdata[4096],tempdata2[4096],temp_val;
    Float32 vsum,dsum,max_valr,min_valr,max_vali,min_vali;
    if(mDecsize>4096)
        return;
    
    //'Levd' algorithm to calculate the DC value;
    for(f=0;f<mNumFreqs;f++)
    {
        vsum=0;
        dsum=0;
        //real part
        vDSP_maxv(mBaseBandReal[f],1,&max_valr,mDecsize);
        vDSP_minv(mBaseBandReal[f],1,&min_valr,mDecsize);
        //getvariance,first remove the first value
        temp_val=-mBaseBandReal[f][0];
        vDSP_vsadd(mBaseBandReal[f],1,&temp_val,tempdata,1,mDecsize);
        vDSP_sve(tempdata,1,&temp_val,mDecsize);
        dsum=dsum+fabs(temp_val)/mDecsize;
        vDSP_vsq(tempdata,1,tempdata2,1,mDecsize);
        vDSP_sve(tempdata2,1,&temp_val,mDecsize);
        vsum=vsum+fabs(temp_val)/mDecsize;
        
        //imag part
        vDSP_maxv(mBaseBandImage[f],1,&max_vali,mDecsize);
        vDSP_minv(mBaseBandImage[f],1,&min_vali,mDecsize);
        //getvariance,first remove the first value
        temp_val=-mBaseBandImage[f][0];
        vDSP_vsadd(mBaseBandImage[f],1,&temp_val,tempdata,1,mDecsize);
        vDSP_sve(tempdata,1,&temp_val,mDecsize);
        dsum=dsum+fabs(temp_val)/mDecsize;
        vDSP_vsq(tempdata,1,tempdata2,1,mDecsize);
        vDSP_sve(tempdata2,1,&temp_val,mDecsize);
        vsum=vsum+fabs(temp_val)/mDecsize;
        
        mFreqPower[f]=(vsum+dsum*dsum);///fabs(vsum-dsum*dsum)*vsum;
        
        //Get DC estimation
        if(mFreqPower[f]>POWER_THR)
        {
            if ( max_valr > mMaxValue[0][f] ||
                (max_valr > mMinValue[0][f]+PEAK_THR &&
                 (mMaxValue[0][f]-mMinValue[0][f]) > PEAK_THR*4) )
            {
                mMaxValue[0][f]=max_valr;
            }
            
            if ( min_valr < mMinValue[0][f] ||
                (min_valr < mMaxValue[0][f]-PEAK_THR &&
                 (mMaxValue[0][f]-mMinValue[0][f]) > PEAK_THR*4) )
            {
                mMinValue[0][f]=min_valr;
            }
            
            if ( max_vali > mMaxValue[1][f] ||
                (max_vali > mMinValue[1][f]+PEAK_THR &&
                 (mMaxValue[1][f]-mMinValue[1][f]) > PEAK_THR*4) )
            {
                mMaxValue[1][f]=max_vali;
            }
            
            if ( min_vali < mMinValue[1][f] ||
                (min_vali < mMaxValue[1][f]-PEAK_THR &&
                 (mMaxValue[1][f]-mMinValue[1][f]) > PEAK_THR*4) )
            {
                mMinValue[1][f]=min_vali;
            }
            
            
            if ( (mMaxValue[0][f]-mMinValue[0][f]) > PEAK_THR &&
                (mMaxValue[1][f]-mMinValue[1][f]) > PEAK_THR )
            {
                for(i=0;i<=1;i++)
                    mDCValue[i][f]=(1-DC_TREND)*mDCValue[i][f]+
                    (mMinValue[i][f]+mMaxValue[i][f])/2*DC_TREND;
            }
            
        }
        
        //remove DC
        for(i=0;i<mDecsize;i++)
        {
            mBaseBandReal[f][i]=mBaseBandReal[f][i]-mDCValue[0][f];
            mBaseBandImage[f][i]=mBaseBandImage[f][i]-mDCValue[1][f];
        }
        
    }
}

void RangeFinder::SendSocketData(void)
{ int   i,index;
    
    if(1) //send baseband to matlab
    {
        index=mSocBufPos;
        for(i=0;i<16; i++) //number of frequencies
        {
            for(UInt32 k=0;k<mDecsize;k++) //iterate through samples
            {
                if(index<SOCKETBUFLEN-4) //ensure enough buffer
                {
                    mSocketBuffer[index++]=(uint8_t) (((short) mBaseBandReal[i][k]) &0xFF);
                    mSocketBuffer[index++]=(uint8_t) (((short) mBaseBandReal[i][k]) >> 8 );
                    mSocketBuffer[index++]=(uint8_t) (((short) mBaseBandImage[i][k]) &0xFF);
                    mSocketBuffer[index++]=(uint8_t) (((short) mBaseBandImage[i][k]) >> 8 );
                }
            }
            
        }
        mSocBufPos=index-1;
    }
}


void RangeFinder::GetBaseBand(void)
{
    UInt32 i,index,decsize,cid;
    decsize=mCurRecPos/CIC_DEC;
    mDecsize=decsize;
    
    //change data from int to float32
    
    for(i=0;i<mCurRecPos; i++)
    {
        mFRecDataBuffer[i]= (Float32) (mRecDataBuffer[i]/32767.0);
    }
    
    for(i=0;i<mNumFreqs; i++)//mNumFreqs
    {
        vDSP_vmul(mFRecDataBuffer,1,mCosBuffer[i]+mCurProcPos,1,mTempBuffer,1,mCurRecPos); //multiply the cos
        cid=0;
        //sum CIC_DEC points of data, put into CICbuffer
        memmove(mCICBuffer[i][0][cid],mCICBuffer[i][0][cid]+mLastCICPos,CIC_DELAY*sizeof(Float32));
        index=CIC_DELAY;
        for(UInt32 k=0;k<mCurRecPos;k+=CIC_DEC)
        {
            vDSP_sve(mTempBuffer+k,1,mCICBuffer[i][0][cid]+index,CIC_DEC);
            index++;
        }
        
        //prepare CIC first level
        memmove(mCICBuffer[i][1][cid],mCICBuffer[i][1][cid]+mLastCICPos,CIC_DELAY*sizeof(Float32));
        //Sliding window sum
        vDSP_vswsum(mCICBuffer[i][0][cid],1,mCICBuffer[i][1][cid]+CIC_DELAY,1,decsize,CIC_DELAY);
        //prepare CIC second level
        memmove(mCICBuffer[i][2][cid],mCICBuffer[i][2][cid]+mLastCICPos,CIC_DELAY*sizeof(Float32));
        //Sliding window sum
        vDSP_vswsum(mCICBuffer[i][1][cid],1,mCICBuffer[i][2][cid]+CIC_DELAY,1,decsize,CIC_DELAY);
        //prepare CIC third level
        memmove(mCICBuffer[i][3][cid],mCICBuffer[i][3][cid]+mLastCICPos,CIC_DELAY*sizeof(Float32));
        //Sliding window sum
        vDSP_vswsum(mCICBuffer[i][2][cid],1,mCICBuffer[i][3][cid]+CIC_DELAY,1,decsize,CIC_DELAY);
        //CIC last level to Baseband
        vDSP_vswsum(mCICBuffer[i][3][cid],1,mBaseBandReal[i],1,decsize,CIC_DELAY);
        
        
        vDSP_vmul(mFRecDataBuffer,1,mSinBuffer[i]+mCurProcPos,1,mTempBuffer,1,mCurRecPos); //multiply the sin
        cid=1;
        //sum CIC_DEC points of data, put into CICbuffer
        memmove(mCICBuffer[i][0][cid],mCICBuffer[i][0][cid]+mLastCICPos,CIC_DELAY*sizeof(Float32));
        index=CIC_DELAY;
        for(UInt32 k=0;k<mCurRecPos;k+=CIC_DEC)
        {
            vDSP_sve(mTempBuffer+k,1,mCICBuffer[i][0][cid]+index,CIC_DEC);
            index++;
        }
        
        //prepare CIC first level
        memmove(mCICBuffer[i][1][cid],mCICBuffer[i][1][cid]+mLastCICPos,CIC_DELAY*sizeof(Float32));
        //Sliding window sum
        vDSP_vswsum(mCICBuffer[i][0][cid],1,mCICBuffer[i][1][cid]+CIC_DELAY,1,decsize,CIC_DELAY);
        //prepare CIC second level
        memmove(mCICBuffer[i][2][cid],mCICBuffer[i][2][cid]+mLastCICPos,CIC_DELAY*sizeof(Float32));
        //Sliding window sum
        vDSP_vswsum(mCICBuffer[i][1][cid],1,mCICBuffer[i][2][cid]+CIC_DELAY,1,decsize,CIC_DELAY);
        //prepare CIC third level
        memmove(mCICBuffer[i][3][cid],mCICBuffer[i][3][cid]+mLastCICPos,CIC_DELAY*sizeof(Float32));
        //Sliding window sum
        vDSP_vswsum(mCICBuffer[i][2][cid],1,mCICBuffer[i][3][cid]+CIC_DELAY,1,decsize,CIC_DELAY);
        //CIC last level to Baseband
        vDSP_vswsum(mCICBuffer[i][3][cid],1,mBaseBandImage[i],1,decsize,CIC_DELAY);
        
    }
    
    mCurProcPos=mCurProcPos+mCurRecPos;
    if(mCurProcPos >= mBufferSize)
        mCurProcPos= mCurProcPos - mBufferSize;
    mLastCICPos=decsize;
    mCurRecPos=0;
}
