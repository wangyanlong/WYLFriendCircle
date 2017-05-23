//
//  WYLFCModel.h
//  WYLFriendCircle
//
//  Created by wyl on 2017/5/23.
//  Copyright © 2017年 wyl. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,FCCellContentType) {

    FC_OnlyTextContent = 0,//文字
    FC_OnlyPictureContent = 1,//图片
    FC_OnlyLinkContent = 2,//链接
    FC_OnlyMovieContent = 3,//视频
    FC_TextAndPictureContent = 4,//文字+图片
    FC_TextAndLinkContent = 5,//文字+链接
    FC_TextAndMovieContent = 6,//文字+视频
    
};

@interface WYLFCModel : NSObject

@property (nonatomic, strong) NSString  *name;
@property (nonatomic, strong) NSString  *protraitPath;
@property (nonatomic, assign) FCCellContentType contentType;
@property (nonatomic, strong) NSString  *contentTextStr;

@end
