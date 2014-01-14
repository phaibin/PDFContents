//
//  ContentsViewController.m
//  PDFContents
//
//  Created by Leon on 1/14/14.
//  Copyright (c) 2014 Leon. All rights reserved.
//

#import "ContentsViewController.h"

@interface ContentsViewController ()

@end

@implementation ContentsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:100];
    UILabel *numberLabel = (UILabel *)[cell.contentView viewWithTag:101];
    
    NSDictionary *dict = self.contents[indexPath.row];
    titleLabel.text = dict[@"Title"];
    numberLabel.text = [NSString stringWithFormat:@"%@", dict[@"Index"]];
    NSArray *subContents = dict[@"SubContents"];
    if (subContents && subContents.count > 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = self.contents[indexPath.row];
    NSArray *subContents = dict[@"SubContents"];
    if (subContents && subContents.count > 0) {
        ContentsViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ContentsViewController"];
        viewController.contents = subContents;
        viewController.title = dict[@"Title"];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

@end
