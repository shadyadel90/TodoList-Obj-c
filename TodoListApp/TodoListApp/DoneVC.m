//
//  DoneVC.m
//  TodoListApp
//
//  Created by Shady Adel on 12/08/2024.
//

#import "DoneVC.h"

@interface DoneVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray* doneDisplayArray;

@end

@implementation DoneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.navigationItem.title = @"Done Todo's";
    _doneDisplayArray = [NSMutableArray new];
    
    if (_doneDisplayArray.count == 0) {
        _tableView.hidden = true;
    }}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
