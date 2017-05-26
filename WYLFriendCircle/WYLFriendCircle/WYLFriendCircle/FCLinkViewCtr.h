//
//  FCLinkViewCtr.h
//  WeiXinFriendCircle
//
//  Created by sunyong on 17/1/2.
//  Copyright © 2017年 @八点钟学院. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCLinkViewCtr : UIViewController{
    IBOutlet UIWebView *theWebView;
}

@property (nonatomic, strong)NSString *urlStr;

@end
