//
//  TBBackGroundView.m
//  llapfly
//
//  Created by KeSun on 16/7/16.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import "TBBackGroundView.h"
#import "TBImageManager.h"
#import "UIView+Extension.h"
#import "TBConst.h"
@interface TBBackGroundView ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIImageView *bg1;
@property (nonatomic, strong) UIImageView *bg2;
@end

@implementation TBBackGroundView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _bg1 = [[UIImageView alloc] initWithFrame:frame];
        _bg2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, -frame.size.height-5, frame.size.width, frame.size.height+10)];
        _bg1.image = [TBImageManager shareManager].bgImage;
        _bg2.image = [TBImageManager shareManager].bgImage;
        [self addSubview:_bg1];
        [self addSubview:_bg2];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(bgMove) userInfo:nil repeats:YES];
            [_timer fire];
            
        });
        
    }
    return self;
}


- (void)bgMove
{
    [UIView animateWithDuration:0.5 animations:^{
        [_bg1 setY:_bg1.frame.origin.y+2];
        [_bg2 setY:_bg2.frame.origin.y+2];
    }];
    
    if (_bg1.y >= kScreenHeight-5) {
        [_bg1 setY:-kScreenHeight];
    }
    if (_bg2.y >= kScreenHeight-5) {
        [_bg2 setY:-kScreenHeight];
    }
}

- (void)changeBg:(UIImage *)image
{
    self.bg1.image = image;
    self.bg2.image = image;
}
- (void)stopMove
{
    [self.timer setFireDate:[NSDate distantFuture]];
}

-(void)startMove
{
    [self.timer setFireDate:[NSDate distantPast]];
}
@end
