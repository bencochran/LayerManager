//
//  FlickrLayer.h
//  LayerManager
//
//  Created by Jake Kring on 2/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GNLayer.h"
#import "ObjectiveFlickr.h"

@interface FlickrLayer : GNLayer <OFFlickrAPIRequestDelegate> {
	OFFlickrAPIContext *context;
}

@end
