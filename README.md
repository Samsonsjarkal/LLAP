# LLAP:Device-Free Gesture Tracking Using Acoustic Signals  
[![](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/Samsonsjarkal/LLAP/blob/master/LICENSE) 
[![](https://img.shields.io/github/release/Samsonsjarkal/LLAP.svg)](https://github.com/Samsonjarkal/LLAP/releases)
[![](https://img.shields.io/github/stars/Samsonsjarkal/LLAP.svg)](https://github.com/Samsonsjarkal/LLAP/stargazers)
[![](https://img.shields.io/github/forks/Samsonsjarkal/LLAP.svg)](https://github.com/Samsonsjarkal/LLAP/network) 

LLAP(Low-Latency Acoustic Phase) is a device-free gesture tracking scheme based on ultrasound signals, that can be deployed on existing mobile devices as a software (such as an APP) without any hardware modification.

This is an IOS implementation of the [LLAP](https://cs.nju.edu.cn/ww/papers/mobicom16_ultrasound.pdf) paper in Mobicom 2016. 

LLAP enables you to track the distance of the movement by only use the microphones and speaker.LLAP emits 17500~20300 Hz ultrasound signals,  measures the phase changes of the sound signals caused by hand/finger movements and then converts the phase changes into the distance of the movement. LLAP achieves a tracking accuracy of 3.5 mm and a latency of 15 ms on COTS mobile phones with limited computing power.

For more details, please check [our paper](https://cs.nju.edu.cn/ww/papers/mobicom16_ultrasound.pdf) and [our video](https://www.youtube.com/watch?v=gs8wMrOSY80) in Mobicom 2016.

Our work is reported by MIT TECH REVIEW: ["This App Lets You Control Your Phone Using Sonar"](https://www.technologyreview.com/s/602834/this-app-lets-you-control-your-phone-using-sonar/).

![llapfly](https://github.com/Samsonsjarkal/KeSun/blob/master/img/llapfly.gif?raw=true)

## How to use it
The way to use 'LLAP' is to add class `AudioController` and `RangeFinder` to your IOS project. An instance of class `AudioController` is needed to be add to your project.
In the interface of `AudioController`, the property `audiodistance` is the distance of the movement.

```
@interface AudioController : NSObject <NSStreamDelegate>

@property Float32 audiodistance;

- (OSStatus) startIOUnit;
- (OSStatus) stopIOUnit;
- (void) playMySound;
- (void) stopMySound;
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode;
@end

```

We develop a game called 'llapfly' to illustrate how to use llap in details. Users can move my hand left and right to control the airplane in the air.

Furthermore, we provide socket interface to get the baseband ultrasound signals for others researchers and developer. If you want to get the baseband ultrsound signals, you can modify the parameter `SEND_SOCKET_DATA`, IP address and port in class `AudioController`.

```
- (void) setupNetwork
{
    if(!cd.dataOutStream)
    {
    CFWriteStreamRef writeStream;
    //Modify the IP address and port
    CFStreamCreatePairWithSocketToHost(NULL,(CFStringRef)CFSTR("192.168.1.5"), 12345, NULL, &writeStream);
    
    cd.dataOutStream = (__bridge_transfer NSOutputStream *)writeStream;
    [cd.dataOutStream setDelegate:self];

    [cd.dataOutStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [cd.dataOutStream open];
    }
}

```

Our work also support to emit ultrasound along with normal music, you can add the background in our example 'llayfly' by uncomment the button `musicOn`.

## LICENSE
MIT license.

copyright (c) 2017 Nanjing University rights reserved.

## Contact
More than our own work, we are excited about others using our work to advance the state of the art. If our work helps you in your work or you want to cooperate with us, please let us know (kesun@smail.nju.edu.cn) and cite [our paper](https://cs.nju.edu.cn/ww/papers/mobicom16_ultrasound.pdf).

GitHub:[https://github.com/Samsonsjarkal](https://github.com/Samsonsjarkal/LLAP)

Email:kesun@smail.nju.edu.cn;ww@nju.edu.cn;alexliu@cse.msu.edu

## Reference
Wei Wang, Alex X. Liu, and Ke Sun. Device-free gesture tracking using acoustic signals. In Proceedings of ACM MobiCom, 2016