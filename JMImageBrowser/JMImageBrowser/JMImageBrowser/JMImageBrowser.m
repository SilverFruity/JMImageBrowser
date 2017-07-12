//
//  ImageReaderVC.m
//  SharedGym
//
//  Created by Jiang on 2017/6/1.
//
//

#import <CoreText/CoreText.h>

#import "JMImageBrowser.h"
#import "UIView+JM_Frame.h"

#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"



NSString *const JMImageBrowserCellIdentify = @"JMImageBrowserCell";

@interface JMImageBrowser ()<UICollectionViewDelegate,UICollectionViewDataSource,JMImageBrowserCellDelegate>
@property (nonatomic, strong)UICollectionView *collectionView;
@property (nonatomic, strong)UILabel *indexLB;
@property (nonatomic, strong)NSArray <NSString *>*urls;
@property (nonatomic, copy)CGRect(^rectBlock)(NSUInteger index);
@property (nonatomic, copy)void(^scrollBlock)(NSUInteger index);
@property (nonatomic, assign)NSUInteger currentIndex;
@property (nonatomic, strong)UIImageView *animationView;
@property (nonatomic, strong)UIView *coverView;

@property (nonatomic, strong)id cycleSelf; //自身循环引用
@end

@implementation JMImageBrowser

- (instancetype)initWithUrls:(NSArray *)urls
                       index:(NSUInteger)index
                   rectBlock:(CGRect(^)(NSUInteger index))rectBlock
                 scrollBlock:(void(^)(NSUInteger index))scrollBlock{
    self = [self init];
    _cycleSelf = self;
    _urls = urls;
    _rectBlock = rectBlock;
    _scrollBlock = scrollBlock;
    self.currentIndex = index;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    _collectionView.contentOffset = CGPointMake(layout.itemSize.width * index, 0);
    return self;
}

- (void)setCurrentIndex:(NSUInteger)currentIndex{
    _currentIndex = currentIndex;
    _indexLB.text = [NSString stringWithFormat:@"%lu/%lu",_currentIndex + 1,self.urls.count];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
   if(_hideStatuBar) [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    UIImage *CacheImage = [[SDImageCache sharedImageCache]imageFromCacheForKey:_urls[_currentIndex]];
    [self showAnimation:CacheImage];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(_hideStatuBar) [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.view.backgroundColor = [UIColor blackColor];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        CGFloat viewWidth = self.view.frame.size.width;
        CGFloat viewHeight = self.view.frame.size.height;
        layout.itemSize = CGSizeMake(viewWidth + 20, viewHeight);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0,viewWidth + 20, viewHeight) collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.scrollsToTop = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.contentOffset = CGPointMake(0, 0);
        _collectionView.backgroundColor = [UIColor blackColor];
        NSUInteger cunt = 2;
        _collectionView.contentSize = CGSizeMake(cunt * (self.view.frame.size.width + 20), 0);
        [self.view addSubview:_collectionView];
        [_collectionView registerClass:[JMImageBrowserCell class] forCellWithReuseIdentifier:JMImageBrowserCellIdentify];
        
        _coverView = [[UIView alloc]initWithFrame:self.view.frame];
        _coverView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:_coverView];
        
        _animationView = [[UIImageView alloc]init];
        _animationView.contentMode = UIViewContentModeScaleAspectFill;
        _animationView.clipsToBounds = YES;
        [_coverView addSubview:_animationView];
        
        _indexLB = [[UILabel alloc]init];
        _indexLB.translatesAutoresizingMaskIntoConstraints = NO;
        _indexLB.font = [UIFont systemFontOfSize:14];
        _indexLB.textAlignment = NSTextAlignmentCenter;
        _indexLB.textColor = [UIColor whiteColor];
        [self.view addSubview:_indexLB];
        
        NSLayoutConstraint *labelCenterXCons = [NSLayoutConstraint constraintWithItem:_indexLB attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0];
        NSLayoutConstraint *labelBottomCons = [NSLayoutConstraint constraintWithItem:_indexLB attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-20];
        [self.view addConstraint:labelCenterXCons];
        [self.view addConstraint:labelBottomCons];
    }
    return self;
}
- (void)showAnimation:(UIImage *)image{
    if (image == nil) {
        _coverView.hidden = YES;
        return;
    }
    
    CGRect fromViewWindowRect = _rectBlock(_currentIndex);
    _animationView.image = image;
    _animationView.frame = fromViewWindowRect;
    [UIView animateWithDuration:0.3 animations:^{
        _animationView.JM_Size = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width/image.size.width * image.size.height);
        _animationView.center = self.view.JM_BoundsCenter;
    } completion:^(BOOL finished) {
        _coverView.hidden = YES;
    }];
}
- (void)dismissAniamtionWithImage:(UIImage *)image{
    if (image == nil) {
        [self.view removeFromSuperview];
        _cycleSelf = nil;
        return;
    }
    CGRect endWindowRect = _rectBlock(_currentIndex);
    _coverView.hidden = NO;
    _animationView.image = image;
    JMImageBrowserCell *cell = [_collectionView visibleCells].firstObject;
    _animationView.frame = [cell convertRect:cell.imageView.frame toView:nil];
    [UIView animateWithDuration:0.3 animations:^{
        _animationView.frame = endWindowRect;
    } completion:^(BOOL finished) {
        _coverView.hidden = YES;
        [self.view removeFromSuperview];
        _cycleSelf = nil;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _urls.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    JMImageBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:JMImageBrowserCellIdentify forIndexPath:indexPath];
    cell.imageView.image = nil;
    [cell recoverSubviews];
    cell.delegate = self;
    NSURL *url = [NSURL URLWithString:_urls[indexPath.row]];
    cell.currentURL = url;
    __weak typeof(cell) weakCell = cell;
    [[SDWebImageManager sharedManager] loadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        double progress = ((double)receivedSize) / ((double)expectedSize);
        dispatch_async(dispatch_get_main_queue(), ^{
            //判断该进度是否是当前cell要显示的图片的下载进度
            if (![weakCell.currentURL.absoluteString isEqualToString:targetURL.absoluteString]){
                return;
            }
            cell.progress = progress;
        });
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        //判断此时是否是当前cell要显示的图片
        if (![weakCell.currentURL.absoluteString isEqualToString:imageURL.absoluteString] && cacheType == SDImageCacheTypeNone){
            return;
        }
        
        if ([imageURL.absoluteString hasSuffix:@".gif"]) {
            cell.imageView.animatedImage = [[FLAnimatedImage alloc]initWithAnimatedGIFData:data];
        }else{
            cell.imageView.image = image;
        }
        cell.progress = 0;
        cell.imageView.JM_Height = image.size.height * ( [UIScreen mainScreen].bounds.size.width / image.size.width);
        cell.imageView.JM_Width = [UIScreen mainScreen].bounds.size.width;
        cell.imageView.center = cell.contentView.JM_BoundsCenter;
    }];
    return cell;
}

- (void)JMImageBrowserCell:(JMImageBrowserCell *)cell singleTap:(UITapGestureRecognizer *)singleTap{
    UIImage *CacheImage = [[SDImageCache sharedImageCache]imageFromCacheForKey:_urls[_currentIndex]];
    [self dismissAniamtionWithImage:CacheImage];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    NSUInteger index = round(scrollView.contentOffset.x / layout.itemSize.width);
    if (_currentIndex != index) {
        self.currentIndex = index;
        if (_scrollBlock) {
            _scrollBlock(index);
        }
        
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

#pragma mark - JMImageBrowserCell
@implementation JMImageBrowserCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentSize = self.JM_Size;
        _scrollView.maximumZoomScale = 2.0;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.minimumZoomScale = 1;
        _scrollView.multipleTouchEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
        [_scrollView addGestureRecognizer:singleTap];
        [self.contentView addSubview:_scrollView];
        
        _imageView = [[FLAnimatedImageView alloc] init];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        [_scrollView addSubview:_imageView];
        CGFloat layerWidth = 50;
        CGFloat layerX = (self.JM_Width - layerWidth) / 2;
        CGFloat layerY = (self.JM_Height - layerWidth) / 2;
        _progressLayer = [JMImageBrowserProgrsssLayer layer];
        _progressLayer.frame = CGRectMake(layerX, layerY, layerWidth, layerWidth);
        _progressLayer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:_progressLayer];
    }
    return self;
}
- (void)setProgress:(double)progress{
    //当为0时，不会有动画
    if (progress != 0) {
        CABasicAnimation *progressAni = [CABasicAnimation animationWithKeyPath:@"progress"];
        if (progress >= 0.95 || _progress == 0) {
            progressAni.duration = 0.1; //95%以上时，加快动画速度
        }else{
            progressAni.duration = 5 * (progress - _progress);
        }
        progressAni.fromValue = @(_progress);
        progressAni.toValue = @(progress);
        progressAni.fillMode = kCAFillModeForwards;
        progressAni.removedOnCompletion = YES;
        [self.progressLayer addAnimation:progressAni forKey:@"progressAnimation"];
    }
    _progress = progress >= 1.0 ? 1.00 : progress;
    self.progressLayer.progress = _progress;
}

- (void)singleTap:(UITapGestureRecognizer *)recognizer{
    if ([self.delegate respondsToSelector:@selector(JMImageBrowserCell:singleTap:)]) {
        [self.delegate JMImageBrowserCell:self singleTap:recognizer];
    }
}

- (void)recoverSubviews {
    [_scrollView setZoomScale:1.0 animated:NO];
    _imageView.animatedImage = [[FLAnimatedImage alloc]init];
    _imageView.JM_Size = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * 0.666);
    _imageView.center = self.contentView.JM_BoundsCenter;
}


- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshImageContainerViewCenter];
}

//让imageView始终居中
- (void)refreshImageContainerViewCenter {
    CGFloat offsetX = (_scrollView.JM_Width > _scrollView.contentSize.width) ? ((_scrollView.JM_Width - _scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (_scrollView.JM_Height > _scrollView.contentSize.height) ? ((_scrollView.JM_Height - _scrollView.contentSize.height) * 0.5) : 0.0;
    self.imageView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX, _scrollView.contentSize.height * 0.5 + offsetY);
}
@end


#pragma mark - JMImageBrowserProgrsssLayer
@implementation JMImageBrowserProgrsssLayer
//判断当前指定的属性key改变是否需要重新绘制。
+ (BOOL)needsDisplayForKey:(NSString *)key{
    if ([key isEqualToString:@"progress"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

//CoreAnimation动画时的帧，用于获取自定义变量progress
- (instancetype)initWithLayer:(JMImageBrowserProgrsssLayer *)layer{
    if (self = [super initWithLayer:layer]) {
        self.progress = layer.progress;
    }
    return self;
}

//设置progress也直接进行重绘
- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    [self setNeedsDisplay];
}

//实现绘制
- (void)drawInContext:(CGContextRef)ctx{
    if (_progress == 0) {
        return;
    }
    CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] colorWithAlphaComponent:0.9].CGColor);
    CGFloat centerX  = self.frame.size.width * .5;
    CGPoint center = CGPointMake(centerX, centerX);
    CGFloat pathWidth = 5;
    CGFloat radius = centerX - pathWidth;
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = pathWidth;
    
    //进度条
    CGFloat ratio = 0;
    if (_progress <= 0.25) {
        ratio = 2 * _progress + 1.5;
    }else{
        ratio = 2 * _progress - 0.5 - 0.0001;
    }
    [path addArcWithCenter:center radius:radius startAngle:M_PI * 1.5 endAngle:M_PI * ratio clockwise:YES];
    CGContextSetLineWidth(ctx, pathWidth);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextAddPath(ctx, path.CGPath);
    CGContextStrokePath(ctx);
    
    //百分比
    UIFont *font = [UIFont systemFontOfSize:12];
    NSString *numberText = [NSString stringWithFormat:@"%.0f%%",_progress * 100];
    NSDictionary *attribute = @{NSFontAttributeName:font,
                                NSForegroundColorAttributeName:[UIColor whiteColor]};
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:numberText attributes:attribute];
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, self.frame.size.height);
    CGContextScaleCTM(ctx, 1.0f, -1.0f);
    CGSize textSize = CGSizeMake( [numberText sizeWithAttributes:attribute].width, (NSUInteger)font.lineHeight + 1);
    CGFloat textY  = self.frame.size.height * 0.5 - textSize.height * 0.5;
    CGFloat textX = self.frame.size.width * 0.5 - textSize.width * 0.5;
    UIBezierPath *textPath = [UIBezierPath bezierPathWithRect:CGRectMake(textX, textY, textSize.width, textSize.height)];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(string));
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, string.length), textPath.CGPath, NULL);
    CTFrameDraw(frame, ctx);
    CFRelease(framesetter);
    CFRelease(frame);
}


@end





