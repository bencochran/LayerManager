//
//  DiningAreasLayer.m
//  LayerManager
//
//  Created by iComps on 11/16/09.
//  Copyright 2009 Gnarus. All rights reserved.
//

#import "DiningAreasLayer.h"
#import "JSON.h"

@implementation DiningAreasLayer

-(id)init {
	if (self = [super init]) {
		self.name = @"Dining";
	}
	return self;
}

- (NSURL *)URLForLocation:(CLLocation *)location {	
	// http://dev.gnar.us/getInfo.py/DiningAreas?lat=44.46055309703&lon=-93.1566672394&maxLandmarks=2
	NSString *urlString = [NSString stringWithFormat:@"http://dev.gnar.us/getInfo.py/DiningAreas?lat=%f&lon=%f&maxLandmarks=%d",
						   [location coordinate].latitude, [location coordinate].longitude, [[GNLayerManager sharedManager] maxLandmarks]];
	return [NSURL URLWithString:urlString];
}

- (void)ingestNewData:(NSData *)data {
	[self removeSelfFromLandmarks];
	
	[layerInfoByLandmark removeAllObjects];
	
//	NSString *reply = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSString *reply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	
	// parse the reply
	SBJSON *parser = [[SBJSON alloc] init];
	NSArray *layerInfoList = [parser objectWithString:reply error:nil];
	[parser release]; parser = nil;
	[reply release]; reply = nil;
	
	// load the distance and landmark info
	NSDictionary *landmarkAndLayerInfo;
	NSMutableDictionary *layerInfo;
	GNLandmark *landmark;
	
	for (landmarkAndLayerInfo in layerInfoList)
	{
		layerInfo = [[NSMutableDictionary alloc] init];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"menuURL"] forKey:@"menuURL"];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"summary"] forKey:@"summary"];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"description"] forKey:@"description"];
		
		landmark = [[GNLayerManager sharedManager] getLandmark:[[landmarkAndLayerInfo objectForKey:@"ID"] intValue]
														  name:[landmarkAndLayerInfo objectForKey:@"name"]
													  latitude:[[landmarkAndLayerInfo objectForKey:@"latitude"] floatValue]
													 longitude:[[landmarkAndLayerInfo objectForKey:@"longitude"] floatValue]];
		[landmark addActiveLayer:self];
		[layerInfoByLandmark setObject:layerInfo forKey:landmark];
		
		landmark.distance = [[landmarkAndLayerInfo objectForKey:@"distance"] floatValue];
		[layerInfo release];
		
		[self.closestLandmarks addObject:landmark];
	}
	
	[self.closestLandmarks sortUsingSelector:@selector(compareTo:)];
	[[GNLayerManager sharedManager] layerDidUpdate:self withLandmarks:self.closestLandmarks];
}

- (NSString *)summaryForLandmark:(GNLandmark *)landmark {
	return [(NSDictionary*) [layerInfoByLandmark objectForKey:landmark] objectForKey:@"summary"];
}

- (UIViewController *)viewControllerForLandmark:(GNLandmark *)landmark {
	return [[[UIViewController alloc] initWithCoder:nil] autorelease];
}

@end