//
//  FCImageViewCtr.h
//  WeiXinFriendCircle
//
//  Created by sunyong on 17/1/2.
//  Copyright © 2017年 @八点钟学院. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCImageViewCtr : UIViewController{
    
    IBOutlet UIScrollView *theScorllView;
    IBOutlet UIPageControl *thePageContrl;
}

@property(nonatomic, assign)NSInteger startIndex;
@property(nonatomic, strong)NSArray *imagAry;

@end
