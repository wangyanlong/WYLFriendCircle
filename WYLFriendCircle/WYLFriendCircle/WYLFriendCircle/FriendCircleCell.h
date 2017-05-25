//
//  FriendCircleCell.h
//  WYLFriendCircle
//
//  Created by wyl on 2017/5/25.
//  Copyright © 2017年 wyl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendCircleData.h"
#import "WYLFCModel.h"
#import "CellMessageCell.h"

@class FriendCircleCell;

@protocol FriendCircleCellDelegate <NSObject>

- (void)cellImagePress:(NSInteger)index images:(NSArray *)imageAry;
- (void)cellLinkPress:(NSDictionary *)linkInfo;
- (void)cellSelectSendMessage:(FriendCircleCell *)cell subCell:(CellMessageCell *)subCell;

@end

@interface FriendCircleCell : UITableViewCell<UITableViewDelegate, UITableViewDataSource>{
    
    IBOutlet UIImageView *fcPortImageV; // 图像
    IBOutlet UILabel *fcNameLb;// 名字
    
    IBOutlet UIView *fcContentView;// 内容（文字，图片，视频，链接）
    IBOutlet UILabel *textContentLb; // 文字内容
    IBOutlet UIView *multipleContentV;//  图片或视频/链接
    
    IBOutlet UIView *fcTimeAndMesView;//
    IBOutlet UILabel *fcTimeLb;
    IBOutlet UITableView *fcMessageTableV;//留言
    
    IBOutlet UIView *approveView;//点赞view
    IBOutlet UILabel *approveNameLb;//点赞名字label
    
    UITapGestureRecognizer *linkTapGesture;
    
}

@property (nonatomic, strong)IBOutlet UIButton *fcMessageBt;
@property (nonatomic, strong)WYLFCModel *cellModel;

@property (nonatomic, weak)id <FriendCircleCellDelegate>delegate;
+ (CGFloat)fcCellHeight:(FriendCircleCell*)fcCellModel;

@end
