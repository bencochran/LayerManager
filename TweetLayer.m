//
//  TweetLayer.m
//  LayerManager
//
//  Created by Ben Cochran on 12/8/09.
//  Copyright 2009 Ben Cochran. All rights reserved.
//

#import "TweetLayer.h"
#import "JSON.h"

@implementation TweetLayer

-(id)init {
	if (self = [super init]) {
		self.name = @"Tweets";
	}
	return self;
}


-(NSMutableArray*)getNClosestLandmarks:(int)n toLocation:(CLLocation*)location withLM:(GNLayerManager*)layerManager {
	[self removeSelfFromLandmarks];

	[layerInfoByLandmarkID removeAllObjects];
	
	// http://search.twitter.com/search.json?geocode=44.46087,-93.1536,5mi&rpp=50
	
	NSString *urlString = [NSString stringWithFormat:@"http://search.twitter.com/search.json?geocode=%f,%f,5mi&ppm=100",
						   [location coordinate].latitude, [location coordinate].longitude];
	NSURL *url = [NSURL URLWithString:urlString];
	//////////////////////// TODO: What should we do with the error?
	NSString *reply = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
		
	// parse the reply
	SBJSON *parser = [[SBJSON alloc] init];
	NSDictionary *parsedReply = [parser objectWithString:reply error:nil];
	[parser release];
	
	NSArray *tweets = [parsedReply objectForKey:@"results"];
	
	
	// load the distance and landmark info
	NSDictionary *tweet;
	GNLandmark *landmark;
	
	NSNumber *latitude;
	NSNumber *longitude;
	
	for (tweet in tweets)
	{
		if (![[tweet objectForKey:@"geo"] isKindOfClass:[NSNull class]]) {
			//NSLog(@"tweet: %@", tweet);
		
			latitude = [[[tweet objectForKey:@"geo"] objectForKey:@"coordinates"] objectAtIndex:0];
			longitude = [[[tweet objectForKey:@"geo"] objectForKey:@"coordinates"] objectAtIndex:1];
			NSLog(@"id: %@",[tweet objectForKey:@"id"]);
			
			// this conversion from tweet id to int is causing an overflow.
			landmark = [layerManager getLandmark:[[tweet objectForKey:@"id"] intValue]
											name:[tweet objectForKey:@"from_user"]
										latitude:[latitude floatValue]
									   longitude:[longitude floatValue]];
			
			[landmark addActiveLayer:self];
			[layerInfoByLandmarkID setObject:tweet forKey:[NSNumber numberWithInt:landmark.ID]];
						
			// convert distance to miles
			landmark.distance = [landmark getDistanceFrom:location]/1609.344;
			[self.closestLandmarks addObject:landmark];
		}
	}
	
	[self.closestLandmarks sortUsingSelector:@selector(compareTo:)];
	return self.closestLandmarks;
}

-(NSString*)getSummaryStringForID:(int)landmarkID {
//	return @"Helloooooo";
	return [(NSDictionary*) [layerInfoByLandmarkID objectForKey:[NSNumber numberWithInt:landmarkID]] objectForKey:@"text"];
//	return [(NSMutableDictionary*) [layerInfoByLandmarkID objectForKey:[NSNumber numberWithInt:landmarkID]]
//			objectForKey:@"summary"];
}

-(UIViewController*)getLayerViewForID:(int)landmarkID {
	return nil;
}

@end
