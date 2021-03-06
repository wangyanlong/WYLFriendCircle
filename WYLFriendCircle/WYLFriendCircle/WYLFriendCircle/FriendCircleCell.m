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

/**
 先调用了高度计算,在调用layoutSubViews
 */
- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    _cellModel.isFlush = NO;
    [multipleContentV removeGestureRecognizer:linkTapGesture];
    
    if (self.cellModel.contentType == FC_OnlyTextContent) {//如果只有文字,那么只设置文字高度
        
        fcContentView.frame = ({
        
            CGRect tmpRect = fcContentView.frame;
            tmpRect.size.height = _cellModel.textContentHigh;
            tmpRect;
            
        });
        
    }else if (self.cellModel.contentType == FC_OnlyLinkContent || self.cellModel.contentType == FC_TextAndLinkContent){
        
        fcContentView.frame = ({
            
            CGRect tmpRect = fcContentView.frame;
            tmpRect.size.height = LinkViewHight;
            
            if (self.cellModel.contentType == FC_TextAndLinkContent) {
                tmpRect.size.height = self.cellModel.textContentHigh + LinkViewHight;
            }
            
            tmpRect;
            
        });
        
        float multipleContentVPosY = 0;
        
        //如果有文字,设置文字高度,刷新multipleContentVPosY
        if (self.cellModel.contentType == FC_TextAndLinkContent) {
            
            textContentLb.frame = ({
            
                CGRect tmpRect = textContentLb.frame;
                tmpRect.size.height = _cellModel.textContentHigh;
                tmpRect;
                
            });
            
            multipleContentVPosY = CGRectGetMaxY(textContentLb.frame);
            
        }
        
        //通过multipleContentVPosY,改变multipleContentV的frame
        multipleContentV.frame = ({
            CGRect tmpRect = multipleContentV.frame;
            tmpRect.origin.y = multipleContentVPosY;
            tmpRect.size.height = LinkViewHight;
            tmpRect;
        });
        
        //数据植入
        [multipleContentV removeAllSubView];
        [multipleContentV addGestureRecognizer:linkTapGesture];
        multipleContentV.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0  blue:230/255.0  alpha:0.6];

        //链接图标
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
        imageV.image = [UIImage imageNamed:[self.cellModel.linkInfoDict objectForKey:@"img"]];
        [multipleContentV addSubview:imageV];
        
        //链接文字
        UILabel *desContLb = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageV.frame) + 10, 0, multipleContentV.frame.size.width - 50 - 10, 50)];
        desContLb.text = [self.cellModel.linkInfoDict objectForKey:@"text"];
        desContLb.font = [UIFont systemFontOfSize:12];
        desContLb.numberOfLines = 0;
        desContLb.textColor = [UIColor blueColor];
        desContLb.backgroundColor = [UIColor clearColor];
        [multipleContentV addSubview:desContLb];
        
    }else if (self.cellModel.contentType == FC_TextAndPictureContent || self.cellModel.contentType == FC_OnlyPictureContent){
        
        //根据图片高度修改内容区大小,如果有文字加上文字高度
        fcContentView.frame = ({
            
            CGRect tmpRect = fcContentView.frame;
            tmpRect.size.height = self.cellModel.imageContentHigh;
            
            if (_cellModel.contentType == FC_TextAndPictureContent) {
                tmpRect.size.height =  _cellModel.textContentHigh + _cellModel.imageContentHigh;
            }
            
            tmpRect;
            
        });
        
        //根据文字高度位置决定图片高度位置
        float multipleContentVPosY = 0;
        
        if(self.cellModel.contentType == FC_TextAndPictureContent){
            textContentLb.frame = ({
                CGRect tmpRect = textContentLb.frame;
                tmpRect.size.height = _cellModel.textContentHigh;
                tmpRect;
            });
            multipleContentVPosY = CGRectGetMaxY(textContentLb.frame);
        }
        
        multipleContentV.frame = ({
            CGRect tmpRect = multipleContentV.frame;
            tmpRect.origin.y = multipleContentVPosY;
            tmpRect.size.height = _cellModel.imageContentHigh;
            tmpRect;
        });
        
        //数据植入
        [multipleContentV removeAllSubView];
        for (int i = 0; i < self.cellModel.imageAry.count; i++) {
            int line = i/3;
            int row = i%3;
            int gap = 5;
            NSString *imageUrlStr = [self.cellModel.imageAry objectAtIndex:i];
            MyAsyncImageView *imageV = [[MyAsyncImageView alloc] initWithFrame:CGRectMake(row*CellImageHight + row*gap, line*CellImageHight + line*gap, CellImageHight, CellImageHight)];
            
            [imageV loadImageWithURL:imageUrlStr block:^(UIImage *image) {
                
            }];
            
            imageV.tag = i;
            imageV.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGestureR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImge:)];
            [imageV addGestureRecognizer:tapGestureR];
            [multipleContentV addSubview:imageV];
        }
        
    }else if(self.cellModel.contentType == FC_OnlyMovieContent || self.cellModel.contentType == FC_TextAndMovieContent){
        
        fcContentView.frame = ({
            
            CGRect tmpRect = fcContentView.frame;
            
            tmpRect.size.height = MovieViewHight;
            
            if (self.cellModel.contentType == FC_TextAndMovieContent) {
                tmpRect.size.height =  self.cellModel.textContentHigh + MovieViewHight;
            }
            
            tmpRect;
            
        });
        
        float multipleContentVPosY = 0;
        
        //文字
        if(self.cellModel.contentType == FC_TextAndMovieContent){
            textContentLb.frame = ({
                CGRect tmpRect = textContentLb.frame;
                tmpRect.size.height = _cellModel.textContentHigh;
                tmpRect;
            });
            multipleContentVPosY = CGRectGetMaxY(textContentLb.frame);
        }
        
        // 视频
        multipleContentV.frame = ({
            CGRect tmpRect = multipleContentV.frame;
            tmpRect.origin.y = multipleContentVPosY;
            tmpRect.size.height = MovieViewHight;
            tmpRect;
        });
        
        [multipleContentV removeAllSubView];

        MovieView *movieView = [[MovieView alloc] initWithFrame:CGRectMake(0, 0, MovieViewHight, MovieViewHight)];
        movieView.movieURLStr = self.cellModel.moviePath;
        [multipleContentV addSubview:movieView];
        movieView.backgroundColor = [UIColor colorWithRed:(arc4random()%255/255.0) green:(arc4random()%255/255.0) blue:(arc4random()%255/255.0) alpha:1];
        
        [movieView asyLoad:^id{
            
            NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
            
            NSURL *url = [[NSURL alloc] initWithString:@"http://www.8pmedu.com/appimage/8pm.mp4"];
            
            AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
            
            AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
            generator.appliesPreferredTrackTransform = YES;
            generator.maximumSize = CGSizeMake(150, 150);
            
            NSError *error = nil;
            CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(10, 10) actualTime:NULL error:&error];
            UIImage *image = [UIImage imageWithCGImage:img];
            
            NSLog(@"视频第一帧");
            return image;
        
        }];
        
    }
    
    // 时间+留言
    fcTimeAndMesView.frame = ({
        CGRect tmpRect = fcTimeAndMesView.frame;
        tmpRect.origin.y = CGRectGetMaxY(fcContentView.frame);;
        tmpRect;
    });
    
    fcTimeLb.text = [self.cellModel.timeStp stringByAppendingString:@"分钟前"];
    
    //点赞内容
    if (self.cellModel.approveContentHigh > 0){
        
        approveView.frame = ({
        
            CGRect tmpRect = approveView.frame;
            tmpRect.origin.y = 0;
            tmpRect.size.height = self.cellModel.approveContentHigh;
            tmpRect;
            
        });
        
        [fcMessageTableV setTableHeaderView:approveView];
    
    }else{
        
        [fcMessageTableV setTableHeaderView:nil];
        
    }
    
    //留言内容,设置在fcTimeAndMesView下面因为approveView是headerView
    fcMessageTableV.frame = ({
        CGRect tmpRect = fcMessageTableV.frame;
        tmpRect.origin.y = CGRectGetMaxY(fcTimeAndMesView.frame);
        tmpRect.size.height = self.cellModel.messageContentHigh + self.cellModel.approveContentHigh;
        tmpRect;
    });
    
}

+ (CGFloat)fcCellHeight:(WYLFCModel*)cellModel{

    CGFloat contentHigh = 0.0f;
    
    if (cellModel.contentType == FC_OnlyTextContent) {
        
        contentHigh = [UIView backLinesInView:ScreenWidth-90 string:cellModel.contentTextStr font:[UIFont systemFontOfSize:14]];
        contentHigh = (contentHigh < 30)?30:contentHigh;
        cellModel.textContentHigh = contentHigh;
        
    }else if(cellModel.contentType == FC_OnlyPictureContent){
        // 只有图片
        NSInteger lineCount = (cellModel.imageAry.count-1)/3 + 1;
        contentHigh = lineCount * CellImageHight + lineCount*5;
        cellModel.imageContentHigh = contentHigh;
    }
    else if(cellModel.contentType == FC_OnlyLinkContent){
        // 只有链接地址
        contentHigh = LinkViewHight;
    }
    else if(cellModel.contentType == FC_TextAndPictureContent){
        
        contentHigh = [UIView backLinesInView:ScreenWidth-90 string:cellModel.contentTextStr font:[UIFont systemFontOfSize:14]];
        contentHigh = (contentHigh < 30)?30:contentHigh;
        cellModel.textContentHigh = contentHigh;
        
        NSInteger lineCount = (cellModel.imageAry.count-1)/3 + 1;
        contentHigh = lineCount * CellImageHight + lineCount*5;
        cellModel.imageContentHigh = contentHigh;
        
        contentHigh = cellModel.textContentHigh + cellModel.imageContentHigh;
    }
    else if(cellModel.contentType == FC_TextAndLinkContent){
        
        contentHigh = [UIView backLinesInView:ScreenWidth-90 string:cellModel.contentTextStr font:[UIFont systemFontOfSize:14]];
        contentHigh = (contentHigh < 30)?30:contentHigh;
        cellModel.textContentHigh = contentHigh;
        
        contentHigh += LinkViewHight;
    }
    else if(cellModel.contentType == FC_OnlyMovieContent){
        contentHigh = MovieViewHight;
    }
    else if(cellModel.contentType == FC_TextAndMovieContent){
        contentHigh = [UIView backLinesInView:ScreenWidth-90 string:cellModel.contentTextStr font:[UIFont systemFontOfSize:14]];
        contentHigh = (contentHigh < 30)?30:contentHigh;
        cellModel.textContentHigh = contentHigh;
        contentHigh += MovieViewHight;
    }
    
    // 点赞 高度
    if (cellModel.approveAry.count > 0) {
        NSMutableString *approveStr = [NSMutableString stringWithString:@"       "];
        [approveStr appendString:[cellModel.approveAry objectAtIndex:0]];
        for (int i = 1; i < cellModel.approveAry.count; i++) {
            [approveStr appendFormat:@",%@",[cellModel.approveAry objectAtIndex:i]];
        }
        cellModel.approveContentStr = approveStr;
        cellModel.approveContentHigh = [UIView backLinesInView:ScreenWidth-90 string:approveStr font:[UIFont systemFontOfSize:12]];
    }else{
        cellModel.approveContentStr  = @"";
        cellModel.approveContentHigh = 0;
    }

    cellModel.messageContentHigh = 0;
    cellModel.cellHighAry = [NSMutableArray array];
    cellModel.cellContentAry = [NSMutableArray array];
    
    for (int i = 0; i < cellModel.messageAry.count; i++) {
        
        NSDictionary *infoDict = [cellModel.messageAry objectAtIndex:i];
        NSMutableString *messageStr = [NSMutableString string];
        int status = [[infoDict objectForKey:@"status"] intValue];
        
        if (status == 0) {
            [messageStr appendFormat:@"楼主回复%@:",[infoDict objectForKey:@"name"]];
        }else if(status == 1){
            [messageStr appendFormat:@"%@回复楼主:",[infoDict objectForKey:@"name"]];
        }
        else if(status == 2){
            [messageStr appendFormat:@"楼主:"];
        }
        else if(status == 3){
            [messageStr appendFormat:@"%@:",[infoDict objectForKey:@"name"]];
        }
        
        [messageStr appendString:[infoDict objectForKey:@"msg"]];
        
        float cellHeightFloat = [UIView backLinesInView:ScreenWidth-90 string:messageStr font:[UIFont systemFontOfSize:12]];
        cellModel.messageContentHigh += cellHeightFloat;
        [cellModel.cellHighAry addObject:[NSNumber numberWithFloat:cellHeightFloat]];
        [cellModel.cellContentAry addObject:messageStr];
        
    }
    
    return CellBaseHight + contentHigh + cellModel.messageContentHigh + cellModel.approveContentHigh;
    
}

#pragma mark - tableview delegate
//留言评论
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cellModel.messageAry.count;
}
// 高度一定缓存
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [[self.cellModel.cellHighAry objectAtIndex:indexPath.row] floatValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CellMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CellMessageCell" owner:nil options:nil] objectAtIndex:0];
    }
    
    [cell messagePro:[self.cellModel.messageAry objectAtIndex:indexPath.row] content:[self.cellModel.cellContentAry objectAtIndex:indexPath.row]];
    cell.tag = indexPath.row;
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CellMessageCell *cell = (CellMessageCell*)[tableView cellForRowAtIndexPath:indexPath];
    if ([_delegate respondsToSelector:@selector(cellSelectSendMessage:subCell:)]) {
        [_delegate cellSelectSendMessage:self subCell:cell];
    }
    
}

#pragma mark - Gesture handle
- (void)tapImge:(UITapGestureRecognizer*)tapGes{
    
    if ([_delegate respondsToSelector:@selector(cellImagePress:images:)]) {
        [_delegate cellImagePress:tapGes.view.tag images:self.cellModel.imageAry];
    }
}

- (void)tapLink:(UITapGestureRecognizer*)tapGes{
    if ([_delegate respondsToSelector:@selector(cellLinkPress:)]) {
        [_delegate cellLinkPress:self.cellModel.linkInfoDict];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
