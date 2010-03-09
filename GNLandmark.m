//
//  GNLandmark.m
//  Implementation of GNLandmark
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GNLandmark.h"
#import "GNLayerManager.h"

@implementation GNLandmark

@synthesize ID=_id, name=_name, distance=_distance;

- (CLLocationCoordinate2D)coordinate {
	return super.coordinate;
}

- (NSString *)title {
	return self.name;
}

- (NSString *)subtitle {
	NSMutableArray *layerNames = [NSMutableArray array];
	for (GNLayer *layer in [[GNLayerManager sharedManager] layersForLandmark:self]) {
		[layerNames addObject:[layer name]];
	}
	return [layerNames componentsJoinedByString:@", "];
}

+ (GNLandmark *)landmarkWithID:(NSString *)ID name:(NSString *)name latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude altitude:(CLLocationDistance)altitude {
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = latitude;
	coordinate.longitude = longitude;
	
	GNLandmark *landmark = [[GNLandmark alloc] initWithCoordinate:coordinate altitude:altitude horizontalAccuracy:0.0 verticalAccuracy:0.0 timestamp:[NSDate date]];
	landmark.ID = ID;
	landmark.name = name;
	landmark.distance = INFINITY;
	return [landmark autorelease];	
}

+ (GNLandmark *)landmarkWithID:(NSString *)ID name:(NSString *)name latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
	GNLandmark *landmark = [[GNLandmark alloc] initWithLatitude:latitude longitude:longitude];
	landmark.ID = ID;
	landmark.name = name;
	landmark.distance = INFINITY;
	return [landmark autorelease];
}

// Used to sort landmarks by distance
-(NSComparisonResult)compareTo:(GNLandmark*)other {
	if(self.distance < other.distance)
		return NSOrderedAscending;
	else if(self.distance > other.distance)
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%f, %f> %@", self.coordinate.latitude,
			self.coordinate.longitude, self.name];
}

-(void)dealloc {
	[self.ID release];
	[self.name release];
	[super dealloc];
}

@end