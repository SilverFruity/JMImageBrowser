//
//  ImageReaderVC.h
//  SharedGym
//
//  Created by Jiang on 2017/6/1.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FLAnimatedImageView;
@class JMImageBrowserCell;

@protocol JMImageBrowserCellDelegate <NSObject>
- (void)JMImageBrowserCell:(JMImageBrowserCell *)cell singleTap:(UITapGestureRecognizer *)singleTap;
@end

//进度条，百分比Layer
@interface JMImageBrowserProgrsssLayer : CALayer
@property(nonatomic,assign)CGFloat progress;
@end

@interface JMImageBrowserCell:UICollectionViewCell<UIScrollViewDelegate>
@property (nonatomic, weak) id <JMImageBrowserCellDelegate> delegate;
///进度
@property (nonatomic, assign) double progress;
@property (nonatomic, strong) JMImageBrowserProgrsssLayer *progressLayer;
@property (nonatomic, strong) FLAnimatedImageView  *imageView;
///cell当前展示的图片URL
@property (nonatomic, strong) NSURL *currentURL;
@property (nonatomic, strong) UIScrollView *scrollView;
- (void)recoverSubviews;
@end

@interface JMImageBrowser : UIViewController

@property (nonatomic, copy, nullable)void(^handleError)(NSError *error);
/**
 初始化方法
 
 @param urls 图片地址数组
 @param index 选中的位置
 @param rectBlock 显示和隐藏动画需要的frame
 @param scrollBlock 滚动到显示以外的Cell的回调
 @return JMImageBrowser
 */
- (instancetype)initWithUrls:(NSArray <NSString *>*)urls
                       index:(NSUInteger)index
                   rectBlock:(CGRect(^)(NSUInteger index))rectBlock
                 scrollBlock:(nullable void(^)(NSUInteger index))scrollBlock;
@end

NS_ASSUME_NONNULL_END


