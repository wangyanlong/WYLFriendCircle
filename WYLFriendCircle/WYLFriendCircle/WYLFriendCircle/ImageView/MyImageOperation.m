//
//  MyImageOperation.m
//  MyFirendImageView
//
//  Created by 王老师 on 2017/5/19.
//  Copyright © 2017年 wyl. All rights reserved.
//

#import "MyImageOperation.h"

typedef BOOL(^cancelBlock)();

static NSCache *imageCache;
static NSMutableDictionary *operationTaskInfoDict;
static NSMutableArray *sameTaskCacheAry;
static NSLock *taskLock;

@interface MyImageOperation ()

@property (nonatomic, strong)NSData *netData;

@end

@implementation MyImageOperation

@synthesize finished = _finished;

/**
 initialize 如果不考虑子类的情况下,只会生成一次,通常在这个方法里会生成一些静态变量,当做所有使用这个类独有的静态属性
 */
+ (void)initialize{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        imageCache = [NSCache new];
        operationTaskInfoDict = [NSMutableDictionary new];
        sameTaskCacheAry = [NSMutableArray new];
        taskLock = [NSLock new];
        
    });
    
}

- (void)start{

    //获得要加载view的观察值
    atomic_size_t value = self.imageV.monitorValue;
    typeof(self) __weakSelf = self;
    
    /*
     这个是否cancel的判断很有特点,它利用了block的特性,如果在block里传入一个只,如果不加__block,他会被拷贝一份,当拷贝的值和获取的值不一致的时候,那么证明要加载的那个view里要显示的内容已经改变了
     */
    cancelBlock isCancelBlock = ^BOOL() {
    
        BOOL cancel = NO;
        
        //如果view没有了,则取消
        if (!__weakSelf.imageV) {
            
            cancel = YES;
        
        }else{
            
            //如果指针指向的url并且观察值不一致时,取消
            //其中weakSelf.imageV.urlStr已经被拷贝了,而self.urlStr的指针是指向imageV的url,如果imageV的url改变了,那么会和拷贝的URL不一致
            if (__weakSelf.imageV.urlStr != self.urlStr && value != __weakSelf.imageV.monitorValue) {
                cancel = YES;
            }
            
        }
        
        return cancel;
        
    };
    
    //这个判断是判断是否要加载相同的url,也就是说两个view有可能加载同一个url
    if ([operationTaskInfoDict objectForKey:_urlStr]) {
        
        NSLog(@"重复了");
        
        [taskLock lock];
        
        //如果加载相同的,用NSValue保存imageV,这样的方式可以避免强引用
        NSValue *taskValue = [NSValue valueWithNonretainedObject:self.imageV];
        
        [sameTaskCacheAry addObject:taskValue];
        
        [taskLock unlock];
        
        [self finishStatus];
        
        return;
        
    }else{
        
        //如果不是重复加载,那么放入dict,表明正在执行任务
        [operationTaskInfoDict setObject:@"" forKey:_urlStr];
        
    }
    
    UIImage *bitmapImage = nil;
    
    //如果内存中有,从内存中取
    if ([imageCache objectForKey:_urlStr]) {
        
        bitmapImage = [imageCache objectForKey:_urlStr];
        
        if (!isCancelBlock()) {
            [self loadImageInMainThread:bitmapImage];
        }
        
    }else{
        
        //如果内存中没有,从磁盘中去
        NSData *imageData = [self findUrlDataInLocal];
        
        if (imageData) {
            
            bitmapImage = [UIImage imageWithData:imageData];
            
            if (!isCancelBlock()) {
                [self loadImageInMainThread:bitmapImage];
            }
            
        }else{//如果磁盘没有,网络加载
            
            if (!isCancelBlock()) {
                //在这里用了指针的指针,这样就可以直接把bitmapimage通过指针的指针,赋值,而不需要再写block了
                [self synLoadImageNet:isCancelBlock bitmapImage:&bitmapImage];
            }
            
        }
        
    }
    
    [self removeTaskAndExcuteTask:bitmapImage];
    [self finishStatus];
}

- (void)removeTaskAndExcuteTask:(UIImage *)bitmapImage{

    NSMutableArray *deleteTaskAry = [NSMutableArray new];
    NSMutableArray *excuteTaskAry = [NSMutableArray new];
    
    [taskLock lock];
    
    /*
     这个方法也很巧妙,sameTaskCacheAry,装着所有operation当时判断正在执行相同任务的imageV(NSValue保存着的imageV)
     如果imageV消失了,那么不执行
     如果这个operation也在执行相同的任务,那么证明这个operation正在加载的image是那个imageV也要加载的url
     那么把bitmap加载到那个imageV上
     */
    
    for (int i = 0; i < sameTaskCacheAry.count; i++) {
        
        NSValue *taskV = sameTaskCacheAry[i];
        MyAsyncImageView *imageV = taskV.nonretainedObjectValue;
        
        if (!imageV) {
            [deleteTaskAry addObject:taskV];
        }else{
            
            if ([imageV.urlStr isEqualToString:self.urlStr]) {
                [excuteTaskAry addObject:taskV];
            }
            
        }
        
    }
    
    for (int i = 0; i < deleteTaskAry.count; i++) {
        [sameTaskCacheAry removeObject:deleteTaskAry[i]];
    }
    
    for (int i = 0; i < excuteTaskAry.count; i++) {
        [sameTaskCacheAry removeObject:excuteTaskAry[i]];
    }
    [taskLock unlock];

    for (int i = 0; i < excuteTaskAry.count; i++) {
        
        NSValue *taskV = excuteTaskAry[i];
        MyAsyncImageView *imageV = taskV.nonretainedObjectValue;
        
        //如果imageV存在,并且和这个operation正在加载的view不是一个view,那么赋值
        if (imageV && ![imageV isEqual:self.imageV]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                imageV.layer.contents = (__bridge id)bitmapImage.CGImage;// bitmap
            });        }
        
    }
    
    [deleteTaskAry removeAllObjects];
    [excuteTaskAry removeAllObjects];

}


/**
 这个方法也很奇妙,用了指针的指针,这样就可以不写block了
 */
- (void)synLoadImageNet:(cancelBlock)isCancelBlock bitmapImage:(UIImage**)bitmapImage{

    NSURL *url = [NSURL URLWithString:_urlStr];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    
    typeof(self) __weakSelf = self;
    
    NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       
        NSHTTPURLResponse *httpRespone = (NSHTTPURLResponse *)response;
        if (error || [httpRespone statusCode] == 404) {
            NSLog(@"网络错误error %@",error);
        }else{
            __weakSelf.netData = data;
        }
        
        dispatch_semaphore_signal(sem);
        
    }];
    
    [task resume];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    if (self.netData) {
        
        //如果有数据,同时放入内存和磁盘
        *bitmapImage = [self bitmapStyleImageFromImage:[UIImage imageWithData:self.netData]];
        [imageCache setObject:*bitmapImage forKey:_urlStr];
        [self saveImageData:UIImageJPEGRepresentation(*bitmapImage, 1)];
        
    }
    
    if (!isCancelBlock()) {
        [self loadImageInMainThread:*bitmapImage];
    }
    
}

- (void)saveImageData:(NSData*)imageData{

    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)firstObject];
    filePath = [filePath stringByAppendingPathComponent:_urlStr];
    [imageData writeToFile:filePath atomically:YES];
    
}

- (UIImage *)bitmapStyleImageFromImage:(UIImage*)netImage{
    
    CGImageRef imageRef = netImage.CGImage;
    
    size_t width = CGImageGetWidth(imageRef)/[UIScreen mainScreen].scale;
    size_t height = CGImageGetHeight(imageRef)/[UIScreen mainScreen].scale;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    CGContextTranslateCTM(contextRef, 0, height);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef backImageRef = CGBitmapContextCreateImage(contextRef);
    
    UIImage *bitmapImage = [UIImage imageWithCGImage:backImageRef scale:[UIScreen mainScreen].scale orientation:netImage.imageOrientation];
    CFRelease(backImageRef);
    
    UIGraphicsEndImageContext();
    
    return bitmapImage;
}

- (void)finishStatus{

    [self willChangeValueForKey:@"isFinish"];
    _finished = YES;
    [operationTaskInfoDict removeObjectForKey:_urlStr];
    [self didChangeValueForKey:@"isFinish"];
    
}

- (NSData *)findUrlDataInLocal{
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    filePath = [filePath stringByAppendingPathComponent:_urlStr];
    return [NSData dataWithContentsOfFile:filePath];
}

- (void)loadImageInMainThread:(UIImage *)bitmapImage{

    typeof(self) __weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        if (__weakSelf.imageV) {
            __weakSelf.imageV.layer.contents = (__bridge id)bitmapImage.CGImage;
        }
        
    });
    
}

@end
