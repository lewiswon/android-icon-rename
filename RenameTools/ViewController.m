//
//  ViewController.m
//  RenameTools
//
//  Created by LuoLewis on 18/05/2017.
//  Copyright © 2017 LuoLewis. All rights reserved.
//

#import "ViewController.h"

@interface ViewController()<NSDraggingDestination,NSTableViewDelegate,NSTableViewDataSource,NSTextFieldDelegate>{
    NSMutableArray *imageArray;
    NSArray *allSubDirectory;
    NSString *rootFilePath;
    NSInteger currentIndex;
    NSFileManager  *mFileManager;
    NSAlert  *alert;
}
@property (weak) IBOutlet NSImageView *xxxImageView;
@property (weak) IBOutlet NSImageView *xxImageView;
@property (weak) IBOutlet NSImageView *xImageView;
@property (weak) IBOutlet NSImageView *hImageView;
@property (weak) IBOutlet NSImageView *mImageView;
@property (weak) IBOutlet NSButton *renameButton;
@property (weak) IBOutlet NSTextField *renameTextField;
@property (weak) IBOutlet NSButton *openButton;
@property (weak) IBOutlet NSView *editContainer;
@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    mFileManager = [NSFileManager defaultManager];
    _renameTextField.delegate =self;
    // Do any additional setup after loading the view.
    
    alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"先输入名称"];
    [alert setInformativeText:@"Deleted records cannot be restored."];
    [alert setAlertStyle:NSAlertStyleWarning];
    [[[self view]window] setTitle: @"Android 图标重命名工具"];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}
-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
       return  NSDragOperationCopy;
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [imageArray count];
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"imageCell" owner:self];
    NSImageView *imageView = [cellView viewWithTag:100];
    if(imageView.image == nil){
        NSString *imagePath=[NSString stringWithFormat:@"%@/%@/%@",rootFilePath,@"xxhdpi",[imageArray objectAtIndex:row]];
        NSImage *image = [[NSImage alloc]initWithContentsOfFile:imagePath];
        [imageView setImage:image];
    }
    NSTextField  *textField = [cellView viewWithTag:200];
    textField.stringValue = [imageArray objectAtIndex:row];
    return cellView;
}
-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    if(_editContainer.isHidden){
        _editContainer.hidden = NO;
    }
    currentIndex = [_mTableView selectedRow];
    _renameTextField.stringValue = @"";
    [_renameTextField becomeFirstResponder];
    [self loadSelectedImage];
}

-(void)loadSelectedImage{
    NSString *fileName = [imageArray objectAtIndex:currentIndex];
    _renameTextField.placeholderString = fileName;
    if (allSubDirectory == nil) {
        allSubDirectory  = [mFileManager contentsOfDirectoryAtPath:rootFilePath error:nil];
    }
    NSImage  *xxxImage;
    NSImage  *xxImage;
    NSImage  *xImage;
    NSImage  *mImage;
    NSImage  *hImage;
    for(NSString *path in allSubDirectory){
        
        if([path isEqualToString:@"xxxhdpi"]){
            xxxImage = [self getImage:path withName:fileName];
        }
        else if([path isEqualToString:@"xxhdpi"]){
            xxImage = [self getImage:path withName:fileName];
        }
        else if([path isEqualToString:@"xhdpi"]){
            xImage = [self getImage:path withName:fileName];
        }
        else if([path isEqualToString:@"hdpi"]){
            hImage = [self getImage:path withName:fileName];
        }
        else if([path isEqualToString:@"mdpi"]){
            mImage = [self getImage:path withName:fileName];
        }
    }
    
    [_mImageView setImage:mImage];
    [_hImageView setImage:hImage];
    [_xImageView setImage:xImage];
    [_xxImageView setImage:xxImage];
    [_xxxImageView setImage:xxxImage];
    
    
}
-(NSImage*)getImage:(NSString*)imagePath  withName:(NSString*)imageName{
    NSString *fileName =[NSString stringWithFormat:@"%@/%@/%@",rootFilePath,imagePath,imageName];
    return [[NSImage alloc]initWithContentsOfFile:fileName];
}
-(void)keyUp:(NSEvent *)event{
    if ((event.keyCode == 36)&&[self isInputIsFirstResponser]) {
        
        [self renameAllFile:nil];
    }
}

-(BOOL)isInputIsFirstResponser{
    NSResponder *firstResponder = [[NSApp keyWindow]firstResponder ];
    if([firstResponder isKindOfClass:[NSText class]]&&[(id)firstResponder delegate] == _renameTextField){
        return YES;
    }
    return NO;
}
- (IBAction)renameAllFile:(id)sender {
    NSString *targetName = _renameTextField.stringValue;
    if ([targetName isEqualToString:@""]) {
        [_renameTextField resignFirstResponder];
        [alert runModal];
        return;
    }
    NSString *fileName = [imageArray objectAtIndex:currentIndex];
    if (![targetName containsString:@"."]) {
        NSString *suffix = [fileName componentsSeparatedByString:@"."][1];
        targetName  =[NSString stringWithFormat:@"%@.%@",targetName,suffix];
    }
    for(NSString *path in allSubDirectory){
        NSString *directory = [NSString stringWithFormat:@"%@/%@",rootFilePath,path];
        NSString *sourceFile = [NSString stringWithFormat:@"%@/%@",directory,fileName];
        NSString *targetFile = [NSString stringWithFormat:@"%@/%@",directory,targetName];
        [mFileManager moveItemAtPath:sourceFile toPath:targetFile error:nil];
    }
    imageArray[currentIndex] = targetName;
    _renameTextField.placeholderString = targetName;
    [_mTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:currentIndex] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 80;
}
-(BOOL)performDragOperation:(id<NSDraggingInfo>)sender{
    NSPasteboard  *pasteBoard = sender.draggingPasteboard;
    if ([[pasteBoard types]containsObject:NSFilenamesPboardType]) {
        NSArray *fileNames = [pasteBoard propertyListForType:NSFilenamesPboardType];
        NSLog(@"file Name : %@",fileNames);
        return YES;
    }
    return NO;
}
- (IBAction)openFolder:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setPrompt:@"选择文件夹"];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    
    [openPanel beginSheetModalForWindow:[[self view]window] completionHandler:^(NSInteger result) {
        if (result == 1){
            [self navigateToNextPage:[[openPanel URLs] objectAtIndex:0].absoluteURL];
            _openButton.hidden = YES;
        }
    }];
}
-(void)navigateToNextPage:(NSURL*)filePath{
    rootFilePath = [filePath path];
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@",rootFilePath,@"xxhdpi"];
    imageArray = [NSMutableArray arrayWithArray:[mFileManager contentsOfDirectoryAtPath:imagePath error:nil]];
    [_mTableView reloadData];
    
    
}

@end
