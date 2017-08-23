//
//  IDNoteViewController.h
//  IntrovertDiary
//
//  Created by Www Www on 8/20/17.
//  Copyright © 2017 Michael Tishchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IDNote;

@interface IDNoteViewController : UIViewController

+ (UINavigationController *)noteControllerWithNote:(IDNote *)note;
+ (UINavigationController *)createNoteController;

@end
