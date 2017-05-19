//
//  TBLogoView.m
//  llapfly
//
//  Created by KeSun on 16/7/16.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import "TBLogoView.h"

@implementation TBLogoView

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        self.contentMode = UIViewContentModeLeft;
    }
    return self;
}

@end
