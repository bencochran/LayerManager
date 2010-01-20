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

- (NSURL *)URLForLocation:(CLLocation *)location {	
	// http://search.twitter.com/search.json?geocode=44.46087,-93.1536,5mi&rpp=50	
	NSString *urlString = [NSString stringWithFormat:@"http://search.twitter.com/search.json?geocode=%f,%f,5mi&ppm=100",
						   [location coordinate].latitude, [location coordinate].longitude];
	return [NSURL URLWithString:urlString];
}

- (void)ingestNewData:(NSData *)data {
	[self removeSelfFromLandmarks];
	
	[layerInfoByLandmarkID removeAllObjects];
	
//	NSString *reply = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSString *reply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	
	// parse the reply
	SBJSON *parser = [[SBJSON alloc] init];
	NSDictionary *parsedReply = [parser objectWithString:reply error:nil];
	[parser release];
	[reply release];
	
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
			
			landmark = [[GNLayerManager sharedManager] getLandmark:[NSString stringWithFormat:@"twitter:%@",[tweet objectForKey:@"id"]]
															  name:[tweet objectForKey:@"from_user"]
														  latitude:[latitude floatValue]
														 longitude:[longitude floatValue]
														  altitude:center.altitude];
			
			[landmark addActiveLayer:self];
			[layerInfoByLandmarkID setObject:tweet forKey:landmark.ID];
			
			// calculate distance
			landmark.distance = [landmark getDistanceFrom:center];
			[self.landmarks addObject:landmark];
		}
	}
	
	[self.landmarks sortUsingSelector:@selector(compareTo:)];
	[[GNLayerManager sharedManager] layerDidUpdate:self withLandmarks:self.landmarks];
}

- (NSString *)summaryForLandmark:(GNLandmark *)landmark {
	return [(NSDictionary*) [layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"text"];
}

- (UIViewController *)viewControllerForLandmark:(GNLandmark *)landmark {
	return [[[UIViewController alloc] initWithCoder:nil] autorelease];
}

@end
