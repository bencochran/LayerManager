//
//  FlickrLayer.m
//  LayerManager
//
//  Created by Jake Kring on 2/20/10.
//  Copyright 2010 Gnarus. All rights reserved.
//

#import "FlickrLayer.h"


@implementation FlickrLayer 

-(id)init {
	if (self = [super init]) {
		self.name = @"Flickr";
		iconPath = @"wiki.png";
		userModifiable = NO;
		context = [[OFFlickrAPIContext alloc] initWithAPIKey:@"508f5e95cf2b731546019a71fbcbe992" sharedSecret:@"3e8565ce4738e808"];
	}
	return self;
}

- (void)updateToCenterLocation:(CLLocation *)location {
	if (self.active != YES) {
		// Well, this shouldn't have happened.
		NSLog(@"updateToCenterLocation: was called on %s, which is inavtive", [self name]);
		return;
	}
	center = [location retain];
	OFFlickrAPIRequest *request = [[OFFlickrAPIRequest alloc] initWithAPIContext:context];
	[request setDelegate:self];
	[request callAPIMethodWithGET:@"flickr.photos.geo.photosForLocation" arguments:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",location.coordinate.latitude], @"lat",[NSString stringWithFormat:@"%f",location.coordinate.longitude], @"lon", nil]];
	}

- (NSArray *)parseDataIntoLandmarks:(NSData *)data {	
	//NSString *reply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	//SBJSON *parser = [[SBJSON alloc] init];
	//NSDictionary *layerInfoList = [parser objectWithString:reply error:nil];
	//[reply release]; reply = nil;
	//[parser release]; parser = nil;
	
	// load the distance and landmark info
	//NSMutableDictionary *layerInfo;
	//GNLandmark *landmark;
	//NSString *wikiURL;
	//NSString *landmarkName;
	//CLLocationDegrees landmarkLon;
	//CLLocationDegrees landmarkLat;
	//NSMutableArray *landmarks = [NSMutableArray array];
	
	//for (NSDictionary *landmarkAndLayerInfo in [[layerInfoList objectForKey:@"results"] objectForKey:@"bindings"])
	//{
	//	layerInfo = [[NSMutableDictionary alloc] init];
		// Build the wikipedia URL using the dbpedia resource URL.
		// Also be sure to give it the correct-language wikipedia subdomain
	//	wikiURL = [[[landmarkAndLayerInfo objectForKey:@"s"]
	//				objectForKey:@"value"]
	//			   stringByReplacingOccurrencesOfString:@"://dbpedia.org/resource/"
	//			   withString:[NSString stringWithFormat:@"://%@.wikipedia.org/wiki/",
	//						   [[landmarkAndLayerInfo objectForKey:@"name"]
	//							objectForKey:@"xml:lang"]]];
		
	//	landmarkName = [[landmarkAndLayerInfo objectForKey:@"name"] objectForKey:@"value"];
	//	landmarkLat = [(NSString *)[[landmarkAndLayerInfo objectForKey:@"lat"] objectForKey:@"value" ] floatValue];
	//	landmarkLon = [(NSString *)[[landmarkAndLayerInfo objectForKey:@"long"] objectForKey:@"value" ] floatValue];
		
	//	[layerInfo setObject:wikiURL forKey:@"wikiURL"];
		
	//	landmark = [[GNLayerManager sharedManager] getLandmark:[NSString stringWithFormat:@"gnarus:%@", wikiURL]
	//													  name:landmarkName
	//												  latitude:landmarkLat
	//												 longitude:landmarkLon
	//												  altitude:center.altitude];
	//	[layerInfoByLandmarkID setObject:layerInfo forKey:landmark.ID];
		
		// calculate distance
	//	landmark.distance = [landmark getDistanceFrom:center];
		
	//	[layerInfoByLandmarkID setObject:layerInfo forKey:landmark.ID];
	//	[layerInfo release]; layerInfo = nil;
	//	[landmarks addObject:landmark];
	//}
	
	//return landmarks;
}
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary{
	NSLog(@"request succeeded");
		NSLog(@"photo ID,%@", [inResponseDictionary objectForKey:@"photo id"]);
}
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError{
	NSLog(@"some sort of error occured: %d", [inError code]);
	}	
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest imageUploadSentBytes:(NSUInteger)inSentBytes totalBytes:(NSUInteger)inTotalBytes{
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
