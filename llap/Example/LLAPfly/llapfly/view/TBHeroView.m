//
//  TBHeroView.m
//  llapfly
//
//  Created by KeSun on 16/7/16.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import "TBHeroView.h"

@implementation TBHeroView

- (instancetype)initWithImages:(NSArray *)images
{
    self = [super initWithImage:images[0]];
    if (self) {
        
        [self setAnimationImages:images];
        [self setAnimationDuration:1.0];
        [self startAnimating];

    }
    return self;
}

@end
