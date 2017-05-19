//
//  TBImageManager.m
//  llapfly
//
//  Created by KeSun on 16/7/10.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import "TBImageManager.h"

@implementation TBImageManager

+ (instancetype)shareManager
{
    static TBImageManager *_ImageManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _ImageManager = [[TBImageManager alloc] init];
    });
    return _ImageManager;
}

#pragma mark - 
- (UIImage *)loadImageWithBundle:(NSBundle *)bundle imageName:(NSString *)imageName
{
    NSString *path = [bundle pathForResource:imageName ofType:@"png"];
    
    return [UIImage imageWithContentsOfFile:path];
}

#pragma mark
- (NSArray *)loadImagesWithBundle:(NSBundle *)bundle format:(NSString *)format count:(NSInteger)count
{
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:count];
    
    for (NSInteger i = 1; i <= count; i++) {
        NSString *imageName = [NSString stringWithFormat:format, i];
        
        UIImage *image = [self loadImageWithBundle:bundle imageName:imageName];
        
        [arrayM addObject:image];
    }
    
    return arrayM;
}

#pragma mark
- (id)init
{
    self = [super init];
    
    if (self) {
        // load picutre resource
        NSString *bundlePath = [[[NSBundle mainBundle]bundlePath]stringByAppendingPathComponent:@"images.bundle"];
        //build images.bundle
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        
        //background
        self.bgImage = [self loadImageWithBundle:bundle imageName:@"background"];
        
        self.logoImage = [self loadImageWithBundle:bundle imageName:@"njuorign"];
        //hero
        self.heroFlyImages = [self loadImagesWithBundle:bundle
                                                 format:@"hero_fly_%d"
                                                  count:2];
        self.heroBlowupImages = [self loadImagesWithBundle:bundle format:@"hero_blowup_%d" count:4];
        
        //bullet
        self.bullteNormalImage = [self loadImageWithBundle:bundle imageName:@"bullet1"];
        self.bullteEnhancedImage = [self loadImageWithBundle:bundle imageName:@"bullet2"];
        
        //small enemy
        self.enemySmallImage = [self loadImageWithBundle:bundle imageName:@"enemy1_fly_1"];
        self.enemySmallBlowupImages = [self loadImagesWithBundle:bundle format:@"enemy1_blowup_%d" count:4];
        
        //middle enemy
        self.enemyMiddleImage = [self loadImageWithBundle:bundle imageName:@"enemy3_fly_1"];
        self.enemyMiddleHitImage = [self loadImageWithBundle:bundle imageName:@"enemy3_hit_1"];
        self.enemyMiddleBlowupImages = [self loadImagesWithBundle:bundle format:@"enemy3_blowup_%d" count:4];
        
        //big enemy
        self.enemyBigImages = [self loadImagesWithBundle:bundle format:@"enemy2_fly_%d" count:2];
        self.enemyBigHitImage = [self loadImageWithBundle:bundle imageName:@"enemy2_hit_1"];
        self.enemyBigBlowupImages = [self loadImagesWithBundle:bundle format:@"enemy2_blowup_%d" count:7];
        
        //button
        self.pauseImage = [self loadImageWithBundle:bundle imageName:@"BurstAircraftPause"];
        self.pauseHLImage = [self loadImageWithBundle:bundle imageName:@"BurstAircraftPauseHL"];
        self.startImage = [self loadImageWithBundle:bundle imageName:@"BurstAircraftStart"];
        self.startHLImage = [self loadImageWithBundle:bundle imageName:@"BurstAircraftStartHL"];
    }
    
    return self;
}


@end
