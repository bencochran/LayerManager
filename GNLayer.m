//
//  GNLayer.m
//  A generalized layer implementation. Does not recognize all methods - must be subclassed.
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 Gnarus. All rights reserved.
//

#import "GNLayer.h"

@implementation GNLayer

@synthesize name=_name, active=_active, closestLandmarks=_closestLandmarks;

+(GNLayer*)layerWithName:(NSString*)initName {
	GNLayer *layer = [[[GNLayer alloc] init] autorelease];
	layer.name = initName;
	return layer;
}

//////////////////// -(NSIcon) getIcon;

-(id)init {
	if (self = [super init]) {
		self.name = nil;
		self.active = NO;
		self.closestLandmarks = [[NSMutableArray alloc] init];
		iconPath = nil;
		layerInfoByLandmarkID = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(NSMutableArray*)getNClosestLandmarks:(int)n toLocation:(CLLocation*)location withLM:(GNLayerManager*)layerManager {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

// Removes this layer from the active layers list of each of its closest landmarks
// Sets this layer's list of closest landmarks to a new empty NSMutableArray
// and returns the closestLandmarks list
-(NSMutableArray *)removeSelfFromLandmarks {
	NSMutableArray *ret = self.closestLandmarks;
	int i;
	for(i = 0; i < [self.closestLandmarks count]; i++)
		[((GNDistAndLandmark *) [self.closestLandmarks objectAtIndex:i]).landmark removeActiveLayer: self];
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

-(void)dealloc {
	[self.name dealloc];
	[self.closestLandmarks dealloc];
	[iconPath dealloc];
	[layerInfoByLandmarkID dealloc];
	[super dealloc];
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