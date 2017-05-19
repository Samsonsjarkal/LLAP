//
//  TBBullet.h
//  llapfly
//
//  Created by KeSun on 16/7/10.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface TBBullet : NSObject

+ (id)bulletWithPosition:(CGPoint)positon isEnhanced:(BOOL)isEnhanced;

@property (assign, nonatomic) CGPoint position;

@property (assign, nonatomic) NSInteger damage;

@property (assign, nonatomic) BOOL isEnhanced;

@end
