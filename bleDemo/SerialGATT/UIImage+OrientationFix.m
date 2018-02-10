//
//  UIImage+OrientationFix.m
//  SpookCam
//
//  Created by Jack Wu on 2014-03-18.
//
//

#import "UIImage+OrientationFix.h"

@implementation UIImage (OrientationFix)

- (UIImage *)imageWithFixedOrientation {
  if (self.imageOrientation == UIImageOrientationUp) return self;
  
  UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
  [self drawInRect:(CGRect){0, 0, self.size}];
  UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return normalizedImage;
}

@end
