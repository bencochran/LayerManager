//
//  CarletonBuildingsLayer.m
//  LayerManager
//
//  Created by iComps on 11/16/09.
//  Copyright 2009 Gnarus. All rights reserved.
//

#import "CarletonBuildingsLayer.h"
#import "JSON.h"

@implementation CarletonBuildingsLayer

-(id)init {
	if (self = [super init]) {
		self.name = @"CarletonBuildingsLayer";
	}
	return self;
}


-(NSMutableArray*)getNClosestLandmarks:(int)n toLocation:(CLLocation*)location withLM:(GNLayerManager*)layerManager {
	[self removeSelfFromLandmarks];

	[layerInfoByLandmarkID removeAllObjects];
	
	// http://dev.gnar.us/getInfo.py/CarletonBuildings?lat=44.46055309703;lon=-93.1566672394;maxLandmarks=2
	NSString *urlString = [NSString stringWithFormat:@"http://dev.gnar.us/getInfo.py/CarletonBuildings?lat=%f&lon=%f&maxLandmarks=%d",
						   [location coordinate].latitude, [location coordinate].longitude, n];
	NSURL *url = [NSURL URLWithString:urlString];
	//////////////////////// TODO: What should we do with the error?
	NSString *reply = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	
	// parse the reply
	SBJSON *parser = [[SBJSON alloc] init];
	NSArray *layerInfoList = [parser objectWithString:reply error:nil];
	[parser release];
	
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
		[layerInfo release];
		
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