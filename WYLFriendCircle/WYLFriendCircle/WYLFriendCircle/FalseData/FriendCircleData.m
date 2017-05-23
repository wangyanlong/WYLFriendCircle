//
//  FriendCircleData.m
//  WYLFriendCircle
//
//  Created by wyl on 2017/5/22.
//  Copyright © 2017年 wyl. All rights reserved.
//

#import "FriendCircleData.h"

static NSInteger kAllPage = 0;
static NSMutableArray *imageContentAry;
static NSMutableArray *textContentAry;

@implementation FriendCircleData

+(NSDictionary *)backFriendCircleData:(NSInteger)currentPage{
 
    if (currentPage == 0) {
        kAllPage = 0;
    }
    
    NSMutableDictionary *backDict = [NSMutableDictionary dictionary];
    
    NSMutableArray *dataAry = [NSMutableArray array];
    
    for (int i = 0; i < 15; i++) {
        
    }
    
    return nil;

}

@end
