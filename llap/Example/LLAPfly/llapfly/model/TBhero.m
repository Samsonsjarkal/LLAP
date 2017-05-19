//
//  TBhero.m
//  llapfly
//
//  Created by KeSun on 16/7/10.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import "TBhero.h"
#import "TBBullet.h"

#define kFireCount 2
@implementation TBhero

+ (instancetype)heroWithSize:(CGSize)heroSize gameAera:(CGRect)gameAera
{
    TBhero *hero = [[TBhero alloc] init];
    hero.position = CGPointMake(gameAera.size.width/2, gameAera.size.height - 50);
    hero.size = heroSize;
    hero.isEnhancedBullte = NO;
    hero.enhancedTime = 0;
    hero.bulletCount = 0;
    hero.bullteSet = [NSMutableSet set];
    hero.isDead = NO;
    
    return hero;
}



#pragma mark - fire
- (void)fire
{
    CGSize bullteSize = self.bullteNormalSize;
    if (self.isEnhancedBullte) {
        bullteSize = self.bullteEnhancedSize;
    }

    CGFloat y = self.position.y - self.size.height/2 - bullteSize.height/2;
    CGFloat x = self.position.x;
    
    for (NSInteger i = 0; i < kFireCount; i++) {
        CGPoint p = CGPointMake(x, y - i * bullteSize.height * 2);
        TBBullet *b = [TBBullet bulletWithPosition:p isEnhanced:self.isEnhancedBullte];
    [self.bullteSet addObject:b];
        
        
    }
}

//collisionframe
- (CGRect)collisionFrame
{
    CGFloat x = self.position.x - self.size.width / 4.0;
    CGFloat y = self.position.y - self.size.height / 2.0;
    CGFloat w = self.size.width / 2.0;
    CGFloat h = self.size.height;
    
    return CGRectMake(x, y, w, h);
    
}
@end
