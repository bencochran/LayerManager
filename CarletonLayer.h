//
//  CarletonLayer.h
//  LayerManager
//
//  Created by iComps on 11/16/09.
//  Copyright 2009 Gnarus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GNLayer.h"

@interface CarletonLayer : GNLayer {
}

@end

/////

@interface CarletonViewController : UIViewController {
	IBOutlet UITextView *_descriptionView;
	IBOutlet UITextView *_summaryView;
	IBOutlet UITextView *_yearBuiltView;
	NSString *_description;
	NSString *_summary;
	NSString *_yearBuilt;
	NSMutableData *receivedData;
	IBOutlet UIImageView *imageView;
	NSURL *_imageURL;
	GNLayer *_layer;
	GNLandmark *_landmark;
//	NSString *_buildingName;
//	NSString *_description;
}

@property (nonatomic, retain) UITextView *descriptionView;
@property (nonatomic, retain) UITextView *summaryView; 
@property (nonatomic, retain) UITextView *yearBuiltView; 
@property (nonatomic, retain) NSURL *imageURL;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *yearBuilt;
@property (nonatomic, retain) GNLayer *layer;
@property (nonatomic, retain) GNLandmark *landmark;


@end
