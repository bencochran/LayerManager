//
//  GNLayer.m
//  
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GNLayer.h"

@implementation GNLayer

@synthesize name=_name, active=_active, closestLandmarks=_closestLandmarks;

+(GNLayer*)layerWithName:(NSString*)initName {
	GNLayer *layer = [[[GNLayer alloc] init] autorelease];
	layer.name = initName;
	return layer;
}

// -(NSIcon) getIcon;

-(id)init {
	if (self = [super init]) {
		self.name = nil;
		self.active = NO;
		self.closestLandmarks = [[NSMutableArray alloc] init];
		layerInfoByLandmarkID = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(NSMutableArray*)getNClosestLandmarks:(int)n toLocation:(CLLocation*)location {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

-(NSMutableArray *)removeSelfFromLandmarks {
	NSMutableArray *ret = self.closestLandmarks;
	GNDistAndLandmark *distLand;
	int i;
	for(i = 0; i < [self.closestLandmarks count]; i++) {
		distLand = (GNDistAndLandmark *) [self.closestLandmarks objectAtIndex: i];
		[distLand.landmark removeActiveLayer: self];
	}
	self.closestLandmarks = [[NSMutableArray alloc] init];
	return ret;
}

-(NSString*)getSummaryStringForID:(int)landmarkID {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

-(UIViewController*)getLayerViewForID:(int)landmarkID {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

@end


@implementation GNDistAndLandmark

@synthesize dist=_dist, landmark=_landmark;

+(GNDistAndLandmark*)gndlWithDist:(float)initDist andLandmark:(GNLandmark*)initLandmark {
	GNDistAndLandmark *gndl = [[[GNDistAndLandmark alloc] init] autorelease];
	gndl.dist = initDist;
	gndl.landmark = initLandmark;
	return gndl;
}

-(NSComparisonResult)compareTo:(GNDistAndLandmark*)gndl {
	if(self.dist < gndl.dist)
		return NSOrderedAscending;
	else if(self.dist > gndl.dist)
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}

@end