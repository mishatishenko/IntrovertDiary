//
//  IDNoteListViewController.m
//  IntrovertDiary
//
//  Created by Www Www on 8/20/17.
//  Copyright © 2017 Michael Tishchenko. All rights reserved.
//

#import "IDNoteListViewController.h"
#import "IDNoteTableViewCell.h"
#import "IDNoteStorage.h"
#import "IDNote.h"
#import "NSDateAdditions.h"
#import "IDNoteViewController.h"

@interface IDNoteListViewController () <UITableViewDelegate,
			UITableViewDataSource, IDNoteStorageObserver>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray<IDNote *> *notes;
@property (strong, nonatomic) IDNote *selectedNote;

@property (strong, nonatomic) UIAlertController *expirationAlert;

@end

@implementation IDNoteListViewController

- (void)dealloc
{
	[[IDNoteStorage sharedStorage] removeObserver:self];
	[[IDNoteStorage sharedStorage] stopTrackingNoteExpiration];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[[IDNoteStorage sharedStorage] addObserver:self];

	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.rowHeight = 92;
	self.tableView.separatorColor = [UIColor colorWithRed:225./255 green:231./255
				blue:232./255 alpha:1];
	
	[self.tableView registerNib:[UINib nibWithNibName:@"IDNoteTableViewCell"
				bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"note"];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
	
	self.title = NSLocalizedString(@"cToday", @"Title");
	
	UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
	infoButton.backgroundColor = [UIColor clearColor];
	[infoButton setImage:[UIImage imageNamed:@"info"]
				forState:UIControlStateNormal];
	[infoButton sizeToFit];
	[infoButton addTarget:self action:@selector(presentInfo)
				forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
				initWithCustomView:infoButton];
	infoButton.exclusiveTouch = YES;
	
	self.notes = [NSArray arrayWithArray:[[IDNoteStorage sharedStorage] notes]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
				selector:@selector(applicationDidBecomeActive:)
				name:UIApplicationDidBecomeActiveNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
				selector:@selector(applicationWillResignActive:)
				name:UIApplicationWillResignActiveNotification object:nil];
	
	[[IDNoteStorage sharedStorage] startTrackingNoteExpiration];
	
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
	
	[self.tableView reloadData];
}

- (IBAction)addNewNote:(UIButton *)sender
{
	BOOL shouldAddNewNote = YES;
	if (self.notes.count > 0)
	{
		NSDateComponents *newComponents = [[NSCalendar currentCalendar]
					components:NSCalendarUnitMonth fromDate:[NSDate date]];
		
		NSDateComponents *lastComponents = [[NSCalendar currentCalendar]
					components:NSCalendarUnitMonth
					fromDate:self.notes.lastObject.creationDate];
		
		if (newComponents.year == lastComponents.year &&
					newComponents.month == lastComponents.month &&
					newComponents.day == lastComponents.day)
		{
			shouldAddNewNote = NO;
			UIAlertController *alert = [UIAlertController alertControllerWithTitle:
						NSLocalizedString(@"cSorry", @"") message:
						NSLocalizedString(@"cYouCanCreate", @"")
						preferredStyle:UIAlertControllerStyleAlert];
			
			[alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cOk", @"")
						style:UIAlertActionStyleDefault handler:nil]];
			
			[self presentViewController:alert animated:YES completion:nil];
		}
	}
	
	if (shouldAddNewNote)
	{
		[self presentViewController:[IDNoteViewController createNoteController]
					animated:YES completion:nil];
	}
}

- (void)presentInfo
{
	[self.navigationController pushViewController:
				[[UIStoryboard storyboardWithName:@"Main"
				bundle:[NSBundle mainBundle]]
				instantiateViewControllerWithIdentifier:@"infoViewController"]
				animated:YES];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
			didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.selectedNote = self.notes[indexPath.row];
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	[self presentViewController:[IDNoteViewController
				noteControllerWithNote:self.notes[indexPath.row]]
				animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
			numberOfRowsInSection:(NSInteger)section
{
	return self.notes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
			cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	IDNoteTableViewCell *cell = [self.tableView
				dequeueReusableCellWithIdentifier:@"note" forIndexPath:indexPath];
	IDNote *note = self.notes[indexPath.row];
	
	NSMutableParagraphStyle *style =
				[[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	style.alignment = NSTextAlignmentJustified;
	style.lineSpacing = 5;

	NSAttributedString *attrText = [[NSAttributedString alloc]
				initWithString:note.text
				attributes:@{ NSParagraphStyleAttributeName : style}];

	cell.noteLabel.attributedText = attrText;
	
	cell.dateLabel.text = [note.creationDate localizableDate];
	cell.noteImageView.contentMode =  nil != note.picture ?
				UIViewContentModeScaleAspectFill : UIViewContentModeCenter;
	cell.noteImageView.image = nil != note.picture ?
				note.picture : [UIImage imageNamed:@"image"];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
			heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 92;
}

#pragma mark - IDNoteStorageObserver

- (void)noteStorage:(IDNoteStorage *)sender didDeleteNote:(IDNote *)note
{
	self.notes = [NSArray arrayWithArray:[[IDNoteStorage sharedStorage] notes]];
	[self.tableView reloadData];
	self.selectedNote = nil;
	
	if (nil == self.expirationAlert)
	{
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void)noteStorage:(IDNoteStorage *)sender didAddNote:(IDNote *)note
{
	self.notes = [NSArray arrayWithArray:[[IDNoteStorage sharedStorage] notes]];
	
	[self.tableView reloadData];
}

- (void)noteStorage:(IDNoteStorage *)sender didUpdateNote:(IDNote *)note
{
	[self.tableView beginUpdates];
	[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath
				indexPathForRow:[self.notes indexOfObject:note] inSection:0]]
				withRowAnimation:UITableViewRowAnimationFade];
	self.notes = [NSArray arrayWithArray:[[IDNoteStorage sharedStorage] notes]];
	[self.tableView endUpdates];
}

- (void)noteStorage:(IDNoteStorage *)sender didTrackExpirationOfNote:(IDNote *)note
{
	[[IDNoteStorage sharedStorage] removeNote:note];
	if (nil != self.expirationAlert)
	{
		return;
	}
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:
				NSLocalizedString(@"cAttention", @"") message:
				NSLocalizedString(@"cExpiredDescription", @"")
				preferredStyle:UIAlertControllerStyleAlert];
	
	[alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cOk", @"")
				style:UIAlertActionStyleDefault
				handler:^(UIAlertAction * _Nonnull action)
	{
		self.expirationAlert = nil;
		if (self.selectedNote == note)
		{
			[self dismissViewControllerAnimated:YES completion:nil];
		}
	}]];
	
	UIViewController *topController = self;
	
	while (nil != topController.presentedViewController)
	{
		topController = topController.presentedViewController;
	}
	
	self.expirationAlert = alert;
	[topController presentViewController:alert animated:YES completion:nil];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
	[[IDNoteStorage sharedStorage] startTrackingNoteExpiration];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
	[[IDNoteStorage sharedStorage] stopTrackingNoteExpiration];
}

@end
