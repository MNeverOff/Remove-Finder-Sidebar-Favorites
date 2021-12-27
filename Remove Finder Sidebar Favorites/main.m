//
//  main.m
//  Remove Sidebar Favorites
//
//  Created by Mikhail Neverov on 26.12.2021
//  mike@neveroff.dev
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Getting the input parameter for the sidebar item name to be removed
        NSString* input = [NSString stringWithFormat:@"%s",argv[1]];
        // Getting the shared file list (sfl) reference
        LSSharedFileListRef sharedFileListRef = LSSharedFileListCreate(kCFAllocatorDefault, kLSSharedFileListFavoriteItems, NULL);
        // Getting the current snapshot of the sfl
        CFArrayRef snapshot = LSSharedFileListCopySnapshot(sharedFileListRef, NULL);
        // Getting the number of items in the sidebar fevorites list
        CFIndex sidebarItemsCount = CFArrayGetCount(snapshot);
        
        // Iterating over the sidebar items
        for(int i = 0; i < sidebarItemsCount; ++i)
        {
            // Getting the display name for the current sidebar item
            NSString* name = (__bridge NSString *)(LSSharedFileListItemCopyDisplayName(CFArrayGetValueAtIndex(snapshot, i)));
            // Comparing the current sidebar item name with the input name
            if ([name isEqualToString: input]) {
                // Removing the item from the sfl using it's reference and snapshot index
                // !!! IMPORTANT NOTE. If you'll aim to repurpose this code this line most likely needs improvement, since snapshot would, as I assume, contain an old version of the sidebar. I'm not 100% sure that's the case but you might need to reassign snapshot and account for that in the parent loop to make sure you're not out of array bounds and not using a mismatched index
                LSSharedFileListItemRemove(sharedFileListRef, CFArrayGetValueAtIndex(snapshot, i));
            }
        }
    }
    
    return 0;
}
