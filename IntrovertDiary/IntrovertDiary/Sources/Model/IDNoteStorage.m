//
//  IDNoteStorage.m
//  IntrovertDiary
//
//  Created by Www Www on 8/20/17.
//  Copyright © 2017 Michael Tishchenko. All rights reserved.
//

#import "IDNoteStorage.h"
#import "IDNote.h"
#import "IDNoteExpirationTracker.h"

@interface IDNoteStorage ()

@property (nonatomic, strong) NSMutableArray<IDNote *> *mutableNotes;
@property (nonatomic, strong) NSMutableArray<NSValue *> *observers;
@property (nonatomic, strong) IDNoteExpirationTracker *expirationTracker;

@property (nonatomic) BOOL tracking;

@end

@implementation IDNoteStorage

+ (IDNoteStorage *)sharedStorage
{
	static IDNoteStorage *sharedStorage = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken,
	^{
		sharedStorage = [IDNoteStorage new];
	});
	
	return sharedStorage;
}

- (NSMutableArray<IDNote *> *)mutableNotes
{
	if (nil == _mutableNotes)
	{
		_mutableNotes = [NSMutableArray new];
		[self restoreNotes];
	}
	
	return _mutableNotes;
}

- (NSMutableArray *)observers
{
	if (nil == _observers)
	{
		_observers = [NSMutableArray new];
	}
	
	return _observers;
}

- (IDNoteExpirationTracker *)expirationTracker
{
	if (nil == _expirationTracker)
	{
		_expirationTracker = [IDNoteExpirationTracker new];
	}
	
	return _expirationTracker;
}

- (void)addObserver:(id<IDNoteStorageObserver>)delegate
{
	@synchronized(self)
	{
		NSValue *observer = [NSValue valueWithNonretainedObject:delegate];
		if (![self.observers containsObject:observer])
		{
			[self.observers addObject:observer];
		}
	}
}

- (void)removeObserver:(id<IDNoteStorageObserver>)delegate
{
	@synchronized(self)
	{
		NSValue *observer = [NSValue valueWithNonretainedObject:delegate];
		if ([self.observers containsObject:observer])
		{
			[self.observers removeObject:observer];
		}
	}
}

- (NSArray<IDNote *> *)notes
{
	return self.mutableNotes;
}

- (void)saveNote:(IDNote *)note
{
	BOOL isNewNote = NO;
	@synchronized (self)
	{
		if (![self.mutableNotes containsObject:note])
		{
			[self.mutableNotes addObject:note];
			isNewNote = YES;
		}
	}
	[self persistNotes];
	
	if (isNewNote && self.tracking)
	{
		__weak __typeof(self) weakSelf = self;
		[self.expirationTracker trackNoteExpiration:note withHandler:
		^{
			for (NSValue *observerValue in weakSelf.observers)
			{
				id<IDNoteStorageObserver> observer = observerValue.nonretainedObjectValue;
				if ([observer respondsToSelector:@selector(noteStorage:didTrackExpirationOfNote:)])
				{
					[(id<IDNoteStorageObserver>)observer noteStorage:weakSelf
								didTrackExpirationOfNote:note];
				}
			}
		}];
	}
	@synchronized(self)
	{
		for (NSValue *observerValue in self.observers)
		{
			id<IDNoteStorageObserver> observer = observerValue.nonretainedObjectValue;
			if (isNewNote)
			{
				if ([observer respondsToSelector:@selector(noteStorage:didAddNote:)])
				{
					[(id<IDNoteStorageObserver>)observer noteStorage:self didAddNote:note];
				}
			}
			else
			{
				if ([observer respondsToSelector:@selector(noteStorage:didUpdateNote:)])
				{
					[(id<IDNoteStorageObserver>)observer noteStorage:self
								didUpdateNote:note];
				}
			}
		}
	}
}

- (void)removeNote:(IDNote *)note
{
	@synchronized(self)
	{
		[self.mutableNotes removeObject:note];
	}
	[note cleanUp];
	[self.expirationTracker stopTrackingForNote:note];
	
	@synchronized(self)
	{
		for (NSValue *observerValue in self.observers)
		{
			id<IDNoteStorageObserver> observer = observerValue.nonretainedObjectValue;
			if ([observer respondsToSelector:@selector(noteStorage:didDeleteNote:)])
			{
				[(id<IDNoteStorageObserver>)observer noteStorage:self
							didDeleteNote:note];
			}
		}
	}
	[self persistNotes];
}

- (void)persistNotes
{
	NSArray *notes = nil;
	@synchronized(self)
	{
		notes = [NSArray arrayWithArray:self.mutableNotes];
	}
	if (notes.count > 0)
	{
		[[NSUserDefaults standardUserDefaults] setObject:
					[NSKeyedArchiver archivedDataWithRootObject:notes]
					forKey:@"notes"];
	}
	else
	{
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"notes"];
	}
}

- (void)restoreNotes
{
	NSData *data = [[NSUserDefaults standardUserDefaults]
				objectForKey:@"notes"];
	if (nil != data)
	{
		@synchronized(self)
		{
			[self.mutableNotes addObjectsFromArray:[NSKeyedUnarchiver
						unarchiveObjectWithData:data]];
		}
	}
}

- (void)startTrackingNoteExpiration
{
	if (!self.tracking)
	{
		self.tracking = YES;
		
		NSArray *notes = nil;
		@synchronized(self)
		{
			notes = [NSArray arrayWithArray:self.notes];
		}
		
		for (IDNote *note in notes)
		{
			__weak __typeof(self) weakSelf = self;
			[self.expirationTracker trackNoteExpiration:note withHandler:
			^{
				for (NSValue *observerValue in weakSelf.observers)
				{
					id<IDNoteStorageObserver> observer = observerValue.nonretainedObjectValue;
					if ([observer respondsToSelector:@selector(noteStorage:didTrackExpirationOfNote:)])
					{
						[(id<IDNoteStorageObserver>)observer noteStorage:weakSelf
									didTrackExpirationOfNote:note];
					}
				}
			}];
		}
	}
}

- (void)stopTrackingNoteExpiration
{
	if (self.tracking)
	{
		self.tracking = NO;
		
		[self.expirationTracker stopTracking];
	}
}

@end
