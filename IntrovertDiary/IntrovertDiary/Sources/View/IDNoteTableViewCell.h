//
//  IDNoteTableViewCell.h
//  IntrovertDiary
//
//  Created by Www Www on 8/20/17.
//  Copyright © 2017 Michael Tishchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IDNoteTableViewCell : UITableViewCell

@property (readonly, nonatomic) UIImageView *noteImageView;
@property (readonly, nonatomic) UILabel *dateLabel;
@property (readonly, nonatomic) UILabel *noteLabel;

@end
