//
//  IDNoteStorage.h
//  IntrovertDiary
//
//  Created by Www Www on 8/20/17.
//  Copyright © 2017 Michael Tishchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IDNote;
@protocol IDNoteStorageObserver;

@interface IDNoteStorage : NSObject

+ (IDNoteStorage *)sharedStorage;

@property (nonatomic, readonly) NSArray<IDNote *> *notes;

- (void)addObserver:(id<IDNoteStorageObserver>)delegate;
- (void)removeObserver:(id<IDNoteStorageObserver>)delegate;

- (void)saveNote:(IDNote *)note;
- (void)removeNote:(IDNote *)note;

- (void)startTrackingNoteExpiration;
- (void)stopTrackingNoteExpiration;

@end

@protocol IDNoteStorageObserver <NSObject>

@optional
- (void)noteStorage:(IDNoteStorage *)sender didDeleteNote:(IDNote *)note;
- (void)noteStorage:(IDNoteStorage *)sender didAddNote:(IDNote *)note;
- (void)noteStorage:(IDNoteStorage *)sender didUpdateNote:(IDNote *)note;

- (void)noteStorage:(IDNoteStorage *)sender
			didTrackExpirationOfNote:(IDNote *)note;

@end
