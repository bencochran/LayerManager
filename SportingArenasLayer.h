//
//  SportingArenasLayer.h
//  LayerManager
//
//  Created by Eric Alexander on 2/20/2010.
//  Copyright 2010 Gnarus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GNLayer.h"

@interface SportingArenasLayer : GNLayer {
}

@end

///////

@interface SportingArenasViewController : UIViewController {
	IBOutlet UIImageView *imageView;
	IBOutlet UILabel *_summaryView;
	IBOutlet UILabel *_usedByView;
	IBOutlet UILabel *_scheduleURLView;
	IBOutlet UILabel *_editPhoto;
	IBOutlet UIView *_photoFrame;
	NSString *_summary;
	NSString *_usedBy;
	NSString *_scheduleURL;
	NSMutableData *receivedData;
	NSURL *_imageURL;
	GNLayer *_layer;
	GNLandmark *_landmark;
	
}

@property (nonatomic, retain) NSURL *imageURL;
@property (nonatomic, retain) UILabel *usedByView;
@property (nonatomic, retain) UILabel *summaryView;
@property (nonatomic, retain) UILabel *scheduleURLView;
@property (nonatomic, retain) UILabel *editPhoto;
@property (nonatomic, retain) UIView *photoFrame;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *usedBy;
@property (nonatomic, copy) NSString *scheduleURL;

@property (nonatomic, retain) GNLayer *layer;
@property (nonatomic, retain) GNLandmark *landmark;

@end