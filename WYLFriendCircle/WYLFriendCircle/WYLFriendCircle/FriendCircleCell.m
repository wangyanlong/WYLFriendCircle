//
//  FriendCircleCell.m
//  WYLFriendCircle
//
//  Created by wyl on 2017/5/25.
//  Copyright © 2017年 wyl. All rights reserved.
//

#import "FriendCircleCell.h"
#import "MovieView.h"
#import "CellMessageCell.h"
#import "MyAsyncImageView.h"
#import "UIView+FC.h"

#define CellBaseHight 70
#define CellImageHight 70
#define LinkViewHight 50
#define MovieViewHight 150

@implementation FriendCircleCell

- (void)setCellModel:(WYLFCModel *)cellModel{
    
    _cellModel = cellModel;
    fcNameLb.text = cellModel.name;
    
    if (cellModel.contentType == FC_OnlyTextContent) {
        
        textContentLb.hidden    = NO;
        multipleContentV.hidden = YES;
        textContentLb.text = cellModel.contentTextStr;
        [multipleContentV removeAllSubView];
        
    }else if (cellModel.contentType == FC_OnlyPictureContent || self.cellModel.contentType == FC_OnlyLinkContent || self.cellModel.contentType == FC_OnlyMovieContent){
        
        textContentLb.hidden = YES;
        multipleContentV.hidden = NO;
        
    }else if (self.cellModel.contentType == FC_TextAndLinkContent || self.cellModel.contentType == FC_TextAndMovieContent || self.cellModel.contentType == FC_TextAndPictureContent){
        
        textContentLb.hidden = NO;
        multipleContentV.hidden = NO;
        textContentLb.text = cellModel.contentTextStr;
        
    }
    
    if (self.cellModel.approveContentHigh > 0) {
        approveNameLb.text = self.cellModel.approveContentStr;
    }else{
        approveNameLb.text = @"";
    }
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [approveView removeFromSuperview];
    linkTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLink:)];
    
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    _cellModel.isFlush = NO;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
