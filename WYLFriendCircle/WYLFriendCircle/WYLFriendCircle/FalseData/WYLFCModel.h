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

@property (nonatomic, strong) NSString  *name;//名字
@property (nonatomic, strong) NSString  *protraitPath;//头像
@property (nonatomic, assign) FCCellContentType contentType;//数据类型
@property (nonatomic, strong) NSString  *contentTextStr;//文字描述
@property (nonatomic, strong) NSArray   *imageAry;//图片
@property (nonatomic, strong) NSString  *moviePath;//视频
@property (nonatomic, strong) NSDictionary  *linkInfoDict;//链接
@property (nonatomic, strong) NSMutableArray    *messageAry;//评论全部属性
@property (nonatomic, strong) NSString  *timeStp;//时间
@property (nonatomic, strong) NSMutableArray    *approveAry;//点赞
@property (nonatomic, assign) BOOL isFlush;//是否刷新
@property (nonatomic, assign) float imageContentHigh;//图片gap度
@property (nonatomic, assign) float textContentHigh;//文本高度
@property (nonatomic, assign) float approveContentHigh;//点赞高度
@property (nonatomic, assign) float messageContentHigh;//留言高度

@property (nonatomic, strong) NSString  *approveContentStr;//点赞内容
@property (nonatomic, strong) NSMutableArray *cellHighAry;//每个留言cell高度数组
@property (nonatomic, strong) NSMutableArray *cellContentAry;//每个留言cell的内容数组

+ (NSString *)setMessageDict:(NSDictionary *)messageDict;

@end
