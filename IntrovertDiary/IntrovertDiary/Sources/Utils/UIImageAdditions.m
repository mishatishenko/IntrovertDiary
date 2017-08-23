//
//  UIImageAdditions.m
//  IntrovertDiary
//
//  Created by Www Www on 8/21/17.
//  Copyright © 2017 Michael Tishchenko. All rights reserved.
//

#import "UIImageAdditions.h"

@implementation UIImage (Scaling)

- (UIImage *)downscaledImageToSize:(CGFloat)size
{
	CGSize imageSize = self.size;
	
	CGFloat maxDimension = MAX(imageSize.width, imageSize.height);
	
	UIImage *downscaledImage = self;
	if (maxDimension > size)
	{
		CGFloat aspectRatio = size / maxDimension;
		CGSize newSize =CGSizeMake(imageSize.width * aspectRatio,
					imageSize.height * aspectRatio);
		
		UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
		[self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
		downscaledImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	
	return downscaledImage;
}

@end
