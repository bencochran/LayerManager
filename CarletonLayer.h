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
	IBOutlet UILabel *_buildingNameLabel;
	IBOutlet UITextView *_descriptionView;
	NSMutableData *receivedData;
	IBOutlet UIImageView *imageView;
	NSURL *_imageURL;
	GNLayer *_layer;
	GNLandmark *_landmark;
//	NSString *_buildingName;
//	NSString *_description;
}

@property (nonatomic, retain) NSURL *imageURL;
@property (nonatomic, retain) UILabel *buildingNameLabel;
@property (nonatomic, retain) UITextView *descriptionView;
@property (nonatomic, retain) GNLayer *layer;
@property (nonatomic, retain) GNLandmark *landmark;


@end
