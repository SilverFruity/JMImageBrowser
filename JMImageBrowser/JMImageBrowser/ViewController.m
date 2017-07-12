//
//  ViewController.m
//  JMImageBrowser
//
//  Created by Jiang on 2017/7/12.
//  Copyright © 2017年 Jiang. All rights reserved.
//


#import "ViewController.h"
#import "UIImageView+WebCache.h"
#import "JMImageBrowser.h"

NSUInteger const kItemCountOfSecion = 3;
static NSString *const cellIdentify = @"UICollectionViewCell";

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, weak)UICollectionView *collectionView;
@property (nonatomic, strong)NSArray <NSArray <NSString *>*> *data;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/default",paths.firstObject];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:nil];
    [SDWebImageManager sharedManager].imageCache.maxMemoryCountLimit = 0;
    
    self.data = @[
                  @[@"http://wx4.sinaimg.cn/mw690/68611fd2gy1fhfwzkbzwmj20xc0p0adv.jpg",@"http://wx4.sinaimg.cn/mw690/4be9bfb5gy1fhg48uu1e6j20qo0qowjx.jpg"],
                  
                  @[@"http://wx3.sinaimg.cn/mw690/68611fd2gy1fhfwzkpfscj20xc0p00wq.jpg",@"http://wx2.sinaimg.cn/mw690/c0788b86ly1fhfy97c1a4j20xc0p043l.jpg"],
                  
                  @[@"http://wx2.sinaimg.cn/mw690/68611fd2gy1fhfwzlygbej20xc0p0tdp.jpg",@"http://wx3.sinaimg.cn/mw690/c0788b86ly1fhfy97lkwoj20xc0p043j.jpg"],
                  
                  @[@"http://wx1.sinaimg.cn/mw690/a2b70395ly1fgb9ek9dtrg209g09ex6r.gif",@"http://wx4.sinaimg.cn/mw690/677e4af2ly1fhfx06kr3kg20b405k7wi.gif"],
                  
                  @[@"http://wx4.sinaimg.cn/mw690/a2b70395ly1fgb9ep60wlg209q0627wi.gif",@"http://wx1.sinaimg.cn/mw690/e9d0cb55gy1fhewtkf58ng20b4069hdv.gif"],
                  
                  @[@"http://wx4.sinaimg.cn/mw690/a2b70395ly1fgb9ep60wlg209q0627wi.gif",@"http://wx4.sinaimg.cn/mw690/006ppXykly1fhg0z3ww5sg308u07bnpd.gif"],
                  
                  @[@"http://wx1.sinaimg.cn/mw690/006r5bk0ly1fhfz1svgusj30j60y3wox.jpg",@"http://wx3.sinaimg.cn/mw690/6e1fdf79gy1fhfz2cyj16j207t085q3d.jpg"]
                  ];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UICollectionView *collectionView = [self getCollectionViewWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellIdentify];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    NSInteger numberOfSecion = (_data.count - 1) / kItemCountOfSecion + 1;
    return numberOfSecion;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger itemCount = _data.count / kItemCountOfSecion == section ? _data.count % kItemCountOfSecion : kItemCountOfSecion;
    return itemCount;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentify forIndexPath:indexPath];
    NSUInteger index = kItemCountOfSecion * indexPath.section + indexPath.row;
    NSURL *url = [NSURL URLWithString:self.data[index].firstObject];
    if (cell.contentView.subviews.count == 0) {
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [cell.contentView addSubview:imageView];
        imageView.frame = cell.contentView.bounds;
        [imageView sd_setImageWithURL:url];
        return cell;
    }
    UIImageView *imageView = cell.contentView.subviews.firstObject;
    cell.contentView.backgroundColor = [UIColor lightGrayColor];
    [imageView sd_setImageWithURL:url];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger selectIndex = kItemCountOfSecion * indexPath.section + indexPath.row;
    NSMutableArray *originalArr = [NSMutableArray array];
    for (NSArray *arr in self.data) {
        [originalArr addObject:arr.lastObject];
    }
    JMImageBrowser *vc = [[JMImageBrowser alloc]initWithUrls:originalArr index:selectIndex rectBlock:^CGRect(NSUInteger index) {
        //将index转为NSIndexPath
        NSIndexPath *path = [NSIndexPath indexPathForRow:index % kItemCountOfSecion inSection:index / kItemCountOfSecion];
        //获取在indexPath处的cell
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:path];
        CGRect cellWindowRect = [cell convertRect:cell.bounds toView:nil];
        return cellWindowRect;
        
    } scrollBlock:^(NSUInteger index) {
        //当浏览视器的图片Index超出当前collectionView可见cell时，collectionView滚动到最新的index
        NSIndexPath *path = [NSIndexPath indexPathForRow:index % kItemCountOfSecion inSection:index / kItemCountOfSecion];
        if (![collectionView.indexPathsForVisibleItems containsObject:path]) {
            [collectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
    }];
    [self.view.window addSubview:vc.view];
}

- (UICollectionView *)getCollectionViewWithFrame:(CGRect)frame{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    
    CGFloat padding = 3;
    
    CGFloat sectionLeftAndRightMargin = 5;
    
    UIEdgeInsets sectionInset = UIEdgeInsetsMake(padding * 0.5 , sectionLeftAndRightMargin, padding * 0.5, sectionLeftAndRightMargin);
    CGFloat itemWidth = (frame.size.width - padding * (kItemCountOfSecion - 1) - sectionInset.left - sectionInset.right) / kItemCountOfSecion;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    flowLayout.minimumLineSpacing = padding;
    flowLayout.minimumInteritemSpacing = padding;
    flowLayout.sectionInset = sectionInset;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:frame collectionViewLayout:flowLayout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    return collectionView;
}


@end

