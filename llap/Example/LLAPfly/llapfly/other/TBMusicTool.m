//
//  TBMusicTool.m
//  airplane
//
//  Created by qianjianeng on 16/1/24.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "TBMusicTool.h"
#import <AVFoundation/AVFoundation.h>   //音乐
#import <AudioToolbox/AudioToolbox.h>   //音效
@interface TBMusicTool ()

@property (nonatomic, strong) AVAudioPlayer *musicPlayer;
@property (strong, nonatomic) NSDictionary *soundDict;

@end

@implementation TBMusicTool

+ (instancetype)shareManager
{
    static TBMusicTool *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TBMusicTool alloc] init];
    });
    return instance;
}


-(instancetype)init
{
    self = [super init];
    if (self) {
        
        //资源包
        NSString *bundlePath = [[[NSBundle mainBundle]bundlePath]stringByAppendingPathComponent:@"music.bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        NSString *path = [bundle pathForResource:@"game_music" ofType:@"mp3"];
        NSURL *url = [NSURL fileURLWithPath:path];
        
        //音乐
        self.musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [self.musicPlayer setNumberOfLoops:-1];   //循环播放
        [self.musicPlayer prepareToPlay];
        
        //音效
        self.soundDict = [self loadSoundsWithBundle:bundle];
    }
    
    return self;
}


- (void)backMusicPlay
{
    [self.musicPlayer play];
}

- (void)backMusicStop
{
    [self.musicPlayer stop];
}
#pragma mark 加载音效
- (SystemSoundID)loadSoundIdWithBundle:(NSBundle *)bundle name:(NSString *)name
{
    SystemSoundID soundId;
    
    NSString *path = [bundle pathForResource:name ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    // 提示，不需要硬记代码，可以直接输入url，然后让xcode帮我们修复代码
    // 完成bridge的类型转换
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &soundId);
    
    return soundId;
}

#pragma mark 加载声音文件到数据字典
- (NSDictionary *)loadSoundsWithBundle:(NSBundle *)bundle
{
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    
    // 数组中存放所有声音的文件名
    NSArray *array = @[@"bullet",
                       @"enemy1_down",
                       @"enemy2_down",
                       @"enemy3_down",
                       @"game_over"];
    
    // 1 遍历数组，2 创建声音ID 3 添加到字典
    for (NSString *name in array) {
        SystemSoundID soundId = [self loadSoundIdWithBundle:bundle name:name];
        
        // 使用文件名作为键值添加到字典
        [dictM setObject:@(soundId) forKey:name];
    }
    
    return dictM;
}

- (void)playSoundWithType:(TBMusicType)type
{
    SystemSoundID soundId = 0;
    switch (type) {
        case kTBMusicBullet:
            soundId = [self.soundDict[@"bullet"] unsignedIntValue];
            break;
        case kTBMusicEnemySmallDown:
            soundId = [self.soundDict[@"enemy1_down"] unsignedIntValue];
            break;
        case kTBMusicEnemyMiddleDown:
            soundId = [self.soundDict[@"enemy2_down"] unsignedIntValue];
            break;
        case kTBMusicEnemyBigDown:
            soundId = [self.soundDict[@"enemy3_down"] unsignedIntValue];
            break;
        case kTBMusicGameOver:
            soundId = [self.soundDict[@"game_over"] unsignedIntValue];
            break;
        
    }
    
    
    // 播放音效
    AudioServicesPlaySystemSound(soundId);
}

@end
