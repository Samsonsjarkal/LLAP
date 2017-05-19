//
//  TBGameModel.m
//  llapfly
//
//  Created by KeSun on 16/7/10.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import "TBGameModel.h"

@implementation TBGameModel
+ (id)gameModelWithArea:(CGRect)gameArea heroSize:(CGSize)heroSize
{
    TBGameModel *m = [[TBGameModel alloc]init];
    
    m.gameArea = gameArea;

    m.hero = [TBhero heroWithSize:heroSize gameAera:gameArea];
    
    m.score = 0;
    
    return m;
}
- (TBEnemy *)createEnemyWithType:(TBEnemyType)type size:(CGSize)size
{
    return [TBEnemy enemyWithType:type size:size gameArea:self.gameArea];
}

@end
