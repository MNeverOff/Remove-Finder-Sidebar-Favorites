//
//  main.m
//  Remove Sidebar Favorites
//
//  Created by Mikhail Neverov on 26.12.2021
//  mike@neveroff.dev
//

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>
#import <Appkit/AppKit.h>

const int TIMEOUT = 300; // Number of seconds to repeat the code after app launch
const int TIMEOUT_CLEANUP = 60; // Number of seconds after the first folder removal was detected to allow Google Drive to get rid of the folders slowly appearing in case of multiple folders being present
const double SLEEP_INTERVAL = 1; // Constant for the thread sleep, 1 second by default
bool FOLDERS_REMOVED = false; // A flag to break the cycle early

void remove_by_name(NSString* input) {
    // Getting the shared file list (sfl) reference
    LSSharedFileListRef favoriteItems = LSSharedFileListCreate(NULL,  kLSSharedFileListFavoriteItems, NULL);
    // Getting the current snapshot of the sfl
    CFArrayRef snapshot = LSSharedFileListCopySnapshot(favoriteItems, NULL);
    // Getting the number of items in the sidebar fevorites list
    CFIndex sidebarItemsCount = CFArrayGetCount(snapshot);
    
    for(int i = 0; i < sidebarItemsCount; ++i)
    {
        NSString* name = (__bridge NSString *)(LSSharedFileListItemCopyDisplayName(CFArrayGetValueAtIndex(snapshot, i)));
        
        if (![input  isEqual: @"(null)"]) {
            if ([name isEqualToString: input]) {
                // Removing the item from the sfl using it's reference and snapshot index
                // !!! IMPORTANT NOTE. If you'll aim to repurpose this code this line most likely needs improvement, since snapshot would, as I assume, contain an old version of the sidebar. I'm not 100% sure that's the case but you might need to reassign snapshot and account for that in the parent loop to make sure you're not out of array bounds and not using a mismatched index
                LSSharedFileListItemRemove(favoriteItems, CFArrayGetValueAtIndex(snapshot, i));
                
                // Ciurcumventing the repeat logic because thus block is used only for the manual execution. Not the most elegant but would do in this case.
                //goto outer;
            }
        }
    }
}

void remove_google() {
    // Getting the shared file list (sfl) reference
    LSSharedFileListRef favoriteItems = LSSharedFileListCreate(NULL,  kLSSharedFileListFavoriteItems, NULL);
    // Getting the current snapshot of the sfl
    CFArrayRef snapshot = LSSharedFileListCopySnapshot(favoriteItems, NULL);
    // Getting the number of items in the sidebar fevorites list
    CFIndex sidebarItemsCount = CFArrayGetCount(snapshot);
    
    for(int i = 0; i < sidebarItemsCount; ++i)
    {
        NSString* name = (__bridge NSString *)(LSSharedFileListItemCopyDisplayName(CFArrayGetValueAtIndex(snapshot, i)));
        if ([name rangeOfString:@" - Google Drive"].location != NSNotFound) {
            // Removing the item from the sfl using it's reference and snapshot index
            LSSharedFileListItemRemove(favoriteItems, CFArrayGetValueAtIndex(snapshot, i));
            //FOLDERS_REMOVED = true;
        }
    }
    
    CFRelease(favoriteItems);
    CFRelease(snapshot);
    sidebarItemsCount = 0;
}

void remove_one_drive() {
    // Getting the shared file list (sfl) reference
    LSSharedFileListRef favoriteItems = LSSharedFileListCreate(NULL,  kLSSharedFileListFavoriteItems, NULL);
    
    // Getting the current snapshot of the sfl
    CFArrayRef snapshot = LSSharedFileListCopySnapshot(favoriteItems, NULL);
    
    NSArray *list = CFBridgingRelease(LSSharedFileListCopySnapshot(favoriteItems, NULL));
    
    // Getting the number of items in the sidebar fevorites list
    CFIndex sidebarItemsCount = CFArrayGetCount(snapshot);
    
    for(int i = 0; i < sidebarItemsCount; ++i)
    {
        NSString* name = (__bridge NSString *)(LSSharedFileListItemCopyDisplayName(CFArrayGetValueAtIndex(snapshot, i)));
        
        if ([name isEqualToString:@"OneDrive"]) {
            // Removing the item from the sfl using it's reference and snapshot index
            LSSharedFileListItemRemove(favoriteItems, CFArrayGetValueAtIndex(snapshot, i));
            //FOLDERS_REMOVED = true;
        }
    }
    
    CFRelease(favoriteItems);
    CFRelease(snapshot);
    sidebarItemsCount = 0;
}



int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Getting the input parameter for the sidebar item name to be removed
        NSString* input = [NSString stringWithFormat:@"%s",argv[1]];

        // Getting the shared file list (sfl) reference
        //LSSharedFileListRef favoriteItems = LSSharedFileListCreate(NULL,  kLSSharedFileListFavoriteItems, NULL);
        
        // External loop to catch the folders initializing after the machine boot correctly
        // TODO: Instead of a cycle try to subscribe to Finder.Open() event or something like that when a new finder window/tab is opened and handle that instead of the loop
        for (int t = 0; t < TIMEOUT; t++) {
            remove_google();
            remove_one_drive();
            
            //remove_by_name(input)
            //CFRelease(favoriteItems);
            
            //if (FOLDERS_REMOVED && t < TIMEOUT-TIMEOUT_CLEANUP) {
            //    t = TIMEOUT-TIMEOUT_CLEANUP;
            //}
            //else {
            //    [NSThread sleepForTimeInterval:SLEEP_INTERVAL];
            //}
            [NSThread sleepForTimeInterval:SLEEP_INTERVAL];
        }
        outer:;
    }
    return 0;
}
