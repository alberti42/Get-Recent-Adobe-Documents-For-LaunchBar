//
//  GetRecentAdobeDocumentsLib.m
//  GetRecentAdobeDocumentsLib
//
//  Created by Andrea Alberti on 18.02.18.
//  Copyright © 2018 Andrea Alberti. All rights reserved.
//

#import "GetRecentAdobeDocumentsLib.h"
#include <sys/stat.h>
#import "BDAlias.h"

NSString* const RecentDocumentsPlist = @"~/Library/Preferences/com.adobe.mediabrowser.plist";

NSMutableArray* get_recent_documents(NSString* bundleIdentifier) __attribute__((ns_returns_retained))
{
    // ms2016
    NSDictionary *AdobePlist = [NSDictionary dictionaryWithContentsOfFile:[RecentDocumentsPlist stringByExpandingTildeInPath]][@"MRU"][bundleIdentifier];
    
    NSMutableArray *documentsArray = [[NSMutableArray alloc] initWithCapacity:20];
    
    if (AdobePlist)
    {
        NSArray* files = [[NSArray alloc] initWithArray:AdobePlist[@"files"]];
        
        NSDictionary* fileDict;
        BDAlias *alias;
        char* s = (char*)malloc(5);
        NSData* d;
        NSDictionary* dd;
        NSString* path;
        
        NSEnumerator *enumerator = [files objectEnumerator];
        
        int counter=0;
        
        while ((fileDict = [enumerator nextObject]) && counter < 50) {
            
            d = [fileDict objectForKey:@"file-alias"];
            
            if( d && [d length] > 4)
            {
                // check magic characters
                memset(s,0,5);
                memcpy(s,[d bytes],4);
                
                if( strcmp(s, "book") ==0 ) // a bookmark
                {
                    dd = [NSURL resourceValuesForKeys:@[NSURLPathKey] fromBookmarkData:d];
                    
                    if ([dd count] == 0)
                    {
                        continue;
                    }
                    
                    path = dd[NSURLPathKey];
                }
                else // an alias of old type
                {
                    alias = [[BDAlias alloc] initWithData:d];
                    
                    if( alias )
                    {
                        path = [alias fullPath];
                        
                        if( path == nil )
                        {
                            continue;
                        }
                    }
                }
                
                if( access([path fileSystemRepresentation], F_OK ) != 0 )
                {
                    continue;
                }
                
                [documentsArray addObject:path];
                counter++;
            }
            else
            {
                path = [fileDict objectForKey:@"file-path"];
                if( path != nil )
                {
                    if( access([path fileSystemRepresentation], F_OK ) == 0 )
                    {
                        [documentsArray addObject:path];
                        counter++;
                    }
                }
            }
            
        }
        free(s);
    }
    
    
    /*
     // __block int counter = 0;
     [files enumerateObjectsUsingBlock:^(NSDictionary *fileDict, NSUInteger idx, BOOL *stop) {
     if(idx>=50)
     {
     *stop = true;
     }
     else
     {
     NSData *d = [fileDict objectForKey:@"file-alias"];
     
     NSMutableArray* bookmark = parse_bookmark(d);
     if(bookmark)
     {
     [documentsArray addObject:[bookmark objectAtIndex:0]];
     }
     }
     // counter++;
     }];
     */
    
    return documentsArray;
}

const char* create_LB_menu_entries(NSString* const APP_NAME)
{
    NSMutableArray* documentsArray = get_recent_documents(APP_NAME);
    
    // NSFileManager *fm = [NSFileManager defaultManager];
    if ([documentsArray count] > 0)
    {
        
        NSArray* LBkeys = @[@"title", @"subtitle", @"path"];
        
        NSMutableArray* LBitems = [[NSMutableArray alloc] init];
        
        NSString* title;
        NSString* subtitle;
        // NSString* ext;
        // NSString* icon;
        
        for(NSString* filepath in documentsArray)
        {
            
            subtitle = [filepath stringByDeletingLastPathComponent];
            title = [filepath lastPathComponent];
            /*
             ext = [filepath pathExtension];
             
             icon = @"";
             if( !icon )
             {
             icon = @"TEXT";
             }
             */
            
            [LBitems addObject:[[NSDictionary alloc] initWithObjects:
                                @[title,
                                  subtitle,
                                  filepath
                                  //, [NSString stringWithFormat:@"%@:%@",APP_NAME,[icon lowercaseString]]
                                  ] forKeys:LBkeys]];
            
        }
        
        
//        [LBitems sortUsingComparator:^NSComparisonResult(NSDictionary *entry1, NSDictionary *entry2) {
//
//            long int st_atime1 = 0;
//            long int st_atime2 = 0;
//            struct stat filestat1;
//            struct stat filestat2;
//
//            // printf("%s\n",[entry1[@"path"] fileSystemRepresentation]);
//
//            if(stat([entry1[@"path"] fileSystemRepresentation], &filestat1)==0)
//            {
//                st_atime1 = filestat1.st_atime;
//            }
//            if(stat([entry2[@"path"] fileSystemRepresentation], &filestat2)==0)
//            {
//                st_atime2 = filestat2.st_atime;
//            }
//
//            return st_atime1<st_atime2;
//        }];
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:LBitems
                                                           options:NSJSONWritingPrettyPrinted error:nil];
        
        return [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] UTF8String];
    }
    else
    {
        return "";
    }
}
