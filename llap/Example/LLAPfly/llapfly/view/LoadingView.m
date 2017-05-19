//
//  LoadingView.m
//  llapfly
//
//  Created by KeSun on 16/7/16.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSString *imageName = [NSString stringWithFormat:@"images.bundle/loading0.png"];
        UIImage *image = [UIImage imageNamed:imageName];
        UIImageView *imageView =[[UIImageView alloc]initWithImage:image];
    
        [imageView setCenter:self.center];
        [self addSubview:imageView];
        
    }
    return self;
    
}

@end
