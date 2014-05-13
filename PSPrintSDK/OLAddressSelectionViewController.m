//
//  OLAddressSelectionViewController.m
//  Kite SDK
//
//  Created by Deon Botha on 04/01/2014.
//  Copyright (c) 2014 Deon Botha. All rights reserved.
//

#import "OLAddressSelectionViewController.h"
#import "OLAddress.h"
#import "OLAddress+AddressBook.h"
#import "OLCountry.h"
#import "OLAddressEditViewController.h"
#import "OLAddressLookupViewController.h"

#import <AddressBook/ABPerson.h>
#import <AddressBookUI/AddressBookUI.h>

static const NSInteger kSectionAddressList = 0;
static const NSInteger kSectionAddAddress = 1;

static const NSInteger kRowAddAddressFromContacts = 0;
static const NSInteger kRowAddAddressSearch = 1;
static const NSInteger kRowAddAddressManually = 2;

@interface OLAddressSelectionViewController () <ABPeoplePickerNavigationControllerDelegate>
@property (strong, nonatomic) NSMutableSet *selectedAddresses;
@property (strong, nonatomic) OLAddress *addressToAddToListOnViewDidAppear;
@end

@implementation OLAddressSelectionViewController

- (id)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Choose Address";
        self.selectedAddresses = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsMultipleSelection = self.allowMultipleSelection;
    self.allowMultipleSelection = _allowMultipleSelection;
}

- (void)setAllowMultipleSelection:(BOOL)allowMultipleSelection {
    _allowMultipleSelection = allowMultipleSelection;
    self.tableView.allowsMultipleSelection = _allowMultipleSelection;
    if (_allowMultipleSelection) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(onButtonDoneClicked)];
        self.navigationItem.rightBarButtonItem = doneButton;
    } else {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(onButtonCancelClicked)];
        self.navigationItem.rightBarButtonItem = doneButton;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.addressToAddToListOnViewDidAppear) {
        BOOL insertSection = [OLAddress addressBook].count == 0;
        [self.addressToAddToListOnViewDidAppear saveToAddressBook];
        if (self.allowMultipleSelection) {
            [self.selectedAddresses addObject:self.addressToAddToListOnViewDidAppear];
        }
        if (insertSection) {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[OLAddress addressBook].count - 1 inSection:kSectionAddressList]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        self.addressToAddToListOnViewDidAppear = nil;
    }
}

- (NSArray *)selected {
    return self.selectedAddresses.allObjects;
}

- (void)setSelected:(NSArray *)selected {
    [self.selectedAddresses removeAllObjects];
    [self.selectedAddresses addObjectsFromArray:selected];
    [self.tableView reloadData];
}

- (void)onButtonCancelClicked {
    [self.delegate addressSelectionControllerDidCancelPicking:self];
}

- (void)onButtonDoneClicked {
    [self.delegate addressSelectionController:self didFinishPickingAddresses:self.selected];
}

- (void)onButtonAddFromContactsClicked {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    picker.displayedProperties = @[[NSNumber numberWithInteger:kABPersonAddressProperty]];
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [OLAddress addressBook].count > 0 ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([OLAddress addressBook].count == 0) { ++section; }
    if (section == 0) {
        return [OLAddress addressBook].count;
    } else {
        return 3;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([OLAddress addressBook].count == 0) { ++section; }
    if (section == 0) {
        return [OLAddress addressBook].count > 0 ? @"Address Book" : nil;
    } else {
        return @"Add New Address";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([OLAddress addressBook].count == 0) { indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1]; }
    UITableViewCell *cell = nil;
    if(indexPath.section == kSectionAddressList) {
        static NSString *kAddressCellIdentifier = @"AddressCell";
        cell = [tableView dequeueReusableCellWithIdentifier:kAddressCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAddressCellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
        
        OLAddress *address = [OLAddress addressBook][indexPath.row];
        
        if (self.tableView.allowsMultipleSelection) {
            cell.imageView.image = [UIImage imageNamed:[self.selectedAddresses containsObject:address] ? @"checkmark_on" : nil];
        } else {
            cell.imageView.image = nil;
        }
        cell.textLabel.text = address.recipientName;
        cell.detailTextLabel.text = address.descriptionWithoutRecipient;
    } else {
        NSAssert(indexPath.section == kSectionAddAddress, @"oops");
        static NSString *kManageCellIdentifier = @"ManageCell";
        cell = [tableView dequeueReusableCellWithIdentifier:kManageCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kManageCellIdentifier];
        }
        
        if (indexPath.row == kRowAddAddressFromContacts) {
            cell.textLabel.text = NSLocalizedString(@"Add Address from Contacts", @"");
        } else if (indexPath.row == kRowAddAddressSearch) {
            cell.textLabel.text = NSLocalizedString(@"Search for Address", @"");
        } else {
            cell.textLabel.text = NSLocalizedString(@"Enter Address Manually", @"");
        }
        
        cell.textLabel.textColor = [UIColor colorWithRed:0 / 255.0 green:122 / 255.0 blue:255 / 255.0 alpha:1.0];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([OLAddress addressBook].count == 0) { indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1]; }
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        OLAddress *address = [OLAddress addressBook][indexPath.row];
        [address deleteFromAddressBook];
        NSArray *deleteIndexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        if ([OLAddress addressBook].count == 0) {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([OLAddress addressBook].count == 0) { indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1]; }
    return indexPath.section == kSectionAddressList;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([OLAddress addressBook].count == 0) { indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1]; }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == kSectionAddressList) {
        if (!self.allowMultipleSelection) {
            OLAddress *address = [OLAddress addressBook][indexPath.row];
            [self.delegate addressSelectionController:self didFinishPickingAddresses:@[address]];
        } else {
            OLAddress *address = [OLAddress addressBook][indexPath.row];
            BOOL selected = YES;
            if ([self.selectedAddresses containsObject:address]) {
                selected = NO;
                [self.selectedAddresses removeObject:address];
            } else {
                [self.selectedAddresses addObject:address];
            }
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.imageView.image = [UIImage imageNamed:selected ? @"checkmark_on" : nil];
        }
    } else if (indexPath.section == kSectionAddAddress) {
        if (indexPath.row == kRowAddAddressFromContacts) {
            [self onButtonAddFromContactsClicked];
        } else if (indexPath.row == kRowAddAddressManually) {
            [self.navigationController pushViewController:[[OLAddressEditViewController alloc] init] animated:YES];
        } else if (indexPath.row == kRowAddAddressSearch) {
            [self.navigationController pushViewController:[[OLAddressLookupViewController alloc] init] animated:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if ([OLAddress addressBook].count == 0) { indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1]; }
    if (indexPath.section == kSectionAddressList) {
        OLAddress *address = [OLAddress addressBook][indexPath.row];
        [self.navigationController pushViewController:[[OLAddressEditViewController alloc] initWithAddress:address] animated:YES];
    }
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate methods


- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    [peoplePicker dismissViewControllerAnimated:YES completion:^(void) {
        // create address
        OLAddress *olAddress = [[OLAddress alloc] init];
        olAddress.recipientName = (__bridge NSString *) ABRecordCopyCompositeName(person);
        
        ABMultiValueRef addressProperty = ABRecordCopyValue(person, /*kABPersonAddressProperty*/property);
        CFIndex index = ABMultiValueGetIndexForIdentifier(addressProperty, identifier);
        NSArray *addr = (__bridge NSArray *) ABMultiValueCopyArrayOfAllValues(addressProperty);
        if (addr.count <= index) {
            // can't get the address :( TODO: why?! I had a crashlytics crash below on addr objectAtIndex:index
            return;
        }
        NSDictionary *address = [addr objectAtIndex:index];
        
        NSString *streets = [address objectForKey:(NSString *)kABPersonAddressStreetKey];
        NSArray *splitStreets = [streets componentsSeparatedByString:@"\n"];
        
        olAddress.line1 = splitStreets.count > 0 ? [splitStreets objectAtIndex:0] : @"";
        olAddress.line2 = splitStreets.count > 1 ? [splitStreets objectAtIndex:1] : @"";
        olAddress.city = [address objectForKey:(NSString *)kABPersonAddressCityKey];
        olAddress.stateOrCounty = [address objectForKey:(NSString *)kABPersonAddressStateKey];
        olAddress.zipOrPostcode = [address objectForKey:(NSString *)kABPersonAddressZIPKey];
        NSString *countryCode = [address objectForKey:(NSString *)kABPersonAddressCountryCodeKey];
        olAddress.country = [OLCountry countryForCode:countryCode];
        
        [self.navigationController pushViewController:[[OLAddressEditViewController alloc] initWithAddress:olAddress] animated:YES];
    }];
    
    return NO;
}


@end
