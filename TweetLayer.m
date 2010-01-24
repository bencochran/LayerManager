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
	
	NSString *reply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	SBJSON *parser = [[SBJSON alloc] init];
	NSDictionary *parsedReply = [parser objectWithString:reply error:nil];
	[reply release];
	[parser release];
	
	NSArray *tweets = [parsedReply objectForKey:@"results"];
	
	// load the distance and landmark info
	NSDictionary *tweet;
	GNLandmark *landmark;
	NSMutableDictionary *layerInfo;

	NSNumber *latitude;
	NSNumber *longitude;
	
	for (tweet in tweets)
	{
		if (![[tweet objectForKey:@"geo"] isKindOfClass:[NSNull class]]) {
			//NSLog(@"tweet: %@", tweet);
			
			latitude = [[[tweet objectForKey:@"geo"] objectForKey:@"coordinates"] objectAtIndex:0];
			longitude = [[[tweet objectForKey:@"geo"] objectForKey:@"coordinates"] objectAtIndex:1];
			NSLog(@"id: %@",[tweet objectForKey:@"id"]);
			
			layerInfo = [[NSMutableDictionary alloc] init];
			[layerInfo setObject:[tweet objectForKey:@"from_user"] forKey:@"from_user"];
			[layerInfo setObject:[tweet objectForKey:@"text"] forKey:@"text"];
			[layerInfo setObject:[tweet objectForKey:@"id"] forKey:@"id"];
			
			landmark = [[GNLayerManager sharedManager] getLandmark:[NSString stringWithFormat:@"twitter:%@",[tweet objectForKey:@"id"]]
															  name:[tweet objectForKey:@"from_user"]
														  latitude:[latitude floatValue]
														 longitude:[longitude floatValue]
														  altitude:center.altitude];
			
			if (self.active) {
				[landmark addActiveLayer:self];
			}
			[layerInfoByLandmarkID setObject:tweet forKey:landmark.ID];
			
			// calculate distance
			landmark.distance = [landmark getDistanceFrom:center];
			[self.landmarks addObject:landmark];
			
			[layerInfoByLandmarkID setObject:layerInfo forKey:landmark.ID];
			[layerInfo release];
		}
	}
	
	[self.landmarks sortUsingSelector:@selector(compareTo:)];
	[[GNLayerManager sharedManager] layerDidUpdate:self withLandmarks:self.landmarks];
}

- (NSString *)summaryForLandmark:(GNLandmark *)landmark {
	return [(NSDictionary*) [layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"text"];
}

- (UIViewController *)viewControllerForLandmark:(GNLandmark *)landmark {
	UIViewController *viewController = [[UIViewController alloc] init];
	UIWebView *webView = [[UIWebView alloc] init];
	NSString *username = [[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"from_user"];
	NSString *tweetid = [[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"id"];
	NSString *urlString = [NSString stringWithFormat:@"http://twitter.com/%@/status/%@", username, tweetid];
	
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
	
	viewController.title = self.name;
	viewController.view = webView;
	[webView release];
	
	return [viewController autorelease];;
}

@end
