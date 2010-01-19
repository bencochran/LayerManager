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
	GNLayer *layer = [[GNLayer alloc] init];
	layer.name = initName;
	return [layer autorelease];
}

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

//////////////////// -(NSIcon) getIcon;

-(NSMutableArray*)getNClosestLandmarks:(int)n toLocation:(CLLocation*)location withLM:(GNLayerManager*)layerManager {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

// Removes this layer from the active layers list of each of its closest landmarks
// Sets this layer's list of closest landmarks to a new empty NSMutableArray
// and returns the previous closestLandmarks list (autoreleased)
-(NSMutableArray *)removeSelfFromLandmarks {
	for (GNLandmark *landmark in self.closestLandmarks) {
		[landmark removeActiveLayer:self];
	}
	
	NSMutableArray *prev = [self.closestLandmarks copy];
	[self.closestLandmarks removeAllObjects];
	return [prev autorelease];
}

// Returns a short string summarizing the layer information
// for the landmark with the given ID
-(NSString*)getSummaryStringForID:(int)landmarkID {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

// Returns a UIViewController displaying the layer information
// for the landmark with the given ID
-(UIViewController*)getLayerViewForID:(int)landmarkID {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<GNLayer name:%@, active: %@>", self.name, self.active ? @"YES" : @"NO"];
}

-(void)dealloc {
	[self.name release];
	[self.closestLandmarks release];
	[iconPath release];
	[layerInfoByLandmarkID release];
	
	[super dealloc];
}

@end