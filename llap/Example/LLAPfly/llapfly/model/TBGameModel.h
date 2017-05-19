//
//  TBGameModel.h
//  llapfly
//
//  Created by KeSun on 16/7/10.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBhero.h"
#import "TBEnemy.h"
#import "TBEnemyView.h"
#import <UIKit/UIKit.h>
@interface TBGameModel : NSObject

#pragma mark - game area
@property (assign, nonatomic) CGRect gameArea;

#pragma mark - game score
@property (assign, nonatomic) NSInteger score;


#pragma mark - hero
@property (strong, nonatomic) TBhero *hero;

#pragma mark - enemy


+ (id)gameModelWithArea:(CGRect)gameArea heroSize:(CGSize)heroSize;
#pragma mark - create enemy
- (TBEnemy *)createEnemyWithType:(TBEnemyType)type size:(CGSize)size;

@end
