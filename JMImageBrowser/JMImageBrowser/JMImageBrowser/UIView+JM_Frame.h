//
//  UIView+JM_Frame.h
//  JMImageBrower
//
//  Created by Jiang on 2017/7/12.
//  Copyright © 2017年 Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (JM_Frame)
@property (nonatomic, assign)CGFloat JM_Height;
@property (nonatomic, assign)CGFloat JM_Width;
@property (nonatomic, assign)CGSize  JM_Size;
@property (nonatomic, assign)CGFloat JM_X;
@property (nonatomic, assign)CGFloat JM_Y;
@property (nonatomic, assign)CGPoint JM_Origin;
@property (nonatomic, assign)CGFloat JM_CenterX;
@property (nonatomic, assign)CGFloat JM_CenterY;
@property (nonatomic, assign, readonly)CGPoint JM_BoundsCenter;
@end
