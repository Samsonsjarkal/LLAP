//
//  TBEnemyView.m
//  llapfly
//
//  Created by KeSun on 16/7/16.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import "TBEnemyView.h"
#import "TBEnemy.h"
@implementation TBEnemyView

- (id)initWithEnemy:(TBEnemy *)enemy imageManager:(TBImageManager *)imageManger
{
    self = [super init];
    
    if (self) {
        self.enemy = enemy;
        
        switch (enemy.type) {
            case kEnemySmall:
                self.image = imageManger.enemySmallImage;
                self.blowupImages = imageManger.enemySmallBlowupImages;
                break;
            case kEnemyMiddle:
                self.image = imageManger.enemyMiddleImage;
                self.blowupImages = imageManger.enemyMiddleBlowupImages;
                self.hitImage = imageManger.enemyMiddleHitImage;
                break;
            case kEnemyBig:
                self.image = imageManger.enemyBigImages[0];
                self.animationImages = imageManger.enemyBigImages;
                self.animationDuration = 0.5f;
                [self startAnimating];
                self.blowupImages = imageManger.enemyBigBlowupImages;
                self.hitImage = imageManger.enemyBigHitImage;
                break;
        }
        
        [self setFrame:CGRectMake(0, 0, self.image.size.width, self.image.size.height)];
        [self setCenter:enemy.position];
    }
    
    return self;
}

@end
