/**
 MARK: This version is still the first version, the interface has many imperfections and functional defects
 
 2020.05.28
 1. Added row editing status deletion processing and callback
 
 2020.05.10
 1. Add an interface for appending row data in section
 2. The parameter section of addRow and resetRow is the maximum value of the current section number + 1, then a new section is created
 
 2020.04.20
 1. Added [XXtableViewShell resetData:(id)data atIndexPath:(NSIndexPath*)indexPath] to reset the corresponding row
 2. Add <XXtableViewCellDelegate>, mainly to standardize the interface of custom cell
 3. For the data in [cell resetData:data], if the data needs to be modified in the cell, the data needs to be Mutable, which may be a bit different from the original design
    (The native data modification is controlled by the Table layer, but XXtable may be a biased cell to manage its own data)
 
 2020.04.08
 The encapsulation of UITableView (third edition), integrating the following functions
 1. Internal management cells (header, row, footer)
 2. Dynamically add or delete sections
 
 When using a custom cell, you need to implement the protocol <XXtableViewCellDelegate>
    When nib is customized, it is initialized in [awakeFromNib]
    When the code is customized, it is initialized in [initWithStyle: reuseIdentifier:]
 
 When using the system cell, you can use the following 'identity' to set the corresponding value
    @"Title": UITableViewCell.textLabel.text
    @"Detail": UITableViewCell.detailTextLabel.text
    @"Image": UITableViewCell.imageView.image
    @"AccessoryType": UITableViewCell.accessoryType
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    XXtableViewShellRowLoadTypeNib,
    XXtableViewShellRowLoadTypeCode,
} XXtableViewShellRowLoadType;

@interface XXtableViewShell : NSObject<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,weak,readonly) UITableView *tableView; // target UITableView
@property (nonatomic,strong,readonly) NSMutableArray *sectionDatas; // TableView data
@property (nonatomic,copy,nullable) NSString *rowType; // type of row (cell), nil is to use system components
@property (nonatomic,assign,readonly) XXtableViewShellRowLoadType rowLoadType; // Custom row (cell) loading method
@property (nonatomic,assign,readonly) UITableViewCellStyle rowSystemStyle; // style of system row (cell)
@property (nonatomic,assign) BOOL haveRedDot;

@property (nonatomic,assign) BOOL canSlideDelete;   /// Can you swipe left to delete, the default is NO, note that after setting tableView.edit, you cannot delete it by left swiping

@property (nonatomic,copy,readonly) NSString *emptyType;
@property (nonatomic,assign,readonly) XXtableViewShellRowLoadType emptyLoadType;

@property (nonatomic,copy,nullable) void(^onRowClicked)(XXtableViewShell *shell, NSIndexPath *indexPath, id data); // row click callback
@property (nonatomic,copy,nullable) BOOL(^onRowEditingDelete)(XXtableViewShell *shell, NSIndexPath *indexPath, id data); // In editing state, row delete editing callback, by returning NO: cancel delete, return YES: confirm delete

/**
 Set the target TableView for the shell
 @param tableView target TableView
 */
- (void)shell:(UITableView*)tableView;

/**
 Configure the View that is centered when the TableView has empty content
 @param cls Prompt View class name for empty content
 @param loadType loading method
 */
- (void)configEmptyView:(NSString*)cls loadType:(XXtableViewShellRowLoadType)loadType;
- (void)configEmptyViewInstance:(UIView*)view;

/**
 Configure the row (cell) parameter of TableView
 @param type The type of row (cell) of TableView, custom class name is passed in; system is passed in nil
 @param loadType TableView's row (cell) customization method, there are two types [xib, code], using the system type to pass in this parameter is invalid
 @param systemStyle When using the row (cell) of the system, you can specify the system style, and it is invalid to pass in this parameter using a custom type
 @param height height of row (cell), 0: adaptive, otherwise specify the height
 */
- (void)configRowType:(nullable NSString*)type loadType:(XXtableViewShellRowLoadType)loadType systemStyle:(UITableViewCellStyle)systemStyle height:(CGFloat)height;

/**
 Configure the data of all sections of the TableView. After the call, it will trigger the refresh of the TableView. The headers and footers can be nil. If the two are not nil, the length needs to be the same as the number of rows. The number of rows is regarded as the number of sections of the TableView;
 The element in @param headers is the data of the header of each section
 The element in @param rows is the row data of each section, if the number of rows in the section is 0
 The element in @param footers is the data of the footer of each section
 */
- (void)configSectionWithHeaders:(nullable NSArray*)headers rows:(NSArray*)rows footers:(nullable NSArray*)footers;

/**
Configure the section data of a single TableView, the refresh of the TableView will not be triggered after the call, it needs to be used with [XXtableViewShell configFinished]
 @param header section header data
 @param row The row data of the section, when nil, the number of rows in the section is 0
 @param footer section footer data
 */
- (void)configSectionWithHeader:(nullable id)header row:(nullable NSArray*)row footer:(nullable id)footer;

/**
 Configuration is complete, trigger refresh
 */
- (void)configFinished;

/**
 append a section at the end
 @param header section header data
 @param row The row data of the section, when nil, the number of rows in the section is 0
 @param footer section footer data
 */
- (void)addSectionWithHeader:(nullable id)header row:(nullable NSArray*)row footer:(nullable id)footer;

/**
 Insert a section at the specified location
 @param header section header data
 @param row The row data of the section, when nil, the number of rows in the section is 0
 @param footer section footer data
 */
- (void)insertSectionWithHeader:(nullable id)header row:(nullable NSArray*)row footer:(id)footer atIndex:(int)index;

/**
 Remove the section at the specified position
 @param index the position of the target section
 */
- (void)removeSectionAtIndex:(int)index;

/**
 Reset all row data in the specified section
 @param row Reset data, when nil, the number of rows in this section is 0
 @param section The location of the target section
 */
- (void)resetRow:(nullable NSArray*)row atSection:(int)section;

/**
Add several rows to the specified section
 @param row append row data
 @param section The location of the target section
 */
- (void)addRow:(NSArray*)row atSection:(int)section;

/**
 Remove the row of the specified indexPath
 @param indexPath the position where the row needs to be deleted
 */
- (void)removeRowAtIndexPath:(NSIndexPath*)indexPath;

/**
 Reset the row data of the specified indexPath
 @param data data of a single row (cell)
 @param indexPath needs to reset the position of row (cell)
 */
- (void)resetData:(id)data atIndexPath:(NSIndexPath*)indexPath;
/**
Get the row data of the specified indexPath
 @param indexPath needs to reset the position of row (cell)
 */
- (id)getDataAtIndexPath:(NSIndexPath*)indexPath;

/**
 The row is required to perform certain operations, which is different from resetData. resetData means that the row's own data needs to be reset or set.
 doSomething needs to perform certain actions, the shell itself will not modify the data, and the row/cell itself needs to determine whether this operation requires data modification
 @param event The name of the event that needs to be executed
 @param info executes the parameters that need to be carried
 @param indexPath where the cell is located
 */
- (void)rowDoSomething:(NSString*)event info:(nullable id)info atIndex:(NSIndexPath*)indexPath;

@end


@protocol XXtableViewCellDelegate
@required
@property (nonatomic,weak) XXtableViewShell *tableViewShell;
@property (nonatomic,strong) NSIndexPath *indexPath;
- (void)resetData:(id)data;
- (void)doSomething:(NSString*)event info:(nullable id)info;
@end
NS_ASSUME_NONNULL_END
