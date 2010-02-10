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
	NSString *query = [NSString stringWithFormat:@"PREFIX geo:<http://www.w3.org/2003/01/geo/wgs84_pos#>\n"
												  "PREFIX p:<http://dbpedia.org/property/>\n"
												  "SELECT ?s ?name ?lat ?long WHERE{\n"
												  "?s geo:lat ?lat .\n"
												  "?s geo:long ?long .\n"
												  "?s p:name ?name .\n"
												  "FILTER (\n"
												  "?lat<=%f+.1 &&\n"
												  "?long>=%f-.1 &&\n"
												  "?lat>=%f-.1 &&\n"
												  "?long<=%f+.1)\n"
												  "}",
					   [location coordinate].latitude,
					   [location coordinate].longitude,
					   [location coordinate].latitude,
					   [location coordinate].longitude];
	
	query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	// Escape a few extras missed by that method
	query = [query stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
	query = [query stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];

	// Now build the whole URL
	NSString *urlString = [NSString stringWithFormat:@"http://dbpedia.org/sparql?query=%@&format=json", query];
	
	return [NSURL URLWithString:urlString];
}

- (void)ingestNewData:(NSData *)data {
	[self removeSelfFromLandmarks];
	[layerInfoByLandmarkID removeAllObjects];
	
	NSString *reply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	SBJSON *parser = [[SBJSON alloc] init];
	NSArray *layerInfoList = [parser objectWithString:reply error:nil];
	NSLog(@"Got wiki data %@", layerInfoList);
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