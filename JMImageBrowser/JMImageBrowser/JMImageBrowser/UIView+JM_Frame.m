//
//  UIView+JM_Frame.m
//  JMImageBrower
//
//  Created by Jiang on 2017/7/12.
//  Copyright © 2017年 Jiang. All rights reserved.
//

#import "UIView+JM_Frame.h"

@implementation UIView (JM_Frame)
- (CGSize)JM_Size{
    return self.frame.size;
}
- (void)setJM_Size:(CGSize)JM_Size{
    self.JM_Width = JM_Size.width;
    self.JM_Height = JM_Size.height;
}
- (CGFloat)JM_Height{
    return CGRectGetHeight(self.frame);
}
- (void)setJM_Height:(CGFloat)JM_Height{
    self.frame = CGRectMake(self.JM_X, self.JM_Y, self.JM_Width, JM_Height);
}

- (CGFloat)JM_Width{
    return self.frame.size.width;
}
- (void)setJM_Width:(CGFloat)JM_Width{
    self.frame = CGRectMake(self.JM_X, self.JM_Y, JM_Width, self.JM_Height);
}

- (CGPoint)JM_Origin{
    return self.frame.origin;
}
- (void)setJM_Origin:(CGPoint)JM_Origin{
    self.frame = CGRectMake(JM_Origin.x, JM_Origin.y, self.JM_Width, self.JM_Height);
}

- (CGFloat)JM_X{
    return self.frame.origin.x;
}

- (void)setJM_X:(CGFloat)JM_X{
    self.frame = CGRectMake(JM_X, self.JM_Y, self.JM_Width, self.JM_Height);
}

- (CGFloat)JM_Y{
    return self.frame.origin.y;
}
- (void)setJM_Y:(CGFloat)JM_Y{
    self.frame = CGRectMake(self.JM_X, JM_Y, self.JM_Width, self.JM_Height);
}

- (CGFloat)JM_CenterX{
    return self.center.x;
}

- (void)setJM_CenterX:(CGFloat)JM_CenterX{
    self.center = CGPointMake(JM_CenterX, self.JM_CenterY);
}

- (CGFloat)JM_CenterY{
    return self.center.y;
}
- (void)setJM_CenterY:(CGFloat)JM_CenterY{
    self.center = CGPointMake(self.JM_CenterX, JM_CenterY);
}


- (CGPoint)JM_BoundsCenter{
    return CGPointMake(self.JM_Width * 0.5, self.JM_Height * 0.5);
}

@end
