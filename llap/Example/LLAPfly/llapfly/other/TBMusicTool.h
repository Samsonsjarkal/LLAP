//
//  TBMusicTool.h
//  airplane
//
//  Created by qianjianeng on 16/1/24.
//  Copyright © 2016年 SF. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TBMusicType) {
    kTBMusicBullet = 0,
    kTBMusicEnemySmallDown,
    kTBMusicEnemyMiddleDown,
    kTBMusicEnemyBigDown,
    kTBMusicGameOver,
};

@interface TBMusicTool : NSObject
@property (nonatomic, assign) TBMusicType type;
+ (instancetype)shareManager;
- (void)backMusicPlay;
- (void)backMusicStop;
- (void)playSoundWithType:(TBMusicType)type;
@end
