//
//  UIImage+BlurEffect.h
//  XAP
//
//  Created by Zhang Yi on 18/12/2015.
//  Copyright © 2015 JustTwoDudes. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIImage (BlurEffect)
- (nullable UIImage *)blurredWithWhiteAlpha:(CGFloat)alpha;
- (nullable UIImage *)blurredWithBlackAlpha:(CGFloat)alpha;
- (nullable UIImage *)blurredWithColor:(UIColor *)color alpha:(CGFloat)alpha;
- (nullable UIImage *)blurredWithColor:(UIColor *)color alpha:(CGFloat)alpha radius:(CGFloat)radius;
@end
NS_ASSUME_NONNULL_END
