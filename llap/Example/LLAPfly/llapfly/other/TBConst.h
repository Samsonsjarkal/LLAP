//
//  TBConst.h
//  llapfly
//
//  Created by KeSun on 16/7/12.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)

@interface TBConst : NSObject

+ (void)saveScore:(NSString *)score;
+ (NSString *)score;

@end
