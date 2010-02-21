//
//  FoodLayer.h
//  LayerManager
//
//  Created by Jake Kring on 1/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GNLayer.h"

@interface FoodLayer : GNLayer {
}

@end

///////

@interface FoodViewController : UIViewController {
	IBOutlet UILabel *nameLabel;
	IBOutlet UIImageView *imageView;
	IBOutlet UITextView *descriptionView;
	IBOutlet UITextView *summaryView;
	IBOutlet UITextView *menuView;
	IBOutlet UITextView *hoursView;
	NSMutableData *receivedData;
	NSURL *_imageURL;
	NSString *_name;
	NSString *_description;
	NSString *_summary;
	NSString *_hours;
	NSString *_menu;
}

@property (nonatomic, retain) NSURL *imageURL;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *hours;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *menu;

@end
