//
//  UIView+FC.h
//  WYLFriendCircle
//
//  Created by wyl on 2017/5/25.
//  Copyright © 2017年 wyl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FC)

- (void)removeAllSubView;

+ (float)backLinesInView:(CGFloat)viewWidth string:(NSString *)contentS font:(UIFont *)font;

@end
