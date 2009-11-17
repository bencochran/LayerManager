//
//  CarletonBuildings.m
//  LayerManager
//
//  Created by iComps on 11/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
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
	[self.closestLandmarks removeAllObjects];
	
	int i;
	NSMutableArray *oldLayerInfo = [[layerInfoByLandmarkID allValues] mutableCopy];
	// free old layer info
	for(i = 0; i < [oldLayerInfo count]; i++)
		[[oldLayerInfo objectAtIndex:i] release];
	[layerInfoByLandmarkID removeAllObjects];
	
	double lat = [location coordinate].latitude;
	double lon = [location coordinate].longitude;
	
	NSString *urlString = [NSString stringWithFormat:@"http://dev.gnar.us/getInfo.py/%@?lat=%f;long=%f;maxLandmarks=%d.json",
						   self.name, lat, lon, n];
	NSURL *url = [NSURL URLWithString:urlString];
	// TODO: What should we do with the error?
	NSString *reply = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	SBJSON *parser = [[SBJSON alloc] init];
	NSArray *layerInfoList = [parser objectWithString:reply error:nil];
	NSDictionary *landmarkAndLayerInfo;
	GNLandmark *currLandmark;
	CLLocation *currLandmarkLocation;
	NSMutableDictionary *layerInfo;
	GNDistAndLandmark *currGNDL;
	
	for(i = 0; i < [layerInfoList count]; i++)
	{
		landmarkAndLayerInfo = [layerInfoList objectAtIndex:i];
		layerInfo = [[NSMutableDictionary alloc] init];
		
		[layerInfo setValue:[landmarkAndLayerInfo objectForKey:@"imageURL"] forKey:@"imageURL"];
		[layerInfo setValue:[landmarkAndLayerInfo objectForKey:@"summary"] forKey:@"summary"];
		[layerInfo setValue:[landmarkAndLayerInfo objectForKey:@"yearBuilt"] forKey:@"yearBuilt"];
		[layerInfo setValue:[landmarkAndLayerInfo objectForKey:@"description"] forKey:@"description"];
		
		currLandmarkLocation = [[CLLocation alloc] initWithLatitude:[[landmarkAndLayerInfo objectForKey:@"latitude"] floatValue]
														   longitude:[[landmarkAndLayerInfo objectForKey:@"longitude"] floatValue]];
		currLandmark = [layerManager getLandmark:[[landmarkAndLayerInfo objectForKey:@"ID"] intValue]
											name:[landmarkAndLayerInfo objectForKey:@"name"]
										location:currLandmarkLocation];
		[layerInfoByLandmarkID setObject:layerInfo forKey:[NSNumber numberWithInt:currLandmark.ID]];
		currGNDL = [[GNDistAndLandmark alloc] init];
		currGNDL.dist = [[landmarkAndLayerInfo objectForKey:@"distance"] floatValue];
		currGNDL.landmark = currLandmark;
		[self.closestLandmarks addObject:currGNDL];
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