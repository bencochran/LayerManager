//
//  GNEditingTableViewController.h
//  LayerManager
//
//  Created by iComps on 1/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GNLayer.h"

@interface GNEditingTableViewController : UITableViewController {
	NSArray *fields;
	NSInteger currentField;
	NSMutableArray *userInput;
	GNLayer *selectedLayer;
	CLLocation *selectedLocation;
	//UIImagePickerController *photoTaker;


}

- (id)initWithFields:(NSArray *)newFields andLayer:(GNLayer *)layer andLocation:(CLLocation *)location;

- (void)addUserInput:(NSString *)input toField:(NSInteger)index;

- (NSInteger)getCurrentField;

@end