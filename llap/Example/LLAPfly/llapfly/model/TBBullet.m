//
//  TBBullet.m
//  llapfly
//
//  Created by KeSun on 16/7/10.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import "TBBullet.h"

#define kDamageNormal       1
#define kDamageEnhanced     2

@implementation TBBullet

+ (id)bulletWithPosition:(CGPoint)positon isEnhanced:(BOOL)isEnhanced
{
    TBBullet *bu = [[TBBullet alloc]init];
    bu.position = positon;
    bu.isEnhanced = isEnhanced;
    bu.damage = isEnhanced ? kDamageEnhanced : kDamageNormal;
    
    
    return bu;
}
@end
