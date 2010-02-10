//
//  WikiLayer.m
//  LayerManager
//
//  Created by Jake Kring on 2/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WikiLayer.h"
#import "JSON.h"

@implementation WikiLayer

-(id)init {
	if (self = [super init]) {
		self.name = @"Wiki";
		iconPath = @"food.png";
		userModifiable = NO;
	}
	return self;
}

- (NSURL *)URLForLocation:(CLLocation *)location {
	NSString *urlString = @"http://dbpedia.org/sparql?default-graph-uri=http://dbpedia.org&should-sponge=&query=PREFIX+geo:<http://www.w3.org/2003/01/geo/wgs84_pos%23>PREFIX+p:<http://dbpedia.org/property/>SELECT+%3Fs+%3Fname+%3Flat+%3Flong+WHERE{%3Fs+geo:lat+%3Flat+.%3Fs+geo:long+%3Flong+.%3Fs+p:name+%3Fname+.FILTER+(%3Flat<%3D44.45%2B.1%26%26+%3Flong>%3D-93.15-.1+%26%26+%3Flat>%3D44.45-.1+%26%26+%3Flong<%3D-93.15%2B.1)}&format=JSON&debug=on&timeout=";
	return [NSURL URLWithString:urlString];
}

- (void)ingestNewData:(NSData *)data {
	[self removeSelfFromLandmarks];
	[layerInfoByLandmarkID removeAllObjects];
	
	NSString *reply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	SBJSON *parser = [[SBJSON alloc] init];
	NSArray *layerInfoList = [parser objectWithString:reply error:nil];
	[reply release]; reply = nil;
	[parser release]; parser = nil;
	
	// load the distance and landmark info
	//NSMutableDictionary *layerInfo;
	//GNLandmark *landmark;
	
	for (NSDictionary *landmarkAndLayerInfo in layerInfoList)
	{
		//layerInfo = [[NSMutableDictionary alloc] init];
		//[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"menu"] forKey:@"menu"];
		//[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"imageURL"] forKey:@"imageURL"];
		//[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"summary"] forKey:@"summary"];
		//[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"description"] forKey:@"description"];
		
		//landmark = [[GNLayerManager sharedManager] getLandmark:[NSString stringWithFormat:@"gnarus:%@", [landmarkAndLayerInfo objectForKey:@"ID"]]
		//												  name:[landmarkAndLayerInfo objectForKey:@"name"]
		//											  latitude:[[landmarkAndLayerInfo objectForKey:@"latitude"] floatValue]
		//											 longitude:[[landmarkAndLayerInfo objectForKey:@"longitude"] floatValue]
		//											  altitude:center.altitude];
		//landmark.distance = [[landmarkAndLayerInfo objectForKey:@"distance"] floatValue];
		//if (self.active) {
		//	[landmark addActiveLayer:self];
		//}
		
		//[layerInfoByLandmarkID setObject:layerInfo forKey:landmark.ID];
		//[self.landmarks addObject:landmark];
		//[layerInfo release];
	//}
	
	//[self.landmarks sortUsingSelector:@selector(compareTo:)];
	//[[GNLayerManager sharedManager] layerDidUpdate:self withLandmarks:self.landmarks];
	}
}
- (void)requestFinished:(ASIHTTPRequest *)request{
	// Use when fetching text data
	NSString *responseString = [request responseString];
	NSLog(@"Finished: %@", responseString);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	NSLog(@"Error: %@", error);
}


- (NSString *)summaryForLandmark:(GNLandmark *)landmark {
	return [(NSDictionary*) [layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"summary"];
}

- (UIViewController *)viewControllerForLandmark:(GNLandmark *)landmark {
	UIViewController *viewController = [[UIViewController alloc] init];
		UIWebView *webView = [[UIWebView alloc] init];
		NSString *urlString = @"www.wikipedia.org";
	
		[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
		
		viewController.title = self.name;
		viewController.view = webView;
		[webView release];
	
	return [viewController autorelease];;
}

@end