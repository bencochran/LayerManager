//
//  SportsViewController.h
//  LayerManager
//
//  Created by Jake Kring on 2/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "GNLayer.h"
#import "GNTableViewCell.h"

@interface SportsViewController : UITableViewController {
	IBOutlet UITableViewCell *_summaryCell;
	IBOutlet UILabel *_summary;
	IBOutlet UITableViewCell *_usedByCell;
	IBOutlet UILabel *_usedBy;
	IBOutlet UITableViewCell *_scheduleURLCell;
	IBOutlet UITextView*_scheduleURL;
	IBOutlet UITableViewCell *_imageViewCell;
	IBOutlet UIImageView *imageView;
	NSString *_summaryString;
	NSString *_usedByString;
	NSString *_scheduleURLString;
	NSURL *_imageURL;
	NSMutableData *receivedData;
	GNLayer *_layer;
	GNLandmark *_landmark;
	
}

@property (nonatomic, retain) NSURL *imageURL;
@property (nonatomic, retain) UITableViewCell *summaryCell;
@property (nonatomic, retain) UILabel *summary;
@property (nonatomic, retain) UITableViewCell *usedByCell;
@property (nonatomic, retain) UILabel *usedBy;
@property (nonatomic, retain) UITableViewCell *scheduleURLCell;
@property (nonatomic, retain) UITextView *scheduleURL;
@property (nonatomic, retain) UITableViewCell *imageViewCell;

@property (nonatomic, copy) NSString *summaryString;
@property (nonatomic, copy) NSString *usedByString;
@property (nonatomic, copy) NSString *scheduleURLString;

@property (nonatomic, retain) GNLayer *layer;
@property (nonatomic, retain) GNLandmark *landmark;

@end