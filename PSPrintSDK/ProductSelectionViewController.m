//
//  ProductSelectionViewController.m
//  Kite SDK
//
//  Created by Deon Botha on 24/03/2014.
//  Copyright (c) 2014 Deon Botha. All rights reserved.
//

#import "ProductSelectionViewController.h"
#import "OLProductTemplate.h"

NSString *displayNameWithProduct(Product product) {
    switch (product) {
        case kProductMagnets: return @"Magnets";
        case kProductSquares: return @"Square Prints";
        case kProductSquaresMini: return @"Mini Square Prints";
        case kProductPolaroidStyle: return @"Polaroid Style Prints";
        case kProductPolaroidStyleMini: return @"Mini Polaroid Style Prints";
        case kProductPostcard: return @"Postcard";
    }
}

NSString *templateWithProduct(Product product) {
    switch (product) {
        case kProductMagnets: return kOLDefaultTemplateForMagnets;
        case kProductSquares: return kOLDefaultTemplateForSquarePrints;
        case kProductSquaresMini: return kOLDefaultTemplateForSquareMiniPrints;
        case kProductPolaroidStyle: return kOLDefaultTemplateForPolaroidStylePrints;
        case kProductPolaroidStyleMini: return kOLDefaultTemplateForPolaroidStyleMiniPrints;
        case kProductPostcard: return kOLDefaultTemplateForPostcard;
    }
}

static Product productWithDisplayName(NSString *displayName) {
    if ([displayName isEqualToString:@"Magnets"]) {
        return kProductMagnets;
    } else if ([displayName isEqualToString:@"Square Prints"]) {
        return kProductSquares;
    } else if ([displayName isEqualToString:@"Mini Square Prints"]) {
        return kProductSquaresMini;
    } else if ([displayName isEqualToString:@"Polaroid Style Prints"]) {
        return kProductPolaroidStyle;
    } else if ([displayName isEqualToString:@"Mini Polaroid Style Prints"]) {
        return kProductPolaroidStyleMini;
    } else if ([displayName isEqualToString:@"Postcard"]) {
        return kProductPostcard;
    } else {
        NSCAssert(NO, @"oops");
        return 0;
    }
}

@interface ProductSelectionViewController ()

@end

@implementation ProductSelectionViewController

- (IBAction)onCancelClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell.textLabel.text isEqualToString:displayNameWithProduct(self.selectedProduct)]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    [self.delegate productSelectionViewControllerUserDidSelectProduct:productWithDisplayName(cell.textLabel.text)];
}

@end
