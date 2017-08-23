//
//  IDInfoViewController.m
//  IntrovertDiary
//
//  Created by Www Www on 8/20/17.
//  Copyright © 2017 Michael Tishchenko. All rights reserved.
//

#import "IDInfoViewController.h"

@implementation IDInfoViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"cAboutApp", @"");
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.backgroundColor = [UIColor clearColor];
	[backButton setImage:[UIImage imageNamed:@"back"]
				forState:UIControlStateNormal];
	[backButton sizeToFit];
	[backButton addTarget:self action:@selector(goBack)
				forControlEvents:UIControlEventTouchUpInside];
	backButton.exclusiveTouch = YES;
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
				initWithCustomView:backButton];
}

- (void)goBack
{
	[self.navigationController popViewControllerAnimated:YES];
}

@end
