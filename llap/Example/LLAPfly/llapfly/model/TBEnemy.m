//
//       
//  TBEnemy.m
//  llapfly
//
//  Created by KeSun on 16/7/10.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import "TBEnemy.h"

@implementation TBEnemy

+ (id)enemyWithType:(TBEnemyType)type size:(CGSize)size gameArea:(CGRect)gameArea
{
    TBEnemy *em = [[TBEnemy alloc] init];
    //calculate location
    CGFloat x = arc4random_uniform(gameArea.size.width - size.width * 2) + size.width;
    CGFloat y = - size.height / 2.0; //gameArea.size.height + size.height / 2.0;
    em.position = CGPointMake(x, y);
    
    switch (type) {
        case kEnemySmall:
            em.hp = 1;
            em.speed = arc4random_uniform(4) + 2;
            em.score = 1;
            
            break;
        case kEnemyMiddle:
            em.hp = 10;
            em.speed = arc4random_uniform(3) + 2;
            em.score = 10;
            
            break;
        case kEnemyBig:
            em.hp = 50;
            em.speed = arc4random_uniform(2) + 2;
            em.score = 30;
            
            break;
            
    }
    
    em.type = type;
    em.blowupFrames = 0;
    em.toBlowup = NO;
    
    
    return em;
}

@end
