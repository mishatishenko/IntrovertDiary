//
//  IDNoteExpirationTracker.h
//  IntrovertDiary
//
//  Created by Www Www on 8/21/17.
//  Copyright © 2017 Michael Tishchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IDNote;

@interface IDNoteExpirationTracker : NSObject

- (void)trackNoteExpiration:(IDNote *)note withHandler:(void (^)())handler;
- (void)stopTrackingForNote:(IDNote *)note;
- (void)stopTracking;

@end
