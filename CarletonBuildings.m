//
//  CarletonBuildings.m
//  LayerManager
//
//  Created by iComps on 11/16/09.
//  Copyright 2009 Gnarus. All rights reserved.
//

#import "CarletonBuildings.h"
#import "JSON.h"

@implementation CarletonBuildings

-(id)init {
	if (self = [super init]) {
		self.name = @"CarletonBuildings";
	}
	return self;
}


-(NSMutableArray*)getNClosestLandmarks:(int)n toLocation:(CLLocation*)location withLM:(GNLayerManager*)layerManager {
	[self removeSelfFromLandmarks];
	
	int i;
	NSMutableArray *oldLayerInfo = [[layerInfoByLandmarkID allValues] mutableCopy];
	// release old layer info
	for(i = 0; i < [oldLayerInfo count]; i++)
		[[oldLayerInfo objectAtIndex:i] release];
	[layerInfoByLandmarkID removeAllObjects];
	
	NSString *urlString = [NSString stringWithFormat:@"http://dev.gnar.us/getInfo.py/%@?lat=%f&lon=%f&maxLandmarks=%d",
						   self.name, [location coordinate].latitude, [location coordinate].longitude, n];
	NSURL *url = [NSURL URLWithString:urlString];
	//////////////////////// TODO: What should we do with the error?
	NSString *reply = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	
	// parse the reply
	SBJSON *parser = [[SBJSON alloc] init];
	NSArray *layerInfoList = [parser objectWithString:reply error:nil];
	
	// load the distance and landmark info
	NSDictionary *landmarkAndLayerInfo;
	NSMutableDictionary *layerInfo;
	GNLandmark *landmark;
	
	for (landmarkAndLayerInfo in layerInfoList)
	{
		layerInfo = [[NSMutableDictionary alloc] init];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"imageURL"] forKey:@"imageURL"];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"summary"] forKey:@"summary"];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"yearBuilt"] forKey:@"yearBuilt"];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"description"] forKey:@"description"];
		
		landmark = [layerManager getLandmark:[[landmarkAndLayerInfo objectForKey:@"ID"] intValue]
											name:[landmarkAndLayerInfo objectForKey:@"name"]
										latitude:[[landmarkAndLayerInfo objectForKey:@"latitude"] floatValue]
									   longitude:[[landmarkAndLayerInfo objectForKey:@"longitude"] floatValue]];
		[landmark addActiveLayer:self];
		[layerInfoByLandmarkID setObject:layerInfo forKey:[NSNumber numberWithInt:landmark.ID]];
		
		landmark.distance = [[landmarkAndLayerInfo objectForKey:@"distance"] floatValue];
		
		[self.closestLandmarks addObject:landmark];
	}
	
	[self.closestLandmarks sortUsingSelector:@selector(compareTo:)];
	return self.closestLandmarks;
}

-(NSString*)getSummaryStringForID:(int)landmarkID {
	return [(NSMutableDictionary*) [layerInfoByLandmarkID objectForKey:[NSNumber numberWithInt:landmarkID]]
			objectForKey:@"summary"];
}

-(UIViewController*)getLayerViewForID:(int)landmarkID {
	return nil;
}

@end