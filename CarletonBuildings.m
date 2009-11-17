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
	return [GNLayer layerWithName:@"CarletonBuildings"];
}

-(NSMutableArray*)getNClosestLandmarks:(int)n toLocation:(CLLocation*)location {
	double lat = [location coordinate].latitude;
	double lon = [location coordinate].longitude;
	
	NSString *urlString = [NSString stringWithFormat:@"http://dev.gnar.us/getInfo.py/%@?lat=%f;long=%f;maxLandmarks=%d.json",
						   self.name, lat, lon, n];
	NSURL *url = [NSURL URLWithString:urlString];
	// TODO: What should we do with the error?
	NSString *reply = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	SBJSON *parser = [[SBJSON alloc] init];
	NSArray *layerInfoList = [parser objectWithString:reply error:nil];
	
	
	return nil;
}

-(NSString*)getSummaryStringForID:(int)landmarkID {
	return [(NSMutableDictionary*) [layerInfoByLandmarkID objectForKey:[NSNumber numberWithInt:landmarkID]]
			objectForKey:@"summary"];
}

-(UIViewController*)getLayerViewForID:(int)landmarkID {
	return nil;
}

@end