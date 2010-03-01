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

@interface GNLandmarkViewController : UITableViewController {
	NSMutableDictionary *_fieldInfo;
	NSArray *_fieldNames;
	GNTableViewCell *_imageViewCell;
	UIImage *_photo;
	NSURL *_imageURL;
	NSMutableData *receivedData;
	GNLayer *_layer;
	GNLandmark *_landmark;
	
}

@property (nonatomic, retain) NSURL *imageURL;
@property (nonatomic, retain) GNTableViewCell *imageViewCell;
@property (nonatomic, retain) UIImage *photo;
@property (nonatomic, retain, setter=setFieldInfo:) NSMutableDictionary *fieldInfo;
@property (nonatomic, retain) NSArray *fieldNames;
@property (nonatomic, retain) GNLayer *layer;
@property (nonatomic, retain) GNLandmark *landmark;

@end