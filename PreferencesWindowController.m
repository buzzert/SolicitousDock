//
//  PreferencesWindowController.m
//  Solicitous Dock
//
//  Created by Charles Magahern on 12/17/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "PreferencesWindowController.h"
#import "Solicitous_DockAppDelegate.h"

@implementation PreferencesWindowController {
    NSButton *_hideShowCheckbox;
    NSTableView *_appsTableView;
    NSButton *_removeRowButton;
    
    NSMutableArray *_activeApps;
}

@synthesize hideShowCheckbox = _hideShowCheckbox;
@synthesize appsTableView = _appsTableView;
@synthesize removeRowButton = _removeRowButton;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    BOOL hideShowValue = [[NSUserDefaults standardUserDefaults] boolForKey:SDPreferencesHideShowWhenSwitchingKey];
    [_hideShowCheckbox setState:hideShowValue];
    
    Solicitous_DockAppDelegate *del = (Solicitous_DockAppDelegate *) [[NSApplication sharedApplication] delegate];
    _activeApps = [del toggleApps];
    
    if ([_activeApps count] == 0) {
        [_removeRowButton setEnabled:NO];
    }
    
    [[self window] center];
}

- (void)saveChangesToFile {
    [[NSUserDefaults standardUserDefaults] setObject:_activeApps forKey:SDPreferencesToggleAppsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)hideShowCheckboxAction:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[_hideShowCheckbox state] forKey:SDPreferencesHideShowWhenSwitchingKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)addRowButtonAction:(id)sender {
    NSOpenPanel *filePanel = [NSOpenPanel openPanel];
    [filePanel setCanChooseFiles:YES];
    [filePanel setCanChooseDirectories:NO];
    
    [filePanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            NSArray *selectedItems = [filePanel URLs];
            NSURL *selectedItem = [selectedItems objectAtIndex:0];
            
            NSBundle *appBundle = [NSBundle bundleWithURL:selectedItem];
            NSString *bundleIdentifier = [appBundle bundleIdentifier];
            NSString *appName = [[appBundle infoDictionary] objectForKey:@"CFBundleName"];
            
            NSDictionary *appEntry = @{ SDApplicationNameKey : appName, SDApplicationBundleIdentifierKey : bundleIdentifier };
            [_activeApps addObject:appEntry];
            
            [_appsTableView reloadData];
            [self saveChangesToFile];
            
            if (![_removeRowButton isEnabled]) {
                [_removeRowButton setEnabled:YES];
            }
        }
    }];
}

- (IBAction)removeRowButtonAction:(id)sender {
    NSIndexSet *selected = [_appsTableView selectedRowIndexes];
    [_activeApps removeObjectsAtIndexes:selected];
    [_appsTableView reloadData];
    
    [self saveChangesToFile];
    
    if ([_activeApps count] == 0) {
        [_removeRowButton setEnabled:NO];
    }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    return [[_activeApps objectAtIndex:rowIndex] objectForKey:SDApplicationNameKey];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_activeApps count];
}

- (void)dealloc {
    
    [super dealloc];
}

@end
