//
//  CarletonBuildingsLayer.h
//  LayerManager
//
//  Created by iComps on 11/16/09.
//  Copyright 2009 Gnarus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GNLayer.h"

@interface CarletonBuildingsLayer : GNLayer {
}

@end

/////

@interface CarletonBuildingsViewController : UIViewController {
	IBOutlet UILabel *buildingNameLabel;
	IBOutlet UIImageView *imageView;
	IBOutlet UITextView *descriptionView;
	NSMutableData *receivedData;
	NSURL *_imageURL;
	NSString *_buildingName;
	NSString *_description;
}

@property (nonatomic, retain) NSURL *imageURL;
@property (nonatomic, copy) NSString *buildingName;
@property (nonatomic, copy) NSString *description;

@end
