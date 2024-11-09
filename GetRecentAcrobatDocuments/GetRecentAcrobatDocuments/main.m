//
//  main.m
//  GetRecentMatlabDocuments
//
//  Created by Andrea Alberti on 18.02.18.
//  Copyright © 2018 Andrea Alberti. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/stat.h>
// #import "BDAlias.h"

NSString* const RecentDocumentsPlist = @"~/Library/Preferences/com.adobe.Acrobat.Pro.plist";

NSArray* get_recent_documents(void) __attribute__((ns_returns_retained))
{
    // ms2016
    NSDictionary *files = [(NSArray*)[[[[NSDictionary dictionaryWithContentsOfFile:[RecentDocumentsPlist stringByExpandingTildeInPath]] objectForKey:@"DC"] objectForKey:@"AVGeneral"] objectForKey:@"RecentFiles"] objectAtIndex:1];
    
    NSMutableArray *documentsArray = [[NSMutableArray alloc] initWithCapacity:20];
    NSArray* documentsArraySorted = nil;
    
    if (files)
    {
        [files enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSArray* obj, BOOL *stop) {
            
            //alias = [[BDAlias alloc] initWithData:(NSData*)[(NSArray*)[(NSDictionary*)[obj objectAtIndex:1] objectForKey:@"DI"] objectAtIndex:1]];
            
            //if( alias )
            NSString* path = [NSString stringWithFormat:@"/Volumes%@",[(NSArray*)[(NSDictionary*)[obj objectAtIndex:1] objectForKey:@"DIText"] objectAtIndex:1]];
            
            if( path != nil )
            {
                if( access([path fileSystemRepresentation], F_OK ) != -1 )
                {
                    [documentsArray addObject:@[@([key integerValue]), path]];
                }
            }
            
        }];
        
        //        NSArray* RecentDocumentsSorted = [[NSArray alloc] initWithArray:
        //                                          [RecentDocuments sortedArrayUsingComparator:^NSComparisonResult(NSArray* a, NSArray* b) {
        //            return a[0]>b[0];
        //        }]];

        documentsArraySorted = [[NSArray alloc] initWithArray:
                          [documentsArray sortedArrayUsingComparator:^NSComparisonResult(NSArray* a, NSArray* b) {
            if([a[0] integerValue]>[b[0] integerValue])
            {
                return (NSComparisonResult)NSOrderedDescending;
            }
            else if([a[0] integerValue]<[b[0] integerValue])
            {
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            return (NSComparisonResult)NSOrderedSame;
        }]];
    }
    
    return documentsArraySorted;
}

const char* create_LB_menu_entries(void)
{
    NSArray* documentsArray = get_recent_documents();
    
    if ([documentsArray count] > 0)
    {
        //NSArray* LBkeys = @[@"title", @"subtitle", @"action", @"icon", @"path", @"actionRunsInBackground"];
        NSArray* LBkeys = @[@"title", @"subtitle", @"icon", @"path"];
        
        NSMutableArray* LBitems = [[NSMutableArray alloc] init];
        
        __block NSString* title;
        __block NSString* subtitle;
        
        __block int counter = 0;
        [documentsArray enumerateObjectsUsingBlock:^(NSArray* filepath, NSUInteger idx, BOOL *stop) {
            
            subtitle = [(NSString*)[filepath objectAtIndex:1] stringByDeletingLastPathComponent];
            title = [(NSString*)[filepath objectAtIndex:1] lastPathComponent];
            
            [LBitems addObject:[[NSDictionary alloc] initWithObjects:
                                @[title,
                                  subtitle,
                                  //@"open_with_acrobat.py",
                                  @"com.adobe.Acrobat.Pro:ACP_Generic",
                                  //[NSString stringWithFormat:@"pdffile:///%@",[filepath objectAtIndex:1]],
                                  [filepath objectAtIndex:1],
                                  //@"true"
                                  ] forKeys:LBkeys]];
            
            counter++;
            if(counter >= 50)
            {
                *stop = true;
            }
        }];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:LBitems
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about pretty printing
                                                             error:&error];
        if (!jsonData) {
            NSLog(@"Failed to serialize to JSON: %@", error.localizedDescription);
            return "";
        }
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (!jsonString) {
            NSLog(@"Failed to create string from JSON data");
            return "";
        }
        
        return [jsonString UTF8String];
    }
    else
    {
        return "";
    }
}

int main(int argc, const char * argv[]) {
    //@autoreleasepool {
    
    @try {
        // create_LB_menu_entries();
        fprintf(stdout, "%s", create_LB_menu_entries());
        
        return 0;
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        
        return -1;
    }
}


