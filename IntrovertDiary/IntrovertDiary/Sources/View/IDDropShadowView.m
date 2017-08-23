//
//  IDDropShadowView.m
//  IntrovertDiary
//
//  Created by Www Www on 8/7/16.
//  Copyright © 2017 Michael Tishchenko. All rights reserved.
//

#import "IDDropShadowView.h"

@implementation IDDropShadowView

- (instancetype)init
{
	self = [super init];
	
	if (nil != self)
	{
		[self setup];
	}
	
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	
	if (nil != self)
	{
		[self setup];
	}
	
	return self;
}

- (void)setup
{
	self.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
	self.layer.shadowOffset = self.shadowOffset;
	self.layer.shadowOpacity = 0.5;
	self.layer.shadowRadius = 8;
}

- (CGSize)shadowOffset
{
	return CGSizeMake(0, 0);
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
	self.layer.shadowOffset = shadowOffset;
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity
{
	self.layer.shadowOpacity = shadowOpacity;
}

@end

@implementation IDDownDropShadowView

- (CGSize)shadowOffset
{
	return CGSizeMake(0, 5);
}

@end
