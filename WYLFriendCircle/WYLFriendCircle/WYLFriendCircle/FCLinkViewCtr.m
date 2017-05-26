//
//  FCLinkViewCtr.m
//  WeiXinFriendCircle
//
//  Created by sunyong on 17/1/2.
//  Copyright © 2017年 @八点钟学院. All rights reserved.
//

#import "FCLinkViewCtr.h"

@interface FCLinkViewCtr ()

@end


@implementation FCLinkViewCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.urlStr]];
    [theWebView loadRequest:request];
}




@end
