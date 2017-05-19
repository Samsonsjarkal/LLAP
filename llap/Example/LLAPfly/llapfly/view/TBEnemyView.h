//
//  TBEnemyView.h
//  llapfly
//
//  Created by KeSun on 16/7/16.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBImageManager.h"
@class TBEnemy;
@interface TBEnemyView : UIImageView
@property (strong, nonatomic) NSArray *blowupImages;
@property (strong, nonatomic) UIImage *hitImage;
@property (strong, nonatomic) TBEnemy *enemy;


- (id)initWithEnemy:(TBEnemy *)enemy imageManager:(TBImageManager *)imageManger;
@end
