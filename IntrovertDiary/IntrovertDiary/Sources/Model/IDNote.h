//
//  IDNote.h
//  IntrovertDiary
//
//  Created by Www Www on 8/20/17.
//  Copyright © 2017 Michael Tishchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IDNote : NSObject <NSCoding>

@property (nonatomic, strong) UIImage *picture;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, readonly) NSDate *creationDate;

- (void)cleanUp;

@end
