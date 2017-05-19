//
//  TBhero.h
//  llapfly
//
//  Created by KeSun on 16/7/10.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface TBhero : NSObject

#pragma mark location
@property (nonatomic, assign) CGPoint position;

@property (nonatomic, assign, readonly) CGRect collisionFrame;
//enemy size
@property (nonatomic, assign) CGSize size;
//bullet
@property (assign, nonatomic) BOOL isEnhancedBullte;
//bullet enhanced time
@property (assign, nonatomic) NSInteger enhancedTime;
//bullet set
@property (strong, nonatomic) NSMutableSet *bullteSet;
//bullet number
@property (assign, nonatomic) NSInteger bulletCount;
#pragma mark bullet
// normal size
@property (assign, nonatomic) CGSize bullteNormalSize;
// enhanced size
@property (assign, nonatomic) CGSize bullteEnhancedSize;

//isDead
@property (nonatomic, assign) BOOL isDead;

+ (instancetype)heroWithSize:(CGSize)heroSize gameAera:(CGRect)gameAera;
- (void)fire;
@end
