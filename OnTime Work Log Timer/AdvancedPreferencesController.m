//
//  AdvancedPreferencesController.m
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 4/16/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import "AdvancedPreferencesController.h"

@interface AdvancedPreferencesController ()

@end

@implementation AdvancedPreferencesController


- (id)init
{
    self = [super initWithNibName:@"AdvancedPreferencesController" bundle:nil];
    if (self) {
        _managedObjectContext = [[CoreDataHelper sharedInstance] managedObjectContext];
        
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self.taskTableView registerForDraggedTypes:[NSArray arrayWithObjects:[self.taskTypeController entityName], nil]];
    [self.taskTableView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
}

- (NSString *)identifier
{
    return @"AdvancedPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameAdvanced];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"Advanced", @"Toolbar item name for the Advanced preference pane");
}

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pasteboard {
    return NO;
    NSLog(@"Write");
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
	[pasteboard declareTypes:[NSArray arrayWithObject:[self.taskTypeController entityName]] owner:self];
	[pasteboard setData:data forType:[self.taskTypeController entityName]];
	return YES;
}


- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op {
    NSLog(@"Validate drop");
		if (op == NSTableViewDropOn)
			[tv setDropRow:row dropOperation:NSTableViewDropAbove];
		
		if ([[[NSApplication sharedApplication] currentEvent] modifierFlags] & NSAlternateKeyMask)
			return NSDragOperationCopy;
		else
			return NSDragOperationMove;

}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
    NSLog(@"Accept");
	NSDictionary *bindingInfo = [self.taskTypeController infoForBinding:@"contentArray"];
	NSMutableOrderedSet *s = [[bindingInfo objectForKey:NSObservedObjectKey] mutableOrderedSetValueForKeyPath:[bindingInfo objectForKey:NSObservedKeyPathKey]];
	NSLog(@"S: %@", s);
	NSPasteboard *pasteboard = [info draggingPasteboard];
	NSData *rowData = [pasteboard dataForType:[self.taskTypeController entityName]];
	NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
	if ([rowIndexes firstIndex] > row) {
		// we're moving up
        NSLog(@"Moving Up");
		[s moveObjectsAtIndexes:rowIndexes toIndex:row];
	} else {
		// we're moving down
        NSLog(@"Moving Down");
		[s moveObjectsAtIndexes:rowIndexes toIndex:row-[rowIndexes count]];
	}
	
	return YES;
}
@end
