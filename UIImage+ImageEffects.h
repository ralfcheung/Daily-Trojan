//
//  UIImage+ImageEffects.h
//  Daily Trojan
//
//  Created by Ralf Cheung on 6/22/13.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageEffects)


- (UIImage *)applyLightEffect;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

- (UIImage*)scaleToSize:(CGSize)size;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

@end
