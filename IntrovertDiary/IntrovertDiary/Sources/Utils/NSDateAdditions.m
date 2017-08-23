//
//  NSDate.m
//  IntrovertDiary
//
//  Created by Www Www on 8/20/17.
//  Copyright © 2017 Michael Tishchenko. All rights reserved.
//

#import "NSDateAdditions.h"

@implementation NSDate (Note)

- (NSString *)localizableMonth
{
	NSDateComponents *components = [[NSCalendar currentCalendar]
				components:NSCalendarUnitMonth fromDate:self];
	NSDictionary *monthMap =
				@{
					@(1) : NSLocalizedString(@"cJanuary", @""),
					@(2) : NSLocalizedString(@"cFebruary", @""),
					@(3) : NSLocalizedString(@"cMarch", @""),
					@(4) : NSLocalizedString(@"cApril", @""),
					@(5) : NSLocalizedString(@"cMay", @""),
					@(6) : NSLocalizedString(@"cJune", @""),
					@(7) : NSLocalizedString(@"cJuly", @""),
					@(8) : NSLocalizedString(@"cAugust", @""),
					@(9) : NSLocalizedString(@"cSeptember", @""),
					@(10) : NSLocalizedString(@"cOctember", @""),
					@(11) : NSLocalizedString(@"cNovember", @""),
					@(12) : NSLocalizedString(@"cDecember", @"")
				};
	
	return monthMap[@([components month])];
}

- (NSString *)localizableDate
{
	NSDateFormatter *formatter = [NSDateFormatter new];
	[formatter setDateFormat:@"dd / hh:mm"];
	
	return [NSString stringWithFormat:@"%@ %@", self.localizableMonth,
				[formatter stringFromDate:self]];
}

@end
