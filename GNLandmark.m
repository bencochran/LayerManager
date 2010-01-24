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

@synthesize ID=_id, name=_name, distance=_distance, activeLayers=_activeLayers;

+ (GNLandmark *)landmarkWithID:(NSString *)ID name:(NSString *)name latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude altitude:(CLLocationDistance)altitude {
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = latitude;
	coordinate.longitude = longitude;
	
	GNLandmark *landmark = [[GNLandmark alloc] initWithCoordinate:coordinate altitude:altitude horizontalAccuracy:0.0 verticalAccuracy:0.0 timestamp:[NSDate date]];
	landmark.ID = ID;
	landmark.name = name;
	landmark.distance = INFINITY;
	landmark.activeLayers = [NSMutableArray array];
	return [landmark autorelease];	
}

+ (GNLandmark *)landmarkWithID:(NSString *)ID name:(NSString *)name latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
	GNLandmark *landmark = [[GNLandmark alloc] initWithLatitude:latitude longitude:longitude];
	landmark.ID = ID;
	landmark.name = name;
	landmark.distance = INFINITY;
	landmark.activeLayers = [NSMutableArray array];
	return [landmark autorelease];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
		self.name = [aDecoder decodeObjectForKey:@"GNLandmarkName"];
		self.ID = [aDecoder decodeObjectForKey:@"GNLandmarkID"];
		self.activeLayers = [aDecoder decodeObjectForKey:@"GNLandmarkActiveLayers"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:self.name forKey:@"GNLandmarkName"];
	[aCoder encodeObject:self.ID forKey:@"GNLandmarkID"];
	[aCoder encodeObject:self.activeLayers forKey:@"GNLandmarkActiveLayers"];
}

- (id)copyWithZone:(NSZone *)zone {
	id copy = [super copyWithZone:zone];
	
	[copy setName:[self.name copy]];
	[copy setID:[self.ID copy]];
	[copy setActiveLayers:self.activeLayers];
	return copy;
}

- (NSString *)title {
	return self.name;
}

-(NSComparisonResult)compareTo:(GNLandmark*)other {
	if(self.distance < other.distance)
		return NSOrderedAscending;
	else if(self.distance > other.distance)
		return NSOrderedDescending;
	else
		return NSOrderedSame;
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
	[self.ID release];
	[self.name release];
	[self.activeLayers release];
	[super dealloc];
}

@end