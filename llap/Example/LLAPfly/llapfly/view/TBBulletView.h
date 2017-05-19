//
//  TBBulletView.h
//  llapfly
//
//  Created by KeSun on 16/7/16.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TBBullet;

@interface TBBulletView : UIImageView

@property(strong, nonatomic) TBBullet *bullet;

- (id)initWithImage:(UIImage *)image bullet:(TBBullet *)bullet;

@end
