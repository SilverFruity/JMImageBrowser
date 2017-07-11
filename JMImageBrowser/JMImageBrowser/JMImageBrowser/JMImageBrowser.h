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

//动画Layer
@interface JMImageBrowserProgrsssLayer : CALayer
@property(nonatomic,assign)CGFloat progress;
@end

@interface JMImageBrowserCell:UICollectionViewCell<UIScrollViewDelegate>
@property (nonatomic, assign) double progress;
@property (nonatomic, strong) JMImageBrowserProgrsssLayer *progressLayer;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) FLAnimatedImageView  *imageView;
@property (nonatomic, strong) NSURL *currentURL;
@property (nonatomic, weak) id <JMImageBrowserCellDelegate> delegate;
- (void)recoverSubviews;
@end

@interface JMImageBrowser : UIViewController
- (instancetype)initWithUrls:(NSArray *)urls
                       index:(NSUInteger)index
                   rectBlock:(CGRect(^)(NSUInteger index))rectBlock
                 scrollBlock:(nullable void(^)(NSUInteger index))scrollBlock;
@end

NS_ASSUME_NONNULL_END


