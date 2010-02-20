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
		self.name = @"Wikipedia";
		iconPath = @"wiki.png";
		userModifiable = NO;
	}
	return self;
}

- (NSURL *)URLForLocation:(CLLocation *)location limitToValidated:(BOOL)limitToValidated {
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

- (NSArray *)parseDataIntoLandmarks:(NSData *)data {	
	NSString *reply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	SBJSON *parser = [[SBJSON alloc] init];
	NSDictionary *layerInfoList = [parser objectWithString:reply error:nil];
	[reply release]; reply = nil;
	[parser release]; parser = nil;
	
	// load the distance and landmark info
	NSMutableDictionary *layerInfo;
	GNLandmark *landmark;
	NSString *wikiURL;
	NSString *landmarkName;
	CLLocationDegrees landmarkLon;
	CLLocationDegrees landmarkLat;
	NSMutableArray *landmarks = [NSMutableArray array];
	
	for (NSDictionary *landmarkAndLayerInfo in [[layerInfoList objectForKey:@"results"] objectForKey:@"bindings"])
	{
		layerInfo = [[NSMutableDictionary alloc] init];
		// Build the wikipedia URL using the dbpedia resource URL.
		// Also be sure to give it the correct-language wikipedia subdomain
		wikiURL = [[[landmarkAndLayerInfo objectForKey:@"s"]
					objectForKey:@"value"]
				   stringByReplacingOccurrencesOfString:@"://dbpedia.org/resource/"
				   withString:[NSString stringWithFormat:@"://%@.wikipedia.org/wiki/",
							   [[landmarkAndLayerInfo objectForKey:@"name"]
								objectForKey:@"xml:lang"]]];
		
		landmarkName = [[landmarkAndLayerInfo objectForKey:@"name"] objectForKey:@"value"];
		landmarkLat = [(NSString *)[[landmarkAndLayerInfo objectForKey:@"lat"] objectForKey:@"value" ] floatValue];
		landmarkLon = [(NSString *)[[landmarkAndLayerInfo objectForKey:@"long"] objectForKey:@"value" ] floatValue];
		
		[layerInfo setObject:wikiURL forKey:@"wikiURL"];
		
		landmark = [[GNLayerManager sharedManager] getLandmark:[NSString stringWithFormat:@"gnarus:%@", wikiURL]
														  name:landmarkName
													  latitude:landmarkLat
													 longitude:landmarkLon
													  altitude:center.altitude];
		[layerInfoByLandmarkID setObject:layerInfo forKey:landmark.ID];
		
		// calculate distance
		landmark.distance = [landmark getDistanceFrom:center];
		
		[layerInfoByLandmarkID setObject:layerInfo forKey:landmark.ID];
		[layerInfo release]; layerInfo = nil;
		[landmarks addObject:landmark];
	}
	
	return landmarks;
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
	NSString *urlString = [[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"wikiURL"];
	
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
	
	viewController.title = self.name;
	viewController.view = webView;

	[webView release];
	
	return [viewController autorelease];	
}

@end