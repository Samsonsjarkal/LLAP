//
//  TBBulletView.m
//  llapfly
//
//  Created by KeSun on 16/7/16.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import "TBBulletView.h"
#import "TBBullet.h"

@implementation TBBulletView

- (id)initWithImage:(UIImage *)image bullet:(TBBullet *)bullet
{
    self = [super initWithImage:image];
    
    if (self) {
        self.bullet = bullet;
    }
    
    return self;
}
@end
