//
//  TBEnemy.h
//  llapfly
//
//  Created by KeSun on 16/7/10.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TBEnemyType) {
    kEnemySmall = 0,
    kEnemyMiddle,
    kEnemyBig,
};

@interface TBEnemy : NSObject

@property (nonatomic, assign) TBEnemyType type;
@property (nonatomic, assign) CGPoint position;
//hp
@property (nonatomic, assign) NSInteger hp;
//speed
@property (nonatomic, assign) NSInteger speed;
//score
@property (nonatomic, assign) NSInteger score;
//toBlowup
@property (assign, nonatomic) BOOL toBlowup;
//frames
@property (assign, nonatomic) NSInteger blowupFrames;



+ (id)enemyWithType:(TBEnemyType)type size:(CGSize)size gameArea:(CGRect)gameArea;
@end
