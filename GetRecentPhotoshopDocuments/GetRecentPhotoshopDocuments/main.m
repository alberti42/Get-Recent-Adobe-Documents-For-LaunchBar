//
//  main.m
//  GetRecentPhotoshopDocuments
//
//  Created by Andrea Alberti on 18.02.18.
//  Copyright © 2018 Andrea Alberti. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "GetRecentAdobeDocumentsLib.h"

int main(int argc, const char * argv[]) {
    //@autoreleasepool {
    
    NSString* const APP_NAME = @"Photoshop";
    
    @try {
        // create_LB_menu_entries(APP_NAME);
        fprintf(stdout, "%s", create_LB_menu_entries(APP_NAME));
        
        return 0;
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        
        return -1;
    }
    
}
