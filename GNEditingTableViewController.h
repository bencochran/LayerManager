//
//  GNEditingTableViewController.h
//  LayerManager
//
//  Created by iComps on 1/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GNLayer.h"
#import "GNLandmark.h"

@interface GNEditingTableViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	NSArray *fields;
	NSInteger currentField;
	NSMutableArray *userInput;
	GNLayer *selectedLayer;
	CLLocation *selectedLocation;
	GNLandmark *selectedLandmark;
	UIImagePickerController *photoController;
	UIButton *takePhotoButton;
	UIView *buttonContainer;
	UIImage *photo;
	UIImageView *photoView;
	NSDictionary *infoDictionary;


}

- (id)initWithFields:(NSArray *)newFields andLayer:(GNLayer *)layer andLocation:(CLLocation *)location andLandmark:(GNLandmark *)landmark;

- (void)addUserInput:(NSString *)input toField:(NSInteger)index;

-(IBAction) takePhoto:(id) sender;

- (NSInteger)getCurrentField;

@end