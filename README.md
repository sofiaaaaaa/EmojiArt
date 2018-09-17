#  README.md

## References

* lecture11: Drag and Drop, Table View and Collection View https://youtu.be/M3X9o9wbn9o


### Drag and Drop 

* Very interoperable way to move data around Between apps on iPad and within an app on all iOS 11 devices. Your app continues to work normally while drag and drop is going on. Multitouch allows some fingers to be doing drag and drop and other fingers working your app. New multitasking UI in iOS 11 makes drag and drop really useful. 

* Interactions A view “sings up” to participate in drag and/or drop using an interaction. It’s kind of like “gesture recognizer” for drag and drop  Iet drag/dropInteraction = UIDrag/DropInteraction(delegate: theDelegate) view.addInteraction(drag/dropInteraction) Now the theDelegate will get involved if a drag or drop occurs in the view. 

* Starting a drag
Now, when the user makes a dragging gesture, the delegate gets …     func dragInteraction(_ interaction: UIDragInteraction, itemForBeginning session: UIDragSession
) -> [UIDragItem]
… and can return the items it is willing to have dragged from the view.
Returning an empty array means “don’t drag anything after all.”

A UIDragItem is created like this …
let dragItem = UIDragItem(itemProvider: NSItemProvider(object: provider))
Providers: NSAttributedString, NSSting, UIImage, NSURL, UIColor, MKMapItem, CNContact.
You can drag your own types of data, but that’s beyond the scope of this course.
Note that some of these types start with NS… you might have to use as? to cast them.

You can also provide an object that will be passed to drop targets inside your own app..
dragItem.localObject = someObject 

* Adding to a drag
Even in the middle of a drag, users can add more to their drag if you implement …

func dragInteraction(_ interaction: UIDragInteraction, 
itemsForAddingTo session: UIDragSession
) -> [UIDrageItem]
… and returns more items to drag.

* Accepting a drop When a drag moves over a view with a UIDropInteraction, the delegate gets …  func dropInteraction(_ interaction:  UIDropInteraction,          canHandle session: UIDragSession ) -> Bool … at which point the delegate can refuse the drop before it even gets started.  To figure that out, the delegate can ask what kind of objects can be provided … let stringAvailable = session.canLoadObjects(ofClass: NSAttributedString.self) let imageAvailable = session.canLoadObjects(ofClass:UIImage.self) … and refuse the drop if it isn’t to your liking.   If you don’t refuse it in canHandle:, then as the drag progresses, you’ll start getting … func dropInteraction(_ interaction: UIDropInteraction,         sessionDidUpdate session: UIDragSession ) -> UIDropProposal … to which you will respond with UIDropProposal(operation: .copy/ .move/ .cancel). .cancel means the drop would be refused .copy means drop would be accepted .move means drop would be accepted and would move the item (only for drags within an app)  If it matters, you can find out where the touch is with session. location(in: view).  If all that goes well and the use let’s go of the drop, you get to go fetch the data … func dropInteraction(_ interaction: UIDropInteraction,        performDrop session: UIDropSession )   You will implement this method by calling loadObjects(ofClass:) on the session. This will go and fetch the data asynchronously from whomever the drag source is.  session.loadObjects(ofClass: NSAttributedString.self) { the Strings in      // do something with the dropped NSAttributedStrings
}

The passed closure will be executed some time later on the main thread.      You can call multiple loadObjects(ofClass:) for different classes.      You don’t usually do anything else in dropInteraction(performDrop:).
 ## Table and Collection Views

* UITableView and UICollectionView These are UIScrollView subclasses used to display unbounded amounts of information. Table View presents the information in a long (possibly sectioned) list. Collection View presents the information in a 2D format (usually “flowing” like text flows). They are very similar in their API, so we will learn about them at the same time. 

* UITableView It can show simple ancillary information…
Or arbitrarily complex information … 

The rows can also be Grouped …     (but usually only when the information in the table is fixed)

* UICollectionView Is configurable to show information in any 2D arrangement. But by default it “flows” the items it shows like text flows. There is only “custom” layout of information. Like Table View, can also be divided into sections … 

* Where does the data com from? The most important thing to understand about both of them is where they get their data. Remember that, per MVC,”views are not allowed to own their data”. So we can’t just somehow set the data in some var. Instead, we set a `var` called `dataSource`. The type of the dataSource var is a protocol with methods that suppply the data. dataSource is exactly like a delegate in how it works. Table View and Collection View also have a delegate. Their delegate controls how they look, not what data they display (that’s the dataSource). 

* Setting the dataSource and delegate
 In UITableView … var dataSource : UITableViewDataSource var delegate: UITableViewDelegate In UICollectionView … var dataSource : UICollectionViewDataSource var delegate : UICollectionViewDelegate  These are automatically set for you if you use the prepackaged MVCs. If you drag out a UITableView or UICollectionView, you must set these vars yourself. 99.99% of the time, these vars will want to be set to the Controller of the MVC.  
* The UITableView/CollectionViewDataSource protocol The “data retrieving” protocol has many methods. But these 3 are the core (UITableView abbreviated to UITV and UICollectionView to UICV) … 

```
UITableView 

 func numberOfSections(in tableView: UITV) -> Int func tableView(_ tv: UITV, numberOfRowsInSection section: Int) -> Int func tableView(_ tv: UITV, cellForRowAt indexPath: IndexPath) -> UITableViewCell
 UICollectionView
 func numberOfSections(in collectionView: UICV) -> Int func collectionView(_ cv: UICV, numberOfItemsInSection section: Int) -> Int func collectionView(_ cv: UICV, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
```

 `IndexPath` specifies which row (in TV) or item (in CV) we’re talking about. In both, you get the section the row or item is in from indexPath.section. In TV, you get which row from indexPath.row; in CV you get which item from indexPath.item. CV might seem like rows and columns, but it’s not, it’s just items “flowing” like text.  
* Putting data into the UI
 Let’s focus on how we implement that last method. We’ll look at it in the context of UITableView,  but it’s the same for UICollectionView.  
```
func tableView(_ tv: UITV, cellForRowAt indexPath: IndexPath) -> UITableViewCell {          let cell = tv.dequeueReusableCell(withIdentifier : “MyCellId”, for : indexPath)  }
```
  This gets the `UITableViewCell` we are going to lad up with our Model data and return. The UITableView will then use that UITableViewCell to draw the row at the given indexPath. We need to understand a few things to parse this line of code … 

* Cell Reuse
 A UITableView might have 1000s of rows (all your Music Library songs maybe?). If it had to create a UIView for all of them, it would be very inefficient. So it reuses the cells. When a UITableViewCell scrolls off the screen, it gets put in a pool to be reused. The dequeueReusableCell(withIndentifier:) method grabs one out of that reuse pool. But what if the reuse pool is empty (like when the table first appears)?  
* Cell Creation
 How do new (non-reused) cells get created? They get created by copying a prototype cell you configure in your storyboard.   
Each prototype has an identifier you set in the Inspector. 

Prototype #1 (a Basic cell)
Prototype #2 (a Custom cell)  
```
func tableView(_ tv: UITV, cellForRowAt indexPath: IndexPath) -> UITableViewCell {     let cell = tv.dequeueReusableCell(withIndentifier: “MyCellID”, for: indexPath)
}
```
 
* Implementing cellForRowAt 

Let's focus on how we implement that last method
We'll look at it in the context of UITableView, but it's the same for UICollectionView


So now we can understand this line of code.
It is reusing a UITableViewCell with the given identifier if possible.
Otherwise it is making a copy of the prototype in the storyboard.
The fact that cells are reused has serious implications for multithreading. By the time something returns from another thread, a cell might have been reused.

```
func tableView(_ tv: UITV, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let prototype = decision ? "FoodCell" : "CustomFoodCell"
    let cell = tv.dequeueReusableCell(withIndentifier: prototype, for: indexPath)
}
```
 
The `decision` can be made based on many factors.
Usually its based on the indexPath (i.e. which row we're displaying here).
But it might also be based on the data in our Model at that indexPath.
Some data might be an image, whereas other data is text, etc.

```
func tableView(_ tv: UITV, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let prototype = decision ? "FoodCell" : "CustomFoodCell"
    let cell = tv.dequeueReusableCell(withIndentifier: prototype, for: indexPath)
    cell.textLabel?.text = food(at: indexPath)
    cell.detailTextLabel?.text = emoji(at: indexPath)
}
```

So what API can we use to configure this cell that we just reused/created?
Well, for UITableView only, the default UITableViewCell has a few basic things ...

textLabel, detailTextLabel and imageView

But for UICollectionView and for custom UITableViewCells, WE have to provide the API.

 
* Custom UITableViewCell subclass

When we put custom UI into a UITableViewCell prototype, we probably need outlets to it.
Can we hook them up directly to our Controller?
No, we can't, because there might be multiple rows with that type of cell.
They can't all be hooked up to the same single outlet. 

```
class MyTVC: UITableViewController 
{
@IBOutlet var name: UILabel
@IBOutlet var emoji: UILabel
...

}
```

Instead, we have to subclass UITableViewCell and put the outlets in there.


```
class MyTVC: UITableViewCell 
{
    @IBOutlet var name: UILabel
    @IBOutlet var emoji: UILabel
    ...

}
```
Then we inspect the cell in the Identity Inspector and change its class from UITableViewCell to MyTVC

In order to get at those outlets, we need to cast our UITableViewCell to our subclass.
Then we can access its outlets (or any other API it wants to make public).
In Collection View, we always have to do this (there are only "Custom" cellls).
In Table View, we do it when the simple Basic, Subtiltle, etc. styles aren't enough.

### Static Table View

* Using Table View purely for UI layout

Sometimes we just use a table view to lay out UI elements.
A fantastic example of this is the iOS Settings app.
In this case, you do not need to do any of the UITableViewDataSource stuff.
And you can connect outlets directly to your Controller (because there's only one of each cell).
To do this, just set your UITableView to have Static Cells instead of Dynamic Prototypes.
Usually static table views are Style Grouped.
Then pick the sesction in the Document Outline you want to add cells to and add them. 

Note that this row has a Detail Disclosure Accessary.

We can segue from the row and/or from the Detail Disclosure  Accessory.

### Table View Segues

* Preparing to segue from a row in a table view

The sender argument to prepareForSeque is the UITableViewCell of that row ...

```
func prepare(for segue: UIStoryboardSegue,sender: Any?) {
    if let identifier = segue.identifier {
    switch identifier {
    case "XyzSegue" : // handle xyzSegue here
    case "AbcSegue" :
        if let cell = sender as? MyTableViewCell,
        let indexPath = tableView.indexPath(for: cell) 
        let seguedToMVC = segue.destination as? MyVC {
            seguedToMVC.publicAPI = data[indexPath.section][indexPath.row]
            }
    default: break
    }
  }
}
```

Usually we will need the IndexPathof the UITableViewCell
Because we use that to index into our internal data structures.

and then get data from our internal data structure using the IndexPath's section and row
and use that information to prepare the segued-to API using its public API

* Seguing from Collection View cells

Probably best done from this UICollectionViewDelegate method ...
func collectionView(collectionView: UICV, didSelectItemAtIndexPath indexPath: IndexPath)
Use performSegue(withIdentifier: ) from there.
This strategy could also be used for UITableView.

* What if your Model changes?

func reloadData()
Causes it to call numberOfSectionsInTableView and numberOfRows/ItemsInSection
all over again and then cellForRow/ItemAt on each visible row or item
Relatively heavyweight, but if your entire data structure changes,that's what you need
If only part of your Model changes, there are lighter-weight reloaders, for example ...

func reloadRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation )
... among othes and of course similar methods for Collection View.

* Controlling the height of rows in a Table View

Row height can be fixed (UITableView's var rowHeight: CGFloat )
Or it can be determined using autolayout (rowHeight = UITableViewAutomaticDimension)
If you do automatic, help the table view out by setting estimatedRowHeight to something
The UITableView's delegate can also control row heights...
func tableView(UITableView, {estimated}heightForRowAt indexPath: IndexPath) -> CGFloat
Beware, the non-estimated version of this could et called  A LOT if you have a big table. 

* Controlling the size of cells in a Collection View

Cell size can be fixed in the storyboard.
You can also drive it from autolayout similar to table view.
Or you can return the size from this delegate method ..

```
func collectionView(_ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout, 
    sizeForItemAt indexPath: IndexPath
    ) -> CGSize
```
### Table View Headers

* Setting a header for each section

If you have a multiple-section table view, you can set a header (or footer) for each.
There are methods to set this to be a custom  UIView.
But usually we just supply a String for the header using this method ...

```
func tableView(_ tv: UITV, titleForHeaderInSection section: Int) -> String?
```

### Collection View Headers

* Headers and footers are a bit more difficult in Collection View

You can't just specify them as Strings.
First you have to "turn them on" in the storyboard.
They are reusable (like cells are), so you have to make a UICollectionReusableView subclass.
You put your UILable or whatever for your header, then hook up an outlet.
Then you implement this dataSource method to dequeue and provide a header.

```
func collectionView(_ collectionView: UICollectionView,
                viewForSupplementaryElementOfKind kind: String, 
                at indexPath: IndexPath
) -> UICollectionReusableView
```

Use dequeueReusableSupplementaryView(ofKind: withReuseIdentifier: for:) in there.
kind will be UICollectionElementKindSectionHeader or Footer.

### Collection View Segue

* Seguing from Collection View cells
Probably best done from this UICollectionViewDelegate method ...

```
func collectionView(collectionView: UICV, didSelectItemAtIndexPath indexPath: IndexPath)
```

Use performSegue(withIdentifier: ) from there.
This strategy could also be used for UITableView.

* What if your Model changes?

func reloadData()

Causes it to call numberOfSectionsInTableView and numberOfRows/ItemsInSection all over again and then cellForRow/ItemAt an each visible row or item Relatively heavyweight, but if your entire data structure changes, that's what you need 
If only part of your Model changes,there are lighter-weight reloaders,for example...

func reloadRows(at indexPaths: [indexPath], with animation: UITableViewRowAnimation)

... among others and of course similar methods for Collection View. 

* Controlling the height of rows in a Table View

Row height can be fixed (UITableView's var rowHeight:CGFloat)
Or it can be determined using autolayout (rowHeight = UITableViewAutomaticDimension)
If you do automatic, help the table view out by setting estimatedRowHeight to something
The UITableView's delegate can also control row heights..

func tableView(UITableView {estimated}heightForRowAt indexPath: IndexPath) -> CGFloat

Beware: the non-estimated version of this could get called A LOT if you have a big table

* Controlling the size of cells in a Collection View
Cell size can be fixed in the storyboard.
You can also drive it from autolayout similar to table view.
Or you can return the size from this delegate method ...

func collectionView(_ collectionView: UICollectionView, 
                                layout collectionViewlayout: UIColle ctionViewLayout,
                                sizeForItemAt indexPath: IndexPath
) -> CGSize

### Table View Headers

* Setting a header for each section
If you have a multiple-section table view, you can set a header (or footer) for each.
There are methods to set this to be a custom UIView.
But usually we just supply a String for the header using this method ...

func tableView(_ tv:UITV, titleForHeaderInection section: Int) -> Stirng?

### Collection View Headers

* Headers and footers are a bit more difficult in Collection View
You can't just specify them as Strings.
First you have to "turn them on" int the storyboard.
The are reusable (like cells are), so you have to make a UICollectionReusableView subclass.
You put your UILabel or whatever for your header, then hook up an outlet.
Then you implement this dataSource method to dequeue and provide a header.

func collectionView(_ collectionView: UICollectionView, 
                                viewForSupplementaryElementOfKind kind: String, 
                                at indexPath: IndexPath
                        ) -> UICollectionReusableView

Use dequeueReusableSupplementaryView(ofKind: withReuseIdentifier:for:) in there.
kind will be UICollectionElementKindSectionHeader or Footer.

### Other Methods

* There are dozens of other methods in these classes

Controlling the look (separator style and color, default row height, etc.).
Getting cell information (cell for index path, index path for cell, visible cells, etc.).
Scrolling to a row (UITableView/UICollectionView are subclasses of UIScrollView).
Selection management (allows multiple selection, getting the selected row, etc.).
Moving, inserting and deleting rows, etc.
As always, part of learning the material in this course is studying the documentation.

* FoodForThought

Example code doing most of what has been described will be posted to the class website.

It's in an app called FoodForThought.
You'll see all these things in action.


### UITextField

* finding out when editing has ended

Another delegate method ...
`func testFieldDidEndEditing(sender: UITextField)`
Sent when the text field resigns being first responder.

* UITextField is a UIControl
So you can also set up `target/action` to notify you when things change.
Just like with a button, there are different UIcontrolEvents which can kick off an action.
Right-click on a UITextField in a storyboardtosee the options available. 

### Keyboard

* Conrolling the appearance of the keyboard

Remember, whether keyboard is showing is a function of whether its first responder.
You can also control what kind of keyboard comes up.
Set the properties defined in the UITextInputTraits protocol (UITextField implements).

```
var autocapitalizationType: UITextAutocapitalizationType //words, sentences, etc.
var autocorrectionType: UITextAutocorrectionType // .yes or .no
var returnKeyType: UIReturnKeyType // Go, Search,Google,Done,etc
var isSecureTextEntry: Bool // for passwords,for example
var keyboardType: UIKeyboardType // ASCII, URL, PhonePad, etc.
```

* Other Keyboard functionality

Keyboards can have accessory views hat appear above the keyboard (custom toolbar, etc.).

`var inputAccessoryView: UIView // UITextField method`

### UITextField

* Other UITextField properties
var clearOnBeginEditing: Bool
var adjustsFontSizeToFitWidth: Bool
var minimumFontSize: CGFloat    // always set this if you set adjustsFontSizeToFitWidth
var placeholder: String?            // drawn in gray when text field is empty
var background/disabledBackground: UIImage?
var defaultTextAttributes: [String: Any] / applies to entire text


*Other UITextField functionality
UITextFields hava a "left" and "right" overlays.
You can control in detail the layout of the text field (border, left/right view, clear button).

### UserDefaults

* A very lightweight and limited database
UserDefaults is essentially a very tiny database that persists between launchings of your app.
Great for things like "settings" and such. Do not use it for anything big!

* What can you store there?
You are limited in what you can store in UserDefaults: it only stores Property List data. 
A Property List is any combo of Array , Dictionary, String, Date, Data or a number (Int, etc.).
This is an old Object-C API with no type that represents all those, so this API uses Any.
If this were a new, Swift-style API, it would almost certainly not use Any.
(Likely there would be a protocol or some such that those types would implement.)

* What does the API look like?

It's "core" functionality is simple. It just stores and retrives Property Lists by key. 

func set(Any?, forKey: String)  // the Any has to be a Property List (or crash)
func object(forKey: String) -> Any? // the Any is guaranteed to be a Property List

* Reading and Writing

You don't usually create one of these databases with UserDefaults().
Instead, you use the static (type) var called standard ...
let defaults = UserDefaults.standard

Setting a value in the database is easy since the set method takes an Any?.

defaults.set(3.1415, forKey: "pi") // 3.1415 is a Double which is a Property List type
defaults.set([1,2,3,4,5], forKey: "My Array") // Array and Int are both Property Lists
defaults.set(nil, forKey: "Some String") //removes any data at that key

You can pass anything as the first argument as long as it's a combo of Property List types

UserDefaults also has convenience API for getting many of the Property List types.

func double(forKey: String) -> Double
func array(forKey: String) -> [Any]?    // returns nil if non-Array at that key
func dictionary(forKey: String) -> [String: Any]? // note that keys in return are Strings The Any in the returned values will, of course, be a Property List type. 

* Saving the database

Your changes will be occasionally autosaved. 
But you can force them to be saved at any time with synchronize ...

if !defaults.synchronize() { // failed!!! but not clear what you can do about it }
(it's not "free"to synchronize, but it's not that expensive either)

### Archiving

* There are two mechanisms for making ANY object persistent

A historical method which is how, for example, the storyboard is made persistent.
A new mechanism in iOS 11 which is supported directly by the Swift language environment.
We're only going to talk in detail about the second of these.
Since it's supported by the language, it's much more likely to be the one you'd use.

* NSCoder (old) mechanism

Requires all objects in an object graph to implement these two methods ...

func encode(with aCoder: NSCoder)
init(coder: NSCoder)

Essentially you store all of your object's data in the coder's dictionary.
The you have to be able to initialize your object from a coder's dictionary.
References within the object graph are handled automatically. 
You can then take an object graph and turn it into a Data (via NSKeyedArchiver).
And then turn a Data back into an object graph (via NSKeyedUnarchiver).
Once you have a Data, you can easily write it to a file or otherwise pass it around.

* Codable (new) mechanism

Also is essentially a way to store all the vars of an object into a dictionary.
To do this, all the objects in the graph of objects you want to store must implement Codable.
But the difference is that, for standard Swift types, Swift will do this for you.
If you have non-standard types, you can do something similar to the old method.

Some of the standard types (that you'd recognize) that are automatically Codable by Swift...

String, Bool, Int, Double, Float, 
Optional
Array, Dictionary, Set, Data
URL
Date, DateComponents, DateInterval, Calendar
CGFloat, AffineTransform, CGPoint, CGSize, CGRect, CGVector
IndexPath, IndexSet
NSRange

Once your object graph is all Codable, you can convert it to either JSON or a Property List.

let object: MyType =  ...
let jsonData: Data? try? JSONEncoder().encode(object)

Note that this encode throws. You can catch and find errors easily.

By the way, you can make a String object out of this Data like this ...

let jsonString = String(data: jsonData!, encoding: .utf8) // JSON is always utf8

To get your object graph back from the JSON
if let myObject : MyType = try? JSONDecoder().decode(MyType.self, from: jsonData!) {
}

Here's what it might look like to catch errors during a decoding.
The thing decode throws is an enum of type DecodingError.
Note how we can get the associated values of the enum similar to how we do with switch.

do {
    let object = try JSONDecoder().decode(MyType.self, from : jsonData!)
    } catch DecodingError.keyNotFound(let key, let context) {
        print ("couldn't find key \(key) in JSON: \(context.debugDescription)")
    } catch DecodingError.valueNotFound(let type, let context) {
    } catch DecodingError.typeMismatch(let type, let context) {
    } catch DecodingError.dataCorrupted(let context){
    }
    
* Codable Exmaple
So how do you make your data types Codable? Usually you just say so...

struct MyType: Codable {
    var someDate: Date
    var someString: String
    var other: SomeOtherType // SomeOtherType has to be Codable too!
}
    
If your vars are all also Codable (standard types all are), then you're done!

The JSON for this might look like ...
{
    "someDate": "2017-11...",
    "someString" : "Hello", 
    "other" : <whatever SomeOthertype looks like in JSON>
}

Sometimes JSON keys might have different names than your var names (or not be included).
For example, someDate might be some_date.
You can configure this by adding a private enum to your type called CodngKeys like this ...

```
struct MyType : Codable {
    var someDate: Date
    var someString: String
    var other: SomeOtherType // SomeOtherType has to be Codable too!

    private enum CodingKeys: String, CodingKey {
        case someDate = "some_date"
        // note that the someString var will now not be included in the JSON
        case other // this key is also called "other" in JSON
    }
    
}
```
### File System

* Your application sees iOS file system like a normal Unix fileSystem

It starts at /.
There are file protections, of course, like normal Unix,so you can't see everything.
In fact, you can only read and write in your application's "sandbox".

* Why sandbox?

Security (so no one els can damage your application).
Privacy (so no other applications can view your application's data).
Cleanup (when you delete an application, everything it has ever written goes with it)

* So what's in this "sandbox"?

Application directory - Your executable, .storyboards, .jpgs, etc.; not wrtieable
Documents directory - Permanent storage created by and always visible to the user.
Application Support directory - Permanent storage not seen directly by the user.
Caches directory - Store temporary files here (this is not backed up by iTUnes).
Other directories (see documentation).

* Getting a path to these special sandbox directories
FileManager(along with URL) is what you use to find out about what's in the file system.
You can, for example, find the URL to these special system directories like this...

let url: URL = FileManager.default.url(
                for directory: FileManager.SearchPathDirectory.documentDirectory, 
                in domainMask: .userDomainMask, //always .userDomainMask on iOS
                appropriateFor: nil,  // only meaningful for "replace" file operations
                create: true // whether to create the system directory if it doesn't already exist
                )

### URL

* Building on top of these system paths

URL methods: 

func appendingPathComponent(String) -> URL
func appendingPathExtension(Strng) -> URL // e.g. "jpg"

* Finding out about what's at the other end of a URL

var isFileURL : Bool  // is this a file URL (whether file exists or not) or something else?
func resourceValues (for keys: [URLResourceKey]) throws -> [URLResourceKey: Any]?
Example keys: .creationDateKey, .isDirectoryKey, .fileSizeKey

* Data 
Reading binary data from a URL ...
init(conetentsOf: URL, options: Data.ReadingOptions) throws

Writing binary data to a URL ...

func write(to url: URL, options: Data.WritingOptions) throws -> Bool
The options can be things like .atomic (write to tmp file, then swap) or .withoutOverwriting.
Notice that this fucntion throws.

* FileManager

Provides utility operations.

e.g., fileExists(atPath: String) -> Bool

Can create and enumerate directories; move, copy, delete files; etc.
Thread safe (as long as a given instance is only server used in one thread). 
Also has a delegate with lots of "should" methods 

### Core Data

* So how do you access all of this stuff in your code?
Core data is access via an NSManagedObjectContext.
It is the hub around which all core Data activity turns.
The code that the Use Core data button adds creates one for you in your AppDelegate. 

* Deleting objects
 context.delete(tweet)
 
 * Saving changes
    You must explicitly save any changes to a context, but note that this throws.
    
```
do {
    try context.save()
} catch {
        // deal with error
}
```

However, we usually use a UIManagedDocument which autosaves for us...

### Querying

* Searching for objects in the database

Let's say we want to query for all TwitterUsers ...

let request: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()

... who have created a tweet in the last 24 hours ...

let yesterday = Date(timeIntervalSinceNow: -24*60*60) as NSDate

request.predicate = NSPredicate(format; "any tweets.created > %@", yesterday)

... sorted by the TwitterUser's name....

request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

let context : NSManagedObjectContext = ...
let recentTweeters = try? context.fetch(request)

Returns an empty Array (not nil) if it succeeds and there are no matches in the database.
Returns an Array of NSManagedObjects (or subclasses thereof) if there were any matches.
And obviously the try fails if the fetch fails. 

### Cloud Kit

* Cloud Kit

A database in the cloud. Simple to use, but with very basic "database" operations.
Since it's on the network, accessing the database could be slow or even impossible.
This requires some thoughtful programming.

* Important Compoents
Record Type - like a class or struct
Fields - like vars in a class or struct
Record - an "instance" of a Record type
Reference - a "pointer" to another Record
Database - a place where Records are stored
Zone - a sub-area of a Database
Container - collection of Databases
Query - an Database search
Subscription - a "standing Query" which sends push notifications when changes occur

* What it looks like to create a record in a database

```
let db = CKContainer.default.publicCloudDatabase
let tweet = CKRecord("Tweet")
tweet["text"] = "140 characters of pure joy"
let tweeter = CKRecord("TwitterUser")
tweet["tweeter"] = CKReference(record: tweeter, action: .deleteSelf)
db.save(tweet) { (savedRecord: CKRecord?, error: NSError?) -> Void in
    if error == nil {
        // hooray!
    } else if error?.errorCode == CKErrorCode.NotAuthenticated.rawValue {
        // tell user he or she has to be logged in to iCloud for this to work!
    } else {
            // report other errors (there are 29 different CKErrorCodes!)
    }
}
```

* What it looks like to query for records in a database

```
let db = CKContainer.default.publicCloudDatabase
let predicate = NSPredicate(format: "text contains %@", searchString)
let query = CKQuery(recordType: "Tweet", predicate: predicate)
db.perform(query) { (records: [CKRecord]?, errors: NSError?) in
    if error == nil {
        //record will be an array of matching CKRecords
    } else if error?.errorCode == CKErrorCode.NotAuthenticated.rawValue {
        // tell user he or she has to be logged in to iCloud for this to work!
    } else {
        // report other errors (there are 29 different CKErrorCodes!)
    }
}
```
### UIDocument

* When to use UIDocument

If your application stores user information in a way the user perceives as a "document".
If you just want iOS to manage the primary storage of user information. 

* What does UIDocument do?

Manages all interaction with storage devices (not just filesystem, but also iCloud, Box, etc.).
Provides asynchronous opening, writing, reading and closing of files.
Autosaves your document data.
Makes integration with iOS 11's new Files application essentially free.

* What do you need to do make UIDocument work?
Subclass UIDocument to add vars to hold the Model of your MVC that shows your "document".
Then implement one method that writes the Model to a Data and one that reads it from a Data.
That's it.
Now you can use UIDocument's opening, saving and closing methods as needed. 
You can also use its "document has changes" method (or implement undo) to get autosaving. 

* Subclassing UIDocument

For simple documents, there's nothing to do here except add your Model as a var ...

```
class EmojiArtDocument : UIDocument {
    var emojiArt: EmojiArt?
}
```

* Saving your document

You can let your document know that the Model has changed with this method...

myDocument.updateChangedCount(.done)
...or you can use UIDocument's undoManager (no time to cover that, unfortunately!)
UIDocument will save your changes automatically at the next best opportunity.
Or you can force a save using this method...

```
let url = myDocument.fileURL // or something else if you want "save as"

myDocument.save(to url: URL, for: UIDocumentSaveOperation) { success in
    if success {
        // your model has successfully been saved
    } else {
        // there was a problem, check documentState
    }

}
```

UIDcoumentSaveOperation is either .forCreating or .forOverwriting. 

* Document State

var documentState : UIDocumentState

.normal - document is open and ready for use!
.closed -  document is closed and must be opened to be used
.savingError - document couldn't be saved (override handleError if you want to know why)
.editingDisabled - the document cannot currently be edited (so don't let your UI do that)
.progressAvailable - how far a large document is in getting loaded (check progress var)
.inConflict - someone edited this document somewhere else (iCloud)

To resolve conflicts, you access the conflicting versions with...

NSFileVersion.unresolvedConflictVersionsOfItem(at url: URL) -> [NSFileVersion]?
For the best UI, you could give your user the choice of which version to use.
Or, if your document's contents are "mergeable", you could do that. 
documentState can be "observed" using the UIDocumentStateChanged notification (more later).

