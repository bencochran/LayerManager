//
//  FlickrLayer.h
//  Displays geo-tagged Flickr images
//
//  Created by Jake Kring on 2/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GNLayer.h"
#import "JSON.h"

@interface FlickrLayer : GNLayer {
}

@end

/////

@interface FlickrViewController : UIViewController {
	IBOutlet UIImageView *imageView;
	NSURL *_imageURL;
	NSMutableData *receivedData;
	GNLayer *_layer;
	GNLandmark *_landmark;
}

@property (nonatomic, retain) NSURL *imageURL;
@property (nonatomic, retain) GNLayer *layer;
@property (nonatomic, retain) GNLandmark *landmark;


@end
