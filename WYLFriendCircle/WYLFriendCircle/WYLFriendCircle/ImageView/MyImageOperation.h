//
//  MyImageOperation.h
//  MyFirendImageView
//
//  Created by 王老师 on 2017/5/19.
//  Copyright © 2017年 wyl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyAsyncImageView.h"

typedef void(^ImageFinishBlock)(UIImage *image);

@interface MyImageOperation : NSOperation

@property (nonatomic,copy)ImageFinishBlock finishBlock;

@property (nonatomic, weak)MyAsyncImageView *imageV;

@property (nonatomic, strong)NSString *urlStr;

@end
