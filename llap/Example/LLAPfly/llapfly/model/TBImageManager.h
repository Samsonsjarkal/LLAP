//
//  TBImageManager.h
//  llapfly
//
//  Created by KeSun on 16/7/10.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface TBImageManager : NSObject

+ (instancetype)shareManager;

#pragma mark pause button
//pause image
@property (nonatomic, strong) UIImage *pauseImage;
//pause hl image
@property (nonatomic, strong) UIImage *pauseHLImage;
#pragma mark start button
//start button
@property (nonatomic, strong) UIImage *startImage;
//start hl button
@property (nonatomic, strong) UIImage *startHLImage;

#pragma mark background picture
@property (strong, nonatomic) UIImage *bgImage;
#pragma mark logo picture
@property (strong, nonatomic) UIImage *logoImage;
#pragma mark hero pictrue
@property (strong, nonatomic) NSArray *heroFlyImages;
@property (strong, nonatomic) NSArray *heroBlowupImages;

#pragma mark bullet picture
@property (strong, nonatomic) UIImage *bullteNormalImage;
@property (strong, nonatomic) UIImage *bullteEnhancedImage;

#pragma mark enemy picture
@property (strong, nonatomic) UIImage *enemySmallImage;
@property (strong, nonatomic) NSArray *enemySmallBlowupImages;
@property (strong, nonatomic) UIImage *enemyMiddleImage;
@property (strong, nonatomic) NSArray *enemyMiddleBlowupImages;
@property (strong, nonatomic) UIImage *enemyMiddleHitImage;
@property (strong, nonatomic) NSArray *enemyBigImages;
@property (strong, nonatomic) NSArray *enemyBigBlowupImages;
@property (strong, nonatomic) UIImage *enemyBigHitImage;


@end
