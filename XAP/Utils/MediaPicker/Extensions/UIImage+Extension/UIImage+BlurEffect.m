//
//  UIImage+BlurEffect.m
//  XAP
//
//  Created by Zhang Yi on 18/12/2015.
//  Copyright © 2015 JustTwoDudes. All rights reserved.
//

#import "UIImage+BlurEffect.h"
#import <CoreImage/CoreImage.h>
@implementation UIImage (BlurEffect)


- (UIImage *)blurredWithWhiteAlpha:(CGFloat)alpha
{
    return [self blurredWithColor:[UIColor whiteColor] alpha:alpha];
}

- (nullable UIImage *)blurredWithBlackAlpha:(CGFloat)alpha{
    return [self blurredWithColor:[UIColor blackColor] alpha:alpha];
}

- (nullable UIImage *)blurredWithColor:(UIColor *)color alpha:(CGFloat)alpha{
    return [self blurredWithColor:color alpha:alpha radius:5.0];
}

- (nullable UIImage *)blurredWithColor:(UIColor *)color alpha:(CGFloat)alpha radius:(CGFloat)radius {
    CIImage *inputImage = [CIImage imageWithCGImage:self.CGImage];
    
    if (inputImage == nil) {
        return nil;
    }
    
    // Apply Affine-Clamp filter to stretch the image so that it does not
    // look shrunken when gaussian blur is applied
    CGAffineTransform transform = CGAffineTransformIdentity;
    CIFilter *clampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    if (clampFilter == nil){
        return nil;
    }
    [clampFilter setValue:inputImage forKey:@"inputImage"];
    [clampFilter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    // Apply gaussian blur filter with radius of 10
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
    [gaussianBlurFilter setValue:clampFilter.outputImage forKey: @"inputImage"];
    [gaussianBlurFilter setValue:@(radius) forKey:@"inputRadius"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:gaussianBlurFilter.outputImage fromRect:[inputImage extent]];
    
    // Set up output context.
    CGSize size = self.size;
    UIGraphicsBeginImageContext(size);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    
    // Invert image coordinates
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, CGRectMake(0, 0, size.width, size.height), cgImage);
    
    // Apply white tint
    CGContextSaveGState(outputContext);
    
    CGContextSetFillColorWithColor(outputContext, [color colorWithAlphaComponent:alpha].CGColor);
    CGContextFillRect(outputContext, CGRectMake(0, 0, size.width, size.height));
    CGContextRestoreGState(outputContext);
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}
@end
