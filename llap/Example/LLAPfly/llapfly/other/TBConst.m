//
//  TBConst.m
//  llapfly
//
//  Created by KeSun on 16/7/12.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import "TBConst.h"

@implementation TBConst

+ (void)saveScore:(NSString *)score
{
    [[NSUserDefaults standardUserDefaults] setObject:score forKey:@"gameScore"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)score
{
     return [[NSUserDefaults standardUserDefaults] objectForKey:@"gameScore"];
}
@end
