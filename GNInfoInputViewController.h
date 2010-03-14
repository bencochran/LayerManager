//
//  GNInfoInputViewController.h
//  A general UIViewController that allows for entering and editing
//    different types of strings in different UI fields
//  (Used by GNEditingTableViewController)
//
//  Created by Jake Kring on 2/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GNInfoInputViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate> {

	UILabel *label;
	UITextView *textView;
	UITextField *textField;
	NSArray *fieldArray;
	NSString *inputString;
	NSString *savedInput;
}

- (id)initWithFieldArray:(NSArray *)fieldArray andInput:(NSString *)input;

@end
