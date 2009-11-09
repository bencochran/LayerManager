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

+(GNLayer*)initWithName:(NSString*)initName {
	GNLayer *layer = [[[GNLayer alloc] init] autorelease];
	layer.name = initName;
	layer.active = NO;
	layer.closestLandmarks = [[NSMutableArray alloc] init];
	return layer;
}

// -(NSIcon) getIcon;

-(NSMutableArray*)getNClosestLandmarks:(int)n toLocation:(CLLocation*)location {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

-(NSMutableArray *)removeSelfFromLandmarks {
	NSMutableArray *ret = self.closestLandmarks;
	int i;
	for(i = 0; i < [self.closestLandmarks count]; i++) {
		Dist_And_Landmark *distLand = (Dist_And_Landmark *) [self.closestLandmarks objectAtIndex: i];
		[distLand->landmark removeActiveLayer: self];
	}
	self.closestLandmarks = [[NSMutableArray alloc] init];
	return ret;
}

-(UIViewController*)getLayerViewForID:(int)landmarkID {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

@end