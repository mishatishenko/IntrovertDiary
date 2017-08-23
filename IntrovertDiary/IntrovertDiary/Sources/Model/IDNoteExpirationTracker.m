//
//  IDNoteExpirationTracker.m
//  IntrovertDiary
//
//  Created by Www Www on 8/21/17.
//  Copyright © 2017 Michael Tishchenko. All rights reserved.
//

#import "IDNoteExpirationTracker.h"
#import "IDNote.h"

static const NSTimeInterval kExpirationTime = 300;//86400;

@interface IDNoteHolder : NSObject

@property (nonatomic, strong) IDNote *note;
@property (nonatomic, copy) void (^handler)();
@property (nonatomic, strong) NSTimer *timer;

- (void)invalidate;

@end

@implementation IDNoteHolder

- (void)invalidate
{
	[self.timer invalidate];
	self.handler = nil;
	self.note = nil;
}

@end

@interface IDNoteExpirationTracker ()

@property (nonatomic, strong) NSMutableArray<IDNoteHolder *> *holders;

@end

@implementation IDNoteExpirationTracker

- (NSMutableArray<IDNoteHolder *> *)holders
{
	if (nil == _holders)
	{
		_holders = [NSMutableArray new];
	}
	
	return _holders;
}

- (void)trackNoteExpiration:(IDNote *)note withHandler:(void (^)())handler
{
	if (nil == [self holderForNote:note])
	{
		NSTimeInterval intervalToExpire = [[note.creationDate
					dateByAddingTimeInterval:kExpirationTime] timeIntervalSinceNow];
		if (intervalToExpire > 0)
		{
			IDNoteHolder *holder = [IDNoteHolder new];
			holder.note = note;
			holder.handler = handler;
			holder.timer = [NSTimer scheduledTimerWithTimeInterval:intervalToExpire target:self
						selector:@selector(timerDidFired:) userInfo:@{@"note" : note}
					repeats:NO];
			
			[self.holders addObject:holder];
		}
		else if (nil != handler)
		{
			handler();
		}
	}
}

- (void)stopTrackingForNote:(IDNote *)note
{
	IDNoteHolder *holder = [self holderForNote:note];
	if (nil != holder)
	{
		[self.holders removeObject:holder];
		[holder invalidate];
	}
}

- (void)stopTracking
{
	for (IDNoteHolder *holder in self.holders)
	{
		[holder invalidate];
	}
	
	[self.holders removeAllObjects];
}

- (void)timerDidFired:(NSTimer *)timer
{
	IDNoteHolder *holder = [self holderForNote:timer.userInfo[@"note"]];
	if (nil != holder)
	{
		[self.holders removeObject:holder];
		
		if (nil != holder.handler)
		{
			holder.handler();
		}
	}
}

- (IDNoteHolder *)holderForNote:(IDNote *)note
{
	IDNoteHolder *holder = nil;
	
	for (IDNoteHolder *existedHolder in self.holders)
	{
		if (existedHolder.note == note)
		{
			holder = existedHolder;
			break;
		}
	}
	
	return holder;
}

@end
