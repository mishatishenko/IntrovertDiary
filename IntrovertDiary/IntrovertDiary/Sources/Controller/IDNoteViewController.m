//
//  IDNoteViewController.m
//  IntrovertDiary
//
//  Created by Www Www on 8/20/17.
//  Copyright © 2017 Michael Tishchenko. All rights reserved.
//

#import "IDNoteViewController.h"
#import "IDNote.h"
#import "IDNoteStorage.h"
#import "NSDateAdditions.h"
#import "UIImageAdditions.h"
#import "IDDropShadowView.h"
#import <Photos/Photos.h>

@interface IDNoteViewController () <UIImagePickerControllerDelegate,
			UINavigationControllerDelegate, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *placeHolder;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UITextView *noteTextView;
@property (strong, nonatomic) IBOutlet UIButton *changePictureButton;
@property (strong, nonatomic)
			IBOutlet NSLayoutConstraint *imageWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;
@property (strong, nonatomic)
			IBOutlet NSLayoutConstraint *textHeightConstraint;
@property (strong, nonatomic)
			IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;
@property (strong, nonatomic) IBOutlet IDDropShadowView *shadowView;

@property (nonatomic) BOOL editMode;

@property (nonatomic, strong) IDNote *note;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIImage *image;

@end

@implementation IDNoteViewController

+ (UINavigationController *)noteControllerWithNote:(IDNote *)note;
{
	UINavigationController *navigationController =
				[[UIStoryboard storyboardWithName:@"Main"
				bundle:[NSBundle mainBundle]]
				instantiateViewControllerWithIdentifier:
				@"noteEditNavigationController"];
	IDNoteViewController *controller = (IDNoteViewController *)
				navigationController.topViewController;
	controller.note = note;
	
	return navigationController;
}

+ (UINavigationController *)createNoteController
{
	UINavigationController *navigationController =
				[[UIStoryboard storyboardWithName:@"Main"
				bundle:[NSBundle mainBundle]]
				instantiateViewControllerWithIdentifier:
				@"noteEditNavigationController"];
	IDNoteViewController *controller = (IDNoteViewController *)
				navigationController.topViewController;
	controller.note = [IDNote new];
	controller.editMode = YES;
	
	return navigationController;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"cToday", @"");
	
	self.noteTextView.delegate = self;
	
	self.imageWidthConstraint.constant =
				CGRectGetWidth(self.navigationController.view.frame) - 32;
	self.imageHeightConstraint.constant = self.imageWidthConstraint.constant * 0.56;
	
	self.imageView.image = self.note.picture;
	self.image = self.note.picture;
	
	self.dateLabel.text = [self.note.creationDate localizableDate];
	self.text = self.note.text;
	
	CGSize estimatedSize = [self.noteTextView sizeThatFits:CGSizeMake(
				CGRectGetWidth(self.noteTextView.frame), MAXFLOAT)];
	
	self.textHeightConstraint.constant = MAX(estimatedSize.height, 20);
	
	self.noteTextView.text = self.note.text;
	self.placeHolder.hidden = 0 != self.text.length;
	
	self.shadowView.hidden = nil == self.image;
	
	[self turnEditMode:self.editMode];
	
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelButton.backgroundColor = [UIColor clearColor];
	[cancelButton setImage:[UIImage imageNamed:@"close"]
				forState:UIControlStateNormal];
	[cancelButton sizeToFit];
	[cancelButton addTarget:self action:@selector(cancelEditing)
				forControlEvents:UIControlEventTouchUpInside];
	cancelButton.exclusiveTouch = YES;
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
				initWithCustomView:cancelButton];
	
	UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	deleteButton.backgroundColor = [UIColor clearColor];
	[deleteButton setImage:[UIImage imageNamed:@"delete"]
				forState:UIControlStateNormal];
	[deleteButton sizeToFit];
	[deleteButton addTarget:self action:@selector(showDeleteNoteConfirmation)
				forControlEvents:UIControlEventTouchUpInside];
	deleteButton.exclusiveTouch = YES;
	
	UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	shareButton.backgroundColor = [UIColor clearColor];
	[shareButton setImage:[UIImage imageNamed:@"share"]
				forState:UIControlStateNormal];
	[shareButton sizeToFit];
	[shareButton addTarget:self action:@selector(shareNote)
				forControlEvents:UIControlEventTouchUpInside];
	shareButton.exclusiveTouch = YES;
	
	self.toolbarItems = @[[[UIBarButtonItem alloc]
				initWithCustomView:deleteButton],
				[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
				UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
				[[UIBarButtonItem alloc] initWithCustomView:shareButton]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
				selector:@selector(keyboardWillAppear:)
				name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
				selector:@selector(keyboardWillDisappear:)
				name:UIKeyboardWillHideNotification object:nil];
	
	NSDictionary *textTitleOptions =
				@{
					NSForegroundColorAttributeName :
					[UIColor colorWithRed:97./255 green:108./255 blue:115./255 alpha:1],
					NSBackgroundColorAttributeName : [UIColor whiteColor],
					NSFontAttributeName :
					[UIFont fontWithName:@"SFUIDisplay-Semibold" size:12.0]
				};
	[self.navigationController.navigationBar setTitleTextAttributes:textTitleOptions];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	CGSize estimatedSize = [self.noteTextView sizeThatFits:CGSizeMake(
				CGRectGetWidth(self.noteTextView.frame), MAXFLOAT)];
	
	self.textHeightConstraint.constant = estimatedSize.height;
}

- (void)turnEditMode:(BOOL)enableEditMode
{
	self.editMode = enableEditMode;
	
	self.changePictureButton.userInteractionEnabled = enableEditMode;
	self.changePictureButton.hidden = !enableEditMode && nil != self.image;
	[self.changePictureButton setImage:[UIImage imageNamed:nil != self.image ?
				@"imageWhite" : @"image"] forState:UIControlStateNormal];
	self.changePictureButton.backgroundColor = nil != self.image ?
				[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] :
				[UIColor colorWithRed:225./255 green:231./255
				blue:232./255 alpha:0.5];
	self.noteTextView.userInteractionEnabled = enableEditMode;
	
	[self.navigationController setToolbarHidden:enableEditMode animated:YES];
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.backgroundColor = [UIColor clearColor];
	[button setImage:[UIImage imageNamed:enableEditMode ? @"done" : @"edit"]
				forState:UIControlStateNormal];
	[button sizeToFit];
	[button addTarget:self action:enableEditMode ? @selector(doneEditing) :
				@selector(enableEditMode)
				forControlEvents:UIControlEventTouchUpInside];
	button.exclusiveTouch = YES;
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
				initWithCustomView:button];
	button.enabled = !enableEditMode || nil != self.image || nil != self.text;
}

- (void)cancelEditing
{
	[self.noteTextView endEditing:YES];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneEditing
{
	[self.noteTextView endEditing:YES];
	self.text = self.noteTextView.text;
	[self turnEditMode:NO];
	
	BOOL noteIsEdited = NO;
	if (![self.image isEqual:self.note.picture] && nil != self.image)
	{
		noteIsEdited = YES;
		self.note.picture = self.image;
	}
	if (![self.note.text isEqualToString:self.text] && nil != self.text)
	{
		noteIsEdited = YES;
		self.note.text = self.text;
	}
	
	if (noteIsEdited)
	{
		[[IDNoteStorage sharedStorage] saveNote:self.note];
	}
}

- (void)enableEditMode
{
	[self turnEditMode:YES];
}

- (void)showDeleteNoteConfirmation
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:
				NSLocalizedString(@"cAttention", @"") message:
				NSLocalizedString(@"cDeleteConfirmation", @"")
				preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:
				NSLocalizedString(@"cCancel", @"") style:UIAlertActionStyleDefault
				handler:nil]];
	
	[alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cOk", @"")
				style:UIAlertActionStyleDefault handler:
	^(UIAlertAction * _Nonnull action)
	{
		[self deleteNote];
	}]];
	
	[self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteNote
{
	[[IDNoteStorage sharedStorage] removeNote:self.note];
}

- (void)shareNote
{
	NSMutableArray *objectsToShare = [NSMutableArray new];
	if (nil != self.note.text)
	{
		[objectsToShare addObject:self.note.text];
	}
	if (nil != self.note.picture)
	{
		[objectsToShare addObject:self.note.picture];
	}
 
	UIActivityViewController *activityController =
				[[UIActivityViewController alloc]
				initWithActivityItems:objectsToShare applicationActivities:nil];
 
	NSArray *excludeActivities = @[UIActivityTypePostToFacebook,
				UIActivityTypePostToTwitter,
				UIActivityTypePostToWeibo, UIActivityTypeMessage,
				UIActivityTypeMail, UIActivityTypeCopyToPasteboard,
				UIActivityTypePrint];
 
	activityController.excludedActivityTypes = excludeActivities;
 
	[self presentViewController:activityController animated:YES completion:nil];
}

- (IBAction)changePicture:(UIButton *)sender
{
	if ([PHPhotoLibrary authorizationStatus] ==
				PHAuthorizationStatusNotDetermined)
	{
		[PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status)
		{
			dispatch_async(dispatch_get_main_queue(),
			^{
				if (status == PHAuthorizationStatusAuthorized)
				{
					UIImagePickerController *picker = [UIImagePickerController new];
					picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
					picker.delegate = self;
					[self presentViewController:picker animated:YES completion:nil];
				}
				else
				{
					UIAlertController *alert =
								[UIAlertController alertControllerWithTitle:
								NSLocalizedString(@"cError", @"") message:
								NSLocalizedString(@"cNoAccessToPhotos", @"")
								preferredStyle:UIAlertControllerStyleAlert];
					
					[alert addAction:[UIAlertAction
								actionWithTitle:NSLocalizedString(@"cOk", @"")
								style:UIAlertActionStyleDefault handler:nil]];
					
					[self presentViewController:alert animated:YES completion:nil];
				}
			});
		}];
	}
	else
	{
		if ([PHPhotoLibrary authorizationStatus] ==
					PHAuthorizationStatusAuthorized)
		{
			UIImagePickerController *picker = [UIImagePickerController new];
			picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			picker.delegate = self;
			[self presentViewController:picker animated:YES completion:nil];
		}
		else
		{
			UIAlertController *alert = [UIAlertController alertControllerWithTitle:
						NSLocalizedString(@"cError", @"") message:
						NSLocalizedString(@"cNoAccessToPhotos", @"")
						preferredStyle:UIAlertControllerStyleAlert];
			
			[alert addAction:[UIAlertAction
						actionWithTitle:NSLocalizedString(@"cOk", @"")
						style:UIAlertActionStyleDefault handler:nil]];
			
			[self presentViewController:alert animated:YES completion:nil];
		}
	}
}

#pragma mark - UIImagePicker delegate

- (void)imagePickerController:(UIImagePickerController *)picker
			didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
	if (nil != info[UIImagePickerControllerOriginalImage])
	{
		self.image = [info[UIImagePickerControllerOriginalImage]
					downscaledImageToSize:800];
		self.imageView.image = self.image;
		
		[self.changePictureButton setImage:[UIImage imageNamed:@"imageWhite"]
					forState:UIControlStateNormal];
		self.changePictureButton.backgroundColor =
					[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
		((UIButton *)self.navigationItem.rightBarButtonItem.customView).
					enabled = YES;
		self.shadowView.hidden = NO;
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextView delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
	return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
	return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	if (CGRectGetMaxY(self.noteTextView.frame) >
				CGRectGetHeight(self.view.bounds) -
				self.scrollViewBottomConstraint.constant)
	{
		[self.scrollView setContentOffset:CGPointMake(0,
					CGRectGetMaxY(self.noteTextView.frame) -
					CGRectGetHeight(self.view.bounds) +
					self.scrollViewBottomConstraint.constant) animated:YES];
	}
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	self.text = textView.text;
	[self.noteTextView endEditing:YES];
	
	self.placeHolder.hidden = 0 != textView.text.length;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
			replacementText:(NSString *)text
{
	return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
	((UIButton *)self.navigationItem.rightBarButtonItem.customView).enabled =
				nil != self.image || textView.text.length > 0;
	
	CGSize estimatedSize = [self.noteTextView sizeThatFits:CGSizeMake(
				CGRectGetWidth(self.noteTextView.frame), MAXFLOAT)];
	
	self.textHeightConstraint.constant = MAX(estimatedSize.height, 20);
	self.placeHolder.hidden = 0 != textView.text.length;
}

#pragma mark - Notifications

- (void)keyboardWillAppear:(NSNotification *)notification
{
	if (nil != notification.userInfo[UIKeyboardFrameEndUserInfoKey])
	{
		CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey]
					CGRectValue];
		self.scrollViewBottomConstraint.constant = CGRectGetHeight(frame);
	}
}

- (void)keyboardWillDisappear:(NSNotification *)notification
{
	self.scrollViewBottomConstraint.constant = 0;
}

@end
