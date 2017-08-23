//
//  IDNote.m
//  IntrovertDiary
//
//  Created by Www Www on 8/20/17.
//  Copyright © 2017 Michael Tishchenko. All rights reserved.
//

#import "IDNote.h"

@interface IDNote ()

@property (nonatomic, strong) NSString *picturePath;

@end

@implementation IDNote

@synthesize picture = _picture;

- (instancetype)init
{
	if (self = [super init])
	{
		_creationDate = [NSDate date];
	}
	
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super init])
	{
		_creationDate = [aDecoder decodeObjectForKey:@"creationDate"];
		_text = [aDecoder decodeObjectForKey:@"text"];
		_picturePath = [aDecoder decodeObjectForKey:@"picturePath"];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.creationDate forKey:@"creationDate"];
	[aCoder encodeObject:self.text forKey:@"text"];
	[aCoder encodeObject:self.picturePath forKey:@"picturePath"];
}

- (void)setPicture:(UIImage *)picture
{
	if (picture != _picture)
	{
		[self cleanUp];
		_picture = picture;
		NSURL *documentDirectoryURL = [[[NSFileManager defaultManager]
					URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]
					firstObject];
		
		NSURL *pictureURL = [[documentDirectoryURL URLByAppendingPathComponent:
					[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:@"png"];
		
		[UIImagePNGRepresentation(picture) writeToURL:pictureURL atomically:YES];
		self.picturePath = pictureURL.path;
	}
}

- (UIImage *)picture
{
	if (nil == _picture && nil != self.picturePath)
	{
		NSURL *pictureURL = [NSURL fileURLWithPath:self.picturePath];
		_picture = [UIImage imageWithContentsOfFile:pictureURL.path];
	}
	
	return _picture;
}

- (void)cleanUp
{
	if (nil != self.picturePath)
	{
		NSString *path = self.picturePath;
		dispatch_async(dispatch_get_global_queue(0, 0),
		^{
			[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
		});
	}
}

@end
