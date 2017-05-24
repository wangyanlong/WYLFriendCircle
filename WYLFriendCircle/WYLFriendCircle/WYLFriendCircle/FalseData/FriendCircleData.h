//
//  FriendCircleData.h
//  WYLFriendCircle
//
//  Created by wyl on 2017/5/22.
//  Copyright © 2017年 wyl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendCircleData : NSObject

+ (NSArray *)imageUrlFromFile;

// 返回朋友圈数据 currentPage当前页， next是否有下一个页
+ (NSDictionary*)backFriendCircleData:(NSInteger)currentPage;

@end
