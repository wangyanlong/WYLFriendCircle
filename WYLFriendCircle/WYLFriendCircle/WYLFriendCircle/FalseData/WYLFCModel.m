//
//  WYLFCModel.m
//  WYLFriendCircle
//
//  Created by wyl on 2017/5/23.
//  Copyright © 2017年 wyl. All rights reserved.
//

#import "WYLFCModel.h"

@implementation WYLFCModel

+(NSString *)setMessageDict:(NSDictionary *)messageDict{
    
    int status = [[messageDict objectForKey:@"from"] intValue];
    NSMutableString *messageStr = [NSMutableString string];
    
    if (status == 0) {
        [messageStr appendFormat:@"楼主回复%@:",[messageDict objectForKey:@"name"]];
    }else if(status == 1){
        [messageStr appendFormat:@"%@回复楼主:",[messageDict objectForKey:@"name"]];
    }
    else if(status == 2){
        [messageStr appendFormat:@"楼主:"];
    }
    else if(status == 3){
        [messageStr appendFormat:@"%@:",[messageDict objectForKey:@"name"]];
    }
    [messageStr appendString:[messageDict objectForKey:@"msg"]];
    return messageStr;
    
}

@end
