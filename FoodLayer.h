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
	IBOutlet UILabel *_nameLabel;
	IBOutlet UIImageView *imageView;
	IBOutlet UITextView *_descriptionView;
	IBOutlet UITextView *_summaryView;
	IBOutlet UITextView *_menuView;
	IBOutlet UITextView *_hoursView;
	NSMutableData *receivedData;
	NSURL *_imageURL;
	GNLayer *_layer;
	GNLandmark *_landmark;
	
}

@property (nonatomic, retain) NSURL *imageURL;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UITextView *descriptionView;
@property (nonatomic, retain) UITextView *hoursView;
@property (nonatomic, retain) UITextView *summaryView;
@property (nonatomic, retain) UITextView *menuView;
@property (nonatomic, retain) GNLayer *layer;
@property (nonatomic, retain) GNLandmark *landmark;

@end
