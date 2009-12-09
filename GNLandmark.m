//
//  GNLandmark.m
//  Implementation of GNLandmark
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GNLandmark.h"
#import <stdlib.h>

@implementation GNLandmark

@synthesize ID=_id, name=_name, activeLayers=_activeLayers, distance=_distance;

+(GNLandmark*)landmarkWithID:(int)ID name:(NSString*)name latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude altitude:(CLLocationDistance)altitude {
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = latitude;
	coordinate.longitude = longitude;
	
	GNLandmark *landmark = [[GNLandmark alloc] initWithCoordinate:coordinate altitude:altitude horizontalAccuracy:0.0 verticalAccuracy:0.0 timestamp:[NSDate date]];
	landmark.ID = ID;
	landmark.name = name;
	landmark.activeLayers = [NSMutableArray array];
	return [landmark autorelease];	
}

+(GNLandmark*)landmarkWithID:(int)ID name:(NSString*)name latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
	GNLandmark *newLandmark = [[[GNLandmark alloc] initWithLatitude:latitude longitude:longitude] autorelease];
	newLandmark.ID = ID;
	newLandmark.name = name;
	newLandmark.activeLayers = [[NSMutableArray alloc] init];
	return newLandmark;
}

-(NSComparisonResult)compareTo:(GNLandmark*)other {
	if(self.distance < other.distance)
		return NSOrderedAscending;
	else if(self.distance > other.distance)
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}

-(int)getNumActiveLayers {
	return (int) ([self.activeLayers count]);
}

-(void)addActiveLayer:(GNLayer*)layer {
	[self.activeLayers removeObject:layer];
	[self.activeLayers addObject:layer];
}

-(void)removeActiveLayer:(GNLayer*)layer {
	[self.activeLayers removeObject: layer];
}

-(void)clearActiveLayers {
	[self.activeLayers removeAllObjects];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%f, %f> %@", self.coordinate.latitude,
			self.coordinate.longitude, self.name];
}

-(void)dealloc {
	[self.name release];
	[self.activeLayers release];
	[super dealloc];
}

@end