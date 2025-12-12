Directory Structure

Introduction
App Directories
Public assets
Retrieving image assets
Retrieving public assets

Introduction
Every Nylo project comes with a simple boilerplate for managing your files. It has this structure to streamline the development of your projects.

The directory structure was inspired by Laravel.


App Directories
The below app directories are listed inside the lib folder.

app This folder includes any files relating to models, controllers and networking.

commands Include your custom commands here.
controllers Include your controllers here for your Widget pages.
models Create your model classes here.
networking Add any API services here for managing APIs or fetching data from the internet.
events Add all your event classes here.
forms Add all your form classes here.
commands Add all your command classes here.
providers Add any provider classes here that need booting when your app runs.
config This folder contains configuration files such as your font, theme and localization settings.

design Manage the font, logo and loader with this file.
theme Set and configure the themes you want your flutter app to use.
localization Manage the localization, language and other things relating to locale in this file.
decoders Register modelDecoders and apiDecoders.
keys Contains your local storage keys.
events Register your events in the Map object.
providers Register your providers in the Map object.
validation_rules Register your custom validation rules.
toast_notification_styles Register your toast notification styles.
resources This folder includes any files that are key components for your user's UI experience like pages, widgets and themes.

pages Include your Widgets here that you will use as Page's in your project. E.g. home_page.dart.
themes By default, you'll find two themes here for light and dark mode, but you can add more.
widgets Any widgets you need to create can be inserted here, like a date_picker.dart file.
routes This folder includes any files relating to routing.

router.dart You can add your page routes in this file.

Public assets
Public assets can be found in the public/. This directory is used for images, fonts and more files that you may want to include in your project.

app_icon This is used for generating app_icons for the project.
images Include any images here in this directory.
fonts Add any custom fonts here.
postman
collections Add your postman collections here.
environments Add your postman environments here.

Retrieving an image asset
You can use the normal, standard way in Flutter by running the following:

Image.asset(
  'public/images/my_logo.png',
  height: 50,
  width: 50,
),
Or you can use getImageAsset(String key) helper

Image.asset(
  getImageAsset("my_logo.png"),
  height: 50,
  width: 50,
),
Lastly, with the localAsset extension helper

Image.asset(
    "my_logo.png",
    height: 50,
    width: 50,
).localAsset(),
In this example, our public/images/ directory has one file nylo_logo.png.

public/images/nylo_logo.png

Retrieving a public asset
You can get any public asset using getPublicAsset(String key)

VideoPlayerController.asset(
    getPublicAsset('videos/intro.mp4')
);
In this example, our public/videos/ directory has one file intro.mp4.

public/images/intro.mp4

Basics
Router

Introduction
Basics
Adding routes
Navigating to pages
Initial route
Sending data to another page
Passing data to another page
Authentication
Authenticated route
Navigation
Navigation types
Navigating back
Page transitions
Route History
Route parameters
Using Route Parameters
Query Parameters
Route Groups
Multiple routers
Route Guards
Deep linking

Introduction
Routes guide users to different pages in our app.

You can add routes inside the lib/routers/router.dart file.

appRouter() => nyRoutes((router) {
  
  router.add(HomePage.path).initialRoute();
  
  router.add(PostsPage.path);

  router.add(PostDetailPage.path);

  // add more routes
  // router.add(AccountPage.path);

});
You can create your routes manually or use the Metro CLI tool to create them for you.

Here's an example of creating an 'account' page using Metro.

# Run this command in your terminal
dart run nylo_framework:main make:page account_page
// Adds your new route automatically to /lib/routes/router.dart
appRouter() => nyRoutes((router) {
  ...
  router.add(AccountPage.path);
});
You may also need to pass data from one view to another. In Nylo, that’s possible using the NyStatefulWidget. We’ll dive deeper into this to explain how it works.


Adding routes
This is the easiest way to add new routes to your project.

Run the below command to create a new page.

dart run nylo_framework:main make:page profile_page
After running the above, it will create a new Widget named ProfilePage and add it to your resources/pages/ directory. It will also add the new route to your lib/routes/router.dart file.

File: /lib/routes/router.dart

appRouter() => nyRoutes((router) {
  ...
  router.add(HomePage.path).initialRoute();

  // My new route
  router.add(ProfilePage.path);
});

Navigating to pages
You can navigate to new pages using the routeTo helper, here's an example`.

void _pressedSettings() {
    routeTo(SettingsPage.path);
}

Multiple routers
If your routes/router.dart file is getting big, or you need to separate your routes, you can. First, define your routes in a new file like the below example.


Example new routes file: /lib/routes/dashboard_router.dart
NyRouter dashboardRouter() => nyRoutes((router) {
   
   // example dashboard routes
   router.add(AccountPage.path);
   
   router.add(NotificationsPage.path);
});
Then, open /lib/app/providers/route_provider.dart and add the new router.

import 'package:flutter_app/routes/router.dart';
import 'package:flutter_app/routes/dashboard_router.dart';
import 'package:nylo_framework/nylo_framework.dart';

class RouteProvider implements NyProvider {

  boot(Nylo nylo) async {
    nylo.addRouter(appRouter());

    nylo.addRouter(dashboardRouter()); // new routes

    return nylo;
  }
}

...

Initial route
In your routers, you can set a page to be the initial route by passing the initialRoute parameter to the route you want to use.

Once you've set the initial route, it will be the first page that loads when you open the app.

appRouter() => nyRoutes((router) {
  router.add(HomePage.path);

  router.add(SettingsPage.path);

  router.add(ProfilePage.path).initialRoute(); 
  // new initial route
});
Or like this

appRouter() => nyRoutes((router) {
  ...
  router.add(HomePage.path, initialRoute: true);
});

Route guards
Route guards are used to protect your pages from unauthorized access.

To create a new Route Guard, run the below command.

# Run this command in your terminal to create a new Route Guard
dart run nylo_framework:main make:route_guard dashboard
Next, add the new Route Guard to your route.

// File: /routes/router.dart
appRouter() => nyRoutes((router) {
  router.add(HomePage.path);

  router.add(LoginPage.path);

  router.add(DashboardPage.path,
    routeGuards: [
      DashboardRouteGuard() // Add your guard
    ]
  ); // restricted page
});
You can modify the onRequest method to suit your needs.

File: /routes/guards/dashboard_route_guard.dart

class DashboardRouteGuard extends NyRouteGuard {
  DashboardRouteGuard();

  @override
  onRequest(PageRequest pageRequest) async {
    // Perform a check if they can access the page
    bool userLoggedIn = await Auth.isAuthenticated();
    
    if (userLoggedIn == false) {
      return redirectTo(LoginPage.path);
    }
    
    return pageRequest;
  }
}
You can also set route guards using the routeGuard extension helper like in the below example.

// File: /routes/router.dart
appRouter() => nyRoutes((router) {
    router.add(DashboardPage.path)
            .addRouteGuard(MyRouteGuard());

    // or add multiple guards

    router.add(DashboardPage.path)
            .addRouteGuards([MyRouteGuard(), MyOtherRouteGuard()]);
})
Creating a route guard
You can create a new route guard using the Metro CLI.

dart run nylo_framework:main make:route_guard subscribed

Passing data to another page
In this section, we'll show how you can pass data from one widget to another.

From your Widget, use the routeTo helper and pass the data you want to send to the new page.

// HomePage Widget
void _pressedSettings() {
    routeTo(SettingsPage.path, data: "Hello World");
}
...
// SettingsPage Widget (other page)
class _SettingsPageState extends NyPage<SettingsPage> {
  ...
  @override
  get init => () {
    print(widget.data()); // Hello World
    // or
    print(data()); // Hello World   
  };
More examples

// Home page widget
class _HomePageState extends NyPage<HomePage> {

  _showProfile() {
    User user = new User();
    user.firstName = 'Anthony';

    routeTo(ProfilePage.path, data: user);
  }

...

// Profile page widget (other page)
class _ProfilePageState extends NyPage<ProfilePage> {

  @override
  get init => () {
    User user = widget.data();
    print(user.firstName); // Anthony

  };

Route Groups
In Nylo, you can create route groups to organize your routes.

Route groups are perfect for organizing your routes into categories, like 'auth' or 'admin'.

You can define a route group like in the below example.

appRouter() => nyRoutes((router) {
  ...
  router.group(() => {
    "route_guards": [AuthRouteGuard()],
    "prefix": "/dashboard"
  }, (router) {
    router.add(ChatPage.path);

    router.add(FollowersPage.path);
  }); 
Optional settings for route groups are:
route_guards - This will apply all the route guards defined to the routes in the group. Learn more about route guards here.

prefix - This will add the prefix to all the routes in the group. E.g. /dashboard/chat, /dashboard/followers. Now anytime you navigate to a page in the group, it will use the prefix. E.g. routeTo(ChatPage.path) will navigate to /dashboard/chat.


Using Route Parameters
When you create a new page, you can update the route to accept parameters.

class ProfilePage extends NyStatefulWidget<HomeController> {
  static RouteView path = ("/profile/{userId}", (_) => ProfilePage());

  ProfilePage() : super(child: () => _ProfilePageState());
}
Now, when you navigate to the page, you can pass the userId

routeTo(ProfilePage.path.withParams({"userId": 7}));
You can access the parameters in the new page like this.

class _ProfilePageState extends NyPage<ProfilePage> {

  @override
  get init => () {
    print(widget.queryParameters()); // {"userId": 7}
  };
}

Query Parameters
When navigating to a new page, you can also provide query parameters.

Let's take a look.

  // Home page
  routeTo(ProfilePage.path, queryParameters: {"user": "7"});
  // navigate to profile page

  ...

  // Profile Page
  @override
  get init => () {
    print(widget.queryParameters()); // {"user": 7}
    // or 
    print(queryParameters()); // {"user": 7}
  };
As long as your page widget extends the NyStatefulWidget and NyState class, then you can call widget.queryParameters() to fetch all the query parameters from the route name.

// Example page
routeTo(ProfilePage.path, queryParameters: {"hello": "world", "say": "I love code"});
...

// Home page
class MyHomePage extends NyStatefulWidget {
  ...
}

class _MyHomePageState extends NyPage<MyHomePage> {

  @override
  get init => () {
    widget.queryParameters(); // {"hello": "World", "say": "I love code"}
    // or 
    queryParameters(); // {"hello": "World", "say": "I love code"}
  };
Query parameters must follow the HTTP protocol, E.g. /account?userId=1&tab=2


Page Transitions
You can add transitions when you navigate from one page by modifying your router.dart file.

import 'package:page_transition/page_transition.dart';

appRouter() => nyRoutes((router) {

  // bottomToTop
  router.add(SettingsPage.path,
    transitionType: TransitionType.bottomToTop()
  );

  // fade
  router.add(HomePage.path,
    transitionType: TransitionType.fade()
  );

});
Available Page Transitions
Basic Transitions
TransitionType.fade() - Fades the new page in while fading the old page out
TransitionType.theme() - Uses the app theme's page transitions theme
Directional Slide Transitions
TransitionType.rightToLeft() - Slides from right edge of screen
TransitionType.leftToRight() - Slides from left edge of screen
TransitionType.topToBottom() - Slides from top edge of screen
TransitionType.bottomToTop() - Slides from bottom edge of screen
Slide with Fade Transitions
TransitionType.rightToLeftWithFade() - Slides and fades from right edge
TransitionType.leftToRightWithFade() - Slides and fades from left edge
Transform Transitions
TransitionType.scale(alignment: ...) - Scales from specified alignment point
TransitionType.rotate(alignment: ...) - Rotates around specified alignment point
TransitionType.size(alignment: ...) - Grows from specified alignment point
Joined Transitions (Requires current widget)
TransitionType.leftToRightJoined(childCurrent: ...) - Current page exits right while new page enters from left
TransitionType.rightToLeftJoined(childCurrent: ...) - Current page exits left while new page enters from right
TransitionType.topToBottomJoined(childCurrent: ...) - Current page exits down while new page enters from top
TransitionType.bottomToTopJoined(childCurrent: ...) - Current page exits up while new page enters from bottom
Pop Transitions (Requires current widget)
TransitionType.leftToRightPop(childCurrent: ...) - Current page exits to right, new page stays in place
TransitionType.rightToLeftPop(childCurrent: ...) - Current page exits to left, new page stays in place
TransitionType.topToBottomPop(childCurrent: ...) - Current page exits down, new page stays in place
TransitionType.bottomToTopPop(childCurrent: ...) - Current page exits up, new page stays in place
Material Design Shared Axis Transitions
TransitionType.sharedAxisHorizontal() - Horizontal slide and fade transition
TransitionType.sharedAxisVertical() - Vertical slide and fade transition
TransitionType.sharedAxisScale() - Scale and fade transition
Customization Parameters
Each transition accepts the following optional parameters:

Parameter	Description	Default
curve	Animation curve	Platform-specific curves
duration	Animation duration	Platform-specific durations
reverseDuration	Reverse animation duration	Same as duration
fullscreenDialog	Whether the route is a fullscreen dialog	false
opaque	Whether the route is opaque	false
// Home page widget
class _HomePageState extends NyState<HomePage> {

  _showProfile() {
    routeTo(ProfilePage.path, 
      pageTransition: PageTransitionType.bottomToTop
    );
  }
...

Navigation Types
When navigating, you can specify one of the following if you are using the routeTo helper.

NavigationType.push - push a new page to your apps' route stack.
NavigationType.pushReplace - Replace the current route, which disposes of the previous route once the new route has finished.
NavigationType.popAndPushNamed - Pop the current route off the navigator and push a named route in its place.
NavigationType.pushAndForgetAll - push to a new page and dispose of any other pages on the route stack.
// Home page widget
class _HomePageState extends NyState<HomePage> {

  _showProfile() {
    routeTo(
      ProfilePage.path, 
      navigationType: NavigationType.pushReplace
    );
  }
...

Navigating back
Once you're on the new page, you can use the pop() helper to go back to the existing page.

// SettingsPage Widget
class _SettingsPageState extends NyPage<SettingsPage> {

  _back() {
    pop();
    // or 
    Navigator.pop(context);
  }
...
If you want to return a value to the previous widget, provide a result like in the below example.

// SettingsPage Widget
class _SettingsPageState extends NyPage<SettingsPage> {

  _back() {
    pop(result: {"status": "COMPLETE"});
  }

...

// Get the value from the previous widget using the `onPop` parameter
// HomePage Widget
class _HomePageState extends NyPage<HomePage> {

  _viewSettings() {
    routeTo(SettingsPage.path, onPop: (value) {
      print(value); // {"status": "COMPLETE"}
    });
  }
...


Authenticated Route
In your app, you can define a route to be the initial route when a user is authenticated. This will automatically override the default initial route and be the first page the user sees when they log in.

First, your user should be logged using the Auth.authenticate({...}) helper.

Now, when they open the app the route you've defined will be the default page until they log out.

appRouter() => nyRoutes((router) {

  router.add(IntroPage.path).initialRoute();

  router.add(LoginPage.path);

  router.add(ProfilePage.path).authenticatedRoute(); 
  // auth page
});
You can also navigate to the authenticated page using the routeTo helper.

routeToAuthenticatedRoute();
Learn more about authentication here.


Route History
In Nylo, you can access the route history information using the below helpers.

// Get route history
Nylo.getRouteHistory(); // List<dynamic>

// Get the current route
Nylo.getCurrentRoute(); // Route<dynamic>?

// Get the previous route
Nylo.getPreviousRoute(); // Route<dynamic>?

// Get the current route name
Nylo.getCurrentRouteName(); // String?

// Get the previous route name
Nylo.getPreviousRouteName(); // String?

// Get the current route arguments
Nylo.getCurrentRouteArguments(); // dynamic

// Get the previous route arguments
Nylo.getPreviousRouteArguments(); // dynamic

Deep Linking
Deep linking allows users to navigate directly to specific content within your app using URLs. This is useful for:

Sharing direct links to specific app content
Marketing campaigns that target specific in-app features
Handling notifications that should open specific app screens
Seamless web-to-app transitions
Setup
Before implementing deep linking in your app, ensure your project is properly configured:

1. Platform Configuration
iOS: Configure universal links in your Xcode project

Flutter Universal Links Configuration Guide
Android: Set up app links in your AndroidManifest.xml

Flutter App Links Configuration Guide
2. Define Your Routes
All routes that should be accessible via deep links must be registered in your router configuration:

// File: /lib/routes/router.dart
appRouter() => nyRoutes((router) {
  // Basic routes
  router.add(HomePage.path).initialRoute();
  router.add(ProfilePage.path);
  router.add(SettingsPage.path);
  
  // Route with parameters
  router.add(HotelBookingPage.path);
});
Using Deep Links
Once configured, your app can handle incoming URLs in various formats:

Basic Deep Links
Simple navigation to specific pages:

https://yourdomain.com/profile       // Opens the profile page
https://yourdomain.com/settings      // Opens the settings page
To trigger these navigations programmatically within your app:

routeTo(ProfilePage.path);
routeTo(SettingsPage.path);
Path Parameters
For routes that require dynamic data as part of the path:

Route Definition
class HotelBookingPage extends NyStatefulWidget {
  // Define a route with a parameter placeholder {id}
  static RouteView path = ("/hotel/{id}/booking", (_) => HotelBookingPage());
  
  HotelBookingPage({super.key}) : super(child: () => _HotelBookingPageState());
}

class _HotelBookingPageState extends NyPage<HotelBookingPage> {
  @override
  get init => () {
    // Access the path parameter
    final hotelId = queryParameters()["id"]; // Returns "87" for URL ../hotel/87/booking
    print("Loading hotel ID: $hotelId");
    
    // Use the ID to fetch hotel data or perform operations
  };
  
  // Rest of your page implementation
}
URL Format
https://yourdomain.com/hotel/87/booking
Programmatic Navigation
// Navigate with parameters
routeTo(HotelBookingPage.path.withParams({"id": "87"}), queryParameters: {
              "bookings": "active",
            });
Query Parameters
For optional parameters or when multiple dynamic values are needed:

URL Format
https://yourdomain.com/profile?user=20&tab=posts
https://yourdomain.com/hotel/87/booking?checkIn=2025-04-10&nights=3
Accessing Query Parameters
class _ProfilePageState extends NyPage<ProfilePage> {
  @override
  get init => () {
    // Get all query parameters
    final params = queryParameters();
    
    // Access specific parameters
    final userId = params["user"];            // "20"
    final activeTab = params["tab"];          // "posts"
    
    // Alternative access method
    final params2 = widget.queryParameters();
    print(params2);                           // {"user": "20", "tab": "posts"}
  };
}
Programmatic Navigation with Query Parameters
// Navigate with query parameters
routeTo(ProfilePage.path.withQueryParams({"user": "20", "tab": "posts"}));

// Combine path and query parameters
routeTo(HotelBookingPage.path.withParams({"id": "87"}), queryParameters: {
              "checkIn": "2025-04-10",
              "nights": "3",
            });
Handling Deep Links
Testing Deep Links
For development and testing, you can simulate deep link activation using ADB (Android) or xcrun (iOS):

# Android
adb shell am start -a android.intent.action.VIEW -d "https://yourdomain.com/profile?user=20" com.yourcompany.yourapp

# iOS (Simulator)
xcrun simctl openurl booted "https://yourdomain.com/profile?user=20"
Debugging Tips
Print all parameters in your init method to verify correct parsing
Test different URL formats to ensure your app handles them correctly
Remember that query parameters are always received as strings, convert them to the appropriate type as needed
Common Patterns
Parameter Type Conversion
Since all URL parameters are passed as strings, you'll often need to convert them:

// Converting string parameters to appropriate types
final hotelId = int.parse(queryParameters()["id"] ?? "0");
final isAvailable = (queryParameters()["available"] ?? "false") == "true";
final checkInDate = DateTime.parse(queryParameters()["checkIn"] ?? "");
Optional Parameters
Handle cases where parameters might be missing:

final userId = queryParameters()["user"];
if (userId != null) {
  // Load specific user profile
} else {
  // Load current user profile
}

// Or check hasQueryParameter
if (hasQueryParameter('status')) {
  // Do something with the status parameter
} else {
  // Handle absence of the parameter
}

Basics
Localization

Introduction
Adding localized files
Basics
Localizing text
Arguments
Updating the locale
Setting a default locale

Introduction
Localizing our projects provides us with an easy way to change the language for users in different countries.

If your app's primary Locale was en (English) but you also wanted to provide users in Spain with a Spanish version, localising the app would be your best option.

Here's an example to localize text in your app using Nylo.

Example of an localized file: lang/en.json
{
  "documentation": "documentation",
  "changelog": "changelog"
}
Example widget
...
ListView(
  children: [
    Text(
      "documentation".tr()
    ),
    // ... or
    Text(
      trans("documentation")
    )
  ]
)
The above will display the text from the lang/en.json file. If you support more than one locale, add another file like lang/es.json and copy the keys but change the values to match the locale. Here's an example.

Example of a English localized file: lang/en.json
{
  "documentation": "documentation",
  "changelog": "changelog"
}
Example of a Spanish localized file: lang/es.json
{
  "documentation": "documentación",
  "changelog": "registro de cambios"
}

Adding Localized files
Add all your localization files to the lang/ directory. Inside here, you'll be able to include your different locales. E.g. es.json for Spanish or pt.json for Portuguese.

Example: lang/en.json
{
  "documentation": "documentation",
  "changelog": "changelog",
  "intros": {
    "hello": "hello {{first_name}}",
  }
}
Example: lang/es.json
{
  "documentation": "documentación",
  "changelog": "registro de cambios",
  "intros": {
    "hello": "hola {{first_name}}",
  }
}
Once you’ve added the .json files, you’ll need to include them within your pubspec.yaml file.

Go to your pubspec.yaml file and then at the assets section, add the new files.

You can include as many locale files here but make sure you also include them within your pubspec.yaml assets.


Localizing text
You can localize any text with a key from your lang .json file.

"documentation".tr()
// or
trans("documentation");
You can also use nested keys in the json file. Here's an example below.

Example: lang/en.json
{
  "changelog": "changelog",
  "intros": {
    "hello": "hello"
  }
}
Example: lang/es.json
{
  "changelog": "registro de cambios",
  "intros": {
    "hello": "hola"    
  }
}
Example using nested JSON keys
"intros.hello".tr()
// or
trans("intros.hello");

Arguments
You can supply arguments to fill in values for your keys. In the below example, we have a key named "intros.hello_name". It has one fillable value named "first_name" to fill this value, pass a value to the method below.

Example: lang/en.json
{
  "changelog": "changelog",
  "intros": {
    "hello_name": "hello {{first_name}}",
  }
}
Example: lang/es.json
{
  "changelog": "registro de cambios",
  "intros": {
    "hello_name": "hola {{first_name}}"
  }
}
Example to fill arguments in your JSON file.

"intros.hello_name".tr(arguments: {"first_name": "Anthony"}) // Hello Anthony
// or
trans("intros.hello_name", arguments: {"first_name": "Anthony"}); // Hello Anthony

Updating the locale
Updating the locale in the app is simple in Nylo, you can use the below method in your widget.

String language = 'es'; // country code must match your json file e.g. pt.json would be 'pt

await NyLocalization.instance.setLanguage(context, language: language); // Switches language
This will update the locale to Spanish.

If your widget extends the NyState class, you can set the locale by calling the changeLanguage helper.

Example below.

class _MyHomePageState extends NyPage<MyHomePage> {
...
  InkWell(
    child: Text("Switch to Spanish"), 
    onTap: () async {
      await changeLanguage('es');
    },
  )
This is useful if you need to provide users with a menu to select a language to use in the app. E.g. if they navigated to a settings screen with language flags and selected Spanish.


Setting a default locale
You may want to update the default locale when users open your app for the first time, follow the steps below to see how.

First, open the .env file.
Next, update the DEFAULT_LOCALE property to your Locale, like the below example.
DEFAULT_LOCALE="es" 

Basics
Controllers

Introduction
Creating pages and controllers
Using controllers
Singleton Controller

Introduction
Before starting, let's go over what a controller is for those new.

Here's a quick summary from tutorialspoint.com.

The Controller is responsible for controlling the application logic and acts as the coordinator between the View and the Model. The Controller receives an input from the users via the View, then processes the user's data with the help of Model and passes the results back to the View.


Controller with services

...
class HomeController extends Controller {

  AnalyticsService analyticsService;
  NotificationService notificationService;

  @override
  construct(BuildContext context) {
    // example services
    analyticsService = AnalyticsService();
    notificationService = NotificationService();
  }

  bool sendMessage(String message) async {
    bool success = await this.notificationService.sendMessage(message);
    if (success == false) {
      this.analyticsService.sendError("failed to send message");
    }
    return success;
  }

  onTapDocumentation() {
    launch("https://nylo.dev/docs");
  }

  ...

class _MyHomePageState extends NyState<MyHomePage> {
  ...
  MaterialButton(
    child: Text("Documentation"),
    onPressed: widget.controller.onTapDocumentation, // call the action
  ),
If your widget has a controller, you can use widget.controller to access its properties.

You can use dart run nylo_framework:main make:page account --controller command to create a new page and controller automatically for you.


Creating pages and controllers
You can use the Metro CLI tool to create your pages & controllers automatically.

dart run nylo_framework:main make:page dashboard_page --controller
// or
dart run nylo_framework:main make:page dashboard_page -c
This will create a new controller in your app/controllers directory and a page in your resources/pages directory.

Or you can create a single controller using the below command.

dart run nylo_framework:main make:controller profile_controller
Retrieving arguments from routes
If you need to pass data from one widget to another, you can send the data using Navigator class or use the routeTo helper.

// Send an object to another page
User user = new User();
user.firstName = 'Anthony';

routeTo(ProfilePage.path, data: user);
When we navigate to the 'Profile' page, we can call data() to get the data from the previous page.

...
class _ProfilePageState extends NyPage<ProfilePage> {
  
  @override
  get init => () async {
    User user = data(); // data passed from previous page

    print(user.firstName); // Anthony
  };
The routeTo(String routeName, data: dynamic) data parameter accepts dynamic types so you can cast the object after it’s returned.


Using controllers
In your page, you can access the controller using widget.controller.

Your controller must added to the NyStatefulWidget class like in the below example:

NyStatefulWidget<HomeController>

import 'package:nylo_framework/nylo_framework.dart';
import '/app/controllers/my_controller.dart';

class HomePage extends NyStatefulWidget<HomeController> {
  
  static RouteView path = ("/home", (_) => HomePage());

  HomePage() : super(child: () => _HomePageState());
}

class _HomePageState extends NyPage<HomePage> {
    
    // init - called when the page is created
    get init => () async {
        // access the controller
        widget.controller.data(); // data passed from a previous page
        widget.controller.queryParameters(); // query parameters passed from a previous page
    };

    @override
    Widget view(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text("My Page"),
            ),
            body: Column(
                children: [
                    Text("My Page").onTap(() {
                        // call an action from that controller
                        widget.controller.doSomething();
                    }),
                    TextField(
                        controller: widget.controller.myController, 
                        // access the controller's properties
                    ),
                ],
            )
        );
    }
}
Controller Decoders
In Nylo your project will contain a config/decoders.dart file.

Inside this file there is a variable named controllers which is a map of all your controllers.

import 'package:nylo_framework/nylo_framework.dart';
...

final Map<Type, BaseController> controllers = {
  HomeController: () => HomeController(),

  MyNewController: () => MyNewController(), // new controller
  // ...
};

Singleton controller
You can use the singleton property in your controller to make it a singleton.

import 'package:nylo_framework/nylo_framework.dart';

class HomeController extends Controller {

  @override
  bool get singleton => true;

  ...
This will make sure that the controller is only created once and will be reused throughout the app.

Basics
App Icons

Introduction
Generating app icons
Adding your app icon
App icon filename
App icon filetype
Configuration
Badge Count

Introduction
You can build all your app icons using dart run flutter_launcher_icons:main from the command line. This will take your current app icon in /public/assets/app_icon/ and auto-generate all your iOS and Android icons.

Your app icon should be a .png with the size dimensions of 1024x1024px

If you have custom icons for different operating systems you can also just add them manually.

Nylo uses the flutter_launcher_icons library to build icons, to understand the library more you can check out their documentation too.


Generating app icons
You can run the below command from the terminal to auto-generate your app icons.

dart run flutter_launcher_icons:main
This command will use the app icon located in your /public/assets/app_icon directory to make the IOS and Android app icons to the correct dimensions.


Adding your app icon
You can place your 'app icon' inside the /public/assets/app_icon directory.

Make your icon filesize is 1024x1024 for the best results.

Once you’ve added your app icon, you’ll then need to update the image_path if your filename is different to the default Nylo app icon name.

Open your pubspec.yaml file and look for image_path section, this is where you can update the image path for the file. Make sure that the “image_path” matches the location for your new app icon.


App icon filenames
Your filenames shouldn’t include special characters. It’s best to keep it simple, like “app_icon.jpg” or “icon.png”.


App icon file types
The App Icon needs to be a .png type.

App icon attributes.

Attribute	Value
Format	png
Size	1024x1024px
Layers	Flattened with no transparency
If you are interested in learning more, you can view the official guidelines from both Google and Apple.

Apple’s human interface guideline is here
Google’s icon design specifications are here

Configuration
You can also modify the settings when generating your app icons. Inside the pubspec.yaml file, look for the flutter_icons section, and here you can make changes to the configuration.

Check out the official flutter_launcher_icons library to see what's possible.


Badge Count
You can also add a badge count to your app icon.

To set the badge count, use the below code snippet.

setBadgeNumber(5);
This will set the badge count to 5.

To remove the badge count, use the below code snippet.

clearBadgeNumber();

Basics
Validation

Introduction
Basics
Validating Data
Multiple Validation Rules
Validating Text Fields
Validation checks
Validation Rules
Creating Custom Validation Rules

Introduction
In Nylo, you can handle validating data using the validate helper.

It contains some useful validation rules you can use in your project.

If you need to add custom validation rules, you can do that too. In this section, we'll give an overview of how validation works in Nylo.


Validating Data
In your project, you will often need to validate data. For example, you may need to validate a user's email address or phone number when they sign up to your app.

You can use the validate helper to validate data.

class _ExampleState extends NyPage<ExamplePage> {
  ...

  handleFormSuccess() {
    String textFieldPass = 'agordon@web.com';

    validate(rules: {
      "email address": [textFieldPass, "email"]
    }, onSuccess: () {
      print('looks good');
      // do something...
    });
    
    // or like this
    
    validate(rules: {
      "email address": "email" // validation rule 'email'
    }, data: {
      "email address": textFieldPass
    }, onSuccess: () {
      print('looks good');
      // do something...
    });
  }
}
When the validation passes, the onSuccess callback will be called.

If the validation fails, the onFailure callback will be called.

class _ExampleState extends NyPage<ExamplePage> {
  ...
   handleFormFail() {
    String textFieldFail = 'agordon.dodgy.data';

    validate(rules: {
      "email address": [textFieldFail, "email"]
    }, onSuccess: () {
      // onSuccess would not be called
      print("success...");
    }, onFailure: (Exception exception) {
      /// handle the validation error
      print("failed validation");
    }, showAlert: false);
  }
When the validation fails, a toast notification will be displayed to the user. You can override this by setting the showAlert parameter to false.

Example using the phone_number_uk validation rule

class _ExampleState extends NyPage<ExamplePage> {
  TextEditingController _textFieldController = TextEditingController();
  ...

  handleForm() {
    String textFieldValue = _textFieldController.text;

    validate(rules: {
      "phone number": [textFieldValue, "phone_number_uk"] // validation rule 'phone_number_uk'
    }, onSuccess: () {
      print('looks good');
      // do something...
    });
  }
}
Example using the contains validation rule

class _ExampleState extends NyPage<ExamplePage> {
  ...

  handleForm() {
    String carModel = 'ferrari';

    validate(rules: {
      "car model": [carModel, "contains:lamborghini,ferrari"] // validation rule 'contains'
    }, onSuccess: () {
      print("Success! It's a ferrari or lamborghini");
      // do something...
    }, onFailure: (Exception exception) {
        print('No match found');
    });
  }
}
Options:

validate(
  rules: {
  "email address": "email|max:10" // checks data is an email and maximum of 10 characters
  }, data: {
    "email address": textEmail // data to be validated
  }, message: {
    "email address": "oops|it failed" // first section is title, then add a " | " and then provide the description
  },
  showAlert: true, // if you want Nylo to display the alert, default : true
  alertStyle: ToastNotificationStyleType.DANGER // choose from SUCCESS, INFO, WARNING and DANGER
);
This method is handy if you want to quickly validate the user's data and display some feedback to the user.


Multiple Validation Rules
You can pass multiple validation rules into the validate helper.

validate(rules: {
  "email address": ["john.mail@gmail.com" "email|max:10"] 
  // checks data is an email and maximum of 10 characters
}, onSuccess: () { 
    print("Success! It's a valid email and maximum of 10 characters");
});
You can also pass multiple validation rules into the validate helper like this:

validate(rules: {
  "email address": ["anthony@mail.com", "email|max:10|lowercase"], 
  // checks data is an email, lowercased and maximum of 10 characters
  "phone number": ["123456", "phone_number_uk"] 
  // checks data is a UK phone number
}, onSuccess: () { 
    print("Success! It's a valid email, lowercased and maximum of 10 characters");
}, onFailure: (Exception exception) {
    print('No match found');
});

Validating Text Fields
You can validate Text Fields by using the NyTextField widget.

Use the validationRules parameter to pass your validation rules into the TextField.

NyTextField(
  controller: _textEditingController, 
  validationRules: "not_empty|postcode_uk"
)

Validation checks
If you need to perform a validation check on data, you can use the NyValidator.isSuccessful() helper.

String helloWorld = "HELLO WORLD";

bool isSuccessful = NyValidator.isSuccessful(
    rules: {
        "Test": [helloWorld, "uppercase|max:12"]
    }
);

if (isSuccessful) {
    print("Success! It's a valid");
}
This will return a boolean value. If the validation passes, it will return true and false if it fails.


Validation Rules
Here are the available validation rules that you can use in Nylo.

Rule Name	Usage	Info
Email	email	Checks if the data is a valid email
Contains	contains:jeff,cup,example	Checks if the data contains a value
URL	url	Checks if the data is a valid url
Boolean	boolean	Checks if the data is a valid boolean
Min	min:5	Checks if the data is a minimum of x characters
Max	max:11	Checks if the data is a maximum of x characters
Not empty	not_empty	Checks if the data is not empty
Regex	r'regex:([0-9]+)'	Checks if the data matches a regex pattern
Numeric	numeric	Checks if the data is numeric
Date	date	Checks if the data is a date
Capitalized	capitalized	Checks if the data is capitalized
Lowercase	lowercase	Checks if the data is lowercase
Uppercase	uppercase	Checks if the data is uppercase
US Phone Number	phone_number_us	Checks if the data is a valid phone US phone number
UK Phone Number	phone_number_uk	Checks if the data is a valid phone UK phone number
US Zipcode	zipcode_us	Checks if the data is a valid zipcode for the US
UK Postcode	postcode_uk	Checks if the data is a valid postcode for the UK
Date age is younger	date_age_is_younger:18	Checks if the date is younger than a age
Date age is older	date_age_is_older:30	Checks if the date is older than a age
Date in past	date_in_past	Check if a date is in the past
Date in future	date_in_future	Check if a date is in the future
Is True	is_true	Checks if a value is true
Is False	is_false	Checks if a value is false
Password v1	password_v1	Checks for a password that contains:
- At least one upper case letter
- At least one digit
- Minimum of 8 characters
Password v2	password_v2	Checks for a password that contains:
- At least one upper case letter
- At least one digit
- Minimum of 8 characters
- At least one special character

email
This allows you to validate if the input is an email.

Usage: email

String email = "agordon@mail.com";

validate(rules: {
  "Email": [email, "email"]
}, onSuccess: () {
    print("Success! The input is an email");
});

boolean
This allows you to validate if the input is a boolean.

Usage: boolean

bool isTrue = true;

validate(rules: {
  "Is True": [isTrue, "boolean"]
}, onSuccess: () {
    print("Success! The input is a boolean");
});

contains
Check if the input contains a particular value.

Usage: contains:dog,cat

String favouriteAnimal = "dog";
validate(rules: {
  "Favourite Animal": [favouriteAnimal, "contains:dog,cat"]
}, onSuccess: () {
    print("Success! The input contains dog or cat");
});

url
Check if the input is a URL.

Usage: url

String url = "https://www.google.com";
validate(rules: {
  "Website": [url, "url"]
}, onSuccess: () {
    print("Success! The URL is valid");
});

min
Check if the input is a minimum of characters.

Usage: min:7 - will fail if the user's input is less than 7 characters.

// String
String password = "Password1";
validate(rules: {
  "Password": [password, "min:3"]
}, onSuccess: () {
    print("Success! The password is more than 3 characters");
});

// List
List<String> favouriteCountries = ['Spain', 'USA', 'Canada'];
validate(rules: {
  "Favourite Countries": [favouriteCountries, "min:2"]
}, onSuccess: () {
    print("Success! You have more than 2 favourite countries");
});

// Integer/Double
int age = 21;
validate(rules: {
  "Age": [age, "min:18"]
}, onSuccess: () {
    print("Success! You are more than 18 years old");
});

max
Check if the input is a maximum of characters.

Usage: max:10 - will fail if the user's input is more than 10 characters.

// String
String password = "Password1";
validate(rules: {
  "Password": [password, "max:10"]
}, onSuccess: () {
    print("Success! The password is less than 10 characters");
});

// List
List<String> favouriteCountries = ['Spain', 'USA', 'Canada'];
validate(rules: {
  "Favourite Countries": [favouriteCountries, "max:4"]
}, onSuccess: () {
    print("Success! You have less than 4 favourite countries");
});

// Integer/Double
int age = 18;
validate(rules: {
  "Age": [age, "max:21"]
}, onSuccess: () {
    print("Success! You are less than 18 years old");
});

Not Empty
Check if the input is not empty.

Usage: not_empty - will fail if the user's input is empty.

String score = "10";
validate(rules: {
  "Score": [score, "not_empty"]
}, onSuccess: () {
    print("Success! The input is not empty");
});

Regex
Check the input against a regex pattern.

Usage: r'regex:([0-9]+)' - will fail if the user's input does not match the regex pattern.

String password = "Password1!";
validate(rules: {
  "Password": [password, r'regex:^(?=.*\d)(?=.*[A-Z])(?=.*[a-z])(?=.*[^\w\d\s:])([^\s]){8,16}$']
}, onSuccess: () {
    print("Success! The password is valid");   
});

numeric
Check if the input is a numeric match.

Usage: numeric - will fail if the user's input is not numeric.

String age = '18';
validate(rules: {
  "Age": [age, "numeric"]
}, onSuccess: () {
    print("Success! The age is a number");
});

date
Check if the input is a date, e.g. 2020-02-29.

Usage: date - will fail if the user's input is not date.

// String
String birthday = '1990-01-01';
validate(rules: {
  "Birthday": [birthday, "date"]
}, onSuccess: () {
    print("Success! The birthday is a valid date");
});

// DateTime
DateTime birthday = DateTime(1990, 1, 1);
validate(rules: {
  "Birthday": [birthday, "date"]
}, onSuccess: () {
    print("Success! The birthday is a valid date");
});

capitalized
Check if the input is capitalized, e.g. "Hello world".

Usage: capitalized - will fail if the user's input is not capitalized.

String helloWorld = "Hello world";
validate(rules: {
  "Hello World": [helloWorld, "capitalized"]
}, onSuccess: () {
    print("Success! The input is capitalized");
});

lowercase
Check if the input is lowercase, e.g. "hello world".

Usage: lowercase - will fail if the user's input is not lowercased.

String helloWorld = "hello world";
validate(rules: {
  "Hello World": [helloWorld, "lowercase"]
}, onSuccess: () {
    print("Success! The input is lowercase");
});

uppercase
Check if the input is uppercase, e.g. "HELLO WORLD".

Usage: uppercase - will fail if the user's input is not uppercase.

String helloWorld = "HELLO WORLD";
validate(rules: {
  "Hello World": [helloWorld, "uppercase"]
}, onSuccess: () {
    print("Success! The input is uppercase");
});

US Phone Number
Check if the input is a valid US Phone Number, e.g. "123-456-7890".

Usage: phone_number_us - will fail if the user's input is not a US phone number.

String phoneNumber = '123-456-7890';
validate(rules: {
  "Phone Number": [phoneNumber, "phone_number_us"]
}, onSuccess: () {
    print("Success! The phone number is a valid format");
});

UK Phone Number
Check if the input is a valid UK Phone Number, e.g. "07123456789".

Usage: phone_number_uk - will fail if the user's input is not a UK phone number.

String phoneNumber = '07123456789';
validate(rules: {
  "Phone Number": [phoneNumber, "phone_number_uk"]
}, onSuccess: () {
    print("Success! The phone number is a valid format");
});

US Zipcode
Check if the input is a valid US Zipcode, e.g. "33125".

Usage: zipcode_us - will fail if the user's input is not a US Zipcode.

String zipcode = '33120';
validate(rules: {
  "Zipcode": [zipcode, "zipcode_us"]
}, onSuccess: () {
    print("Success! The zipcode is valid");
});

UK Postcode
Check if the input is a valid UK Postcode, e.g. "B3 1JJ".

Usage: postcode_uk - will fail if the user's input is not a UK Postcode.

String postcode = 'B3 1JJ';
validate(rules: {
  "Postcode": [postcode, "postcode_uk"]
}, onSuccess: () {
    print("Success! The postcode is valid");
});

Date age is younger
Check if the input is a date and is younger than a certain age, e.g. "18".

Usage: date_age_is_younger:21 - will fail if the user's input is not a date and is younger than 21.

You can validate against a DateTime or a String

// DateTime
DateTime userBithday = DateTime(2000, 1, 1);
validate(rules: {
  "Birthday": [userBithday, "date_age_is_older:30"]
}, onSuccess: () {
  print("Success! You're younger than 30");
}, onFailure: (Exception exception) {
  print('You are not younger than 30');
});

// String
String userBithday = '2000-01-01';
validate(rules: {
  "Birthday": [userBithday, "date_age_is_older:30"]
}, onSuccess: () {
  print("Success! You're younger than 30");
}, onFailure: (Exception exception) {
  print('You are not younger than 30');
});

Date age is older
Check if the input is a date and is older than a certain age, e.g. "18".

Usage: date_age_is_older:40 - will fail if the user's input is not a date and is older than 40.

You can validate against a DateTime or a String

// DateTime
DateTime userBithday = DateTime(2000, 1, 1);
validate(rules: {
  "Birthday": [userBithday, "date_age_is_older:18"]
}, onSuccess: () {
  print("Success! You're older than 18");
}, onFailure: (Exception exception) {
  print('You are not older than 18');
});

// String
String userBithday = '2000-01-01';
validate(rules: {
  "Birthday": [userBithday, "date_age_is_older:18"]
}, onSuccess: () {
  print("Success! You're older than 18");
}, onFailure: (Exception exception) {
  print('You are not older than 18');
});

Date in past
Check if the input is a date and is in the past.

Usage: date_in_past - will fail if the user's input is not a date and is in the past.

// String
String birthday = '1990-01-01';
validate(rules: {
  "Birthday": [birthday, "date_in_past"]
}, onSuccess: () {
    print("Success! The birthday is in the past");
});

// DateTime
DateTime birthday = DateTime(2030, 1, 1);
validate(rules: {
  "Coupon Date": [birthday, "date_in_past"]
}, onSuccess: () {
    print("Success! The birthday is in the past");
});

Date in future
Check if the input is a date and is in the future.

Usage: date_in_future - will fail if the user's input is not a date and is in the future.

// String
String couponDate = '2030-01-01';
validate(rules: {
  "Coupon Date": [couponDate, "date_in_future"]
}, onSuccess: () {
    print("Success! The coupon date is in the future");
});

// DateTime
DateTime couponDate = DateTime(2030, 1, 1);
validate(rules: {
  "Coupon Date": [couponDate, "date_in_future"]
}, onSuccess: () {
    print("Success! The coupon date is in the future");
});

Is True
Check if the input is true.

Usage: is_true - will fail if the user's input is not true.

bool hasAgreedToTerms = true;
validate(rules: {
  "Terms of service": [hasAgreedToTerms, "is_true"]
}, onSuccess: () {
    print("Success! You have agreed to the terms of service");
});

Is False
Check if the input is false.

Usage: is_false - will fail if the user's input is not false.

bool hasNotifications = false;

validate(rules: {
  "Phone Compatible": [hasNotifications, "is_false"]
}, onSuccess: () {
    // handle the success case
});


Password v1
Checks for a password that contains:
- At least one upper case letter
- At least one digit
- Minimum of 8 characters

Usage: password_v1 - will fail if the user's input is not a valid password.

String password = "PrintUp1";
validate(rules: {
  "Password": [password, "password_v1"]
}, onSuccess: () {
    print("Success! The password is valid");
});


Password v2
Checks for a password that contains:
- At least one upper case letter
- At least one digit
- Minimum of 8 characters
- At least one special character

Usage: password_v2 - will fail if the user's input is not a valid password.

String password = "BlueTab1e!";
validate(rules: {
  "Password": [password, "password_v2"]
}, onSuccess: () {
    print("Success! The password is valid");
});

Custom Validation Rules
You can add custom validation rules for your project by opening the config/valdiation_rules.dart file.

The validationRules variable contains all your custom validation rules.

final Map<String, dynamic> validationRules = {
  /// Example
  // "simple_password": (attribute) => SimplePassword(attribute)
};
To define a new validation rule, first create a new class that extends the ValidationRule class. Your validation class should implement the handle method like in the below example.

class SimplePassword extends ValidationRule {
  SimplePassword(String attribute)
      : super(
      attribute: attribute,
      signature: "simple_password", // Signature for the validator
      description: "The $attribute field must be between 4 and 8 digits long and include at least one numeric digit", // Toast description when an error occurs
      textFieldMessage: "Must be between 4 and 8 digits long with one numeric digit"); // TextField validator description when an error occurs

  @override
  handle(Map<String, dynamic> info) {
    super.handle(info);

    RegExp regExp = RegExp(r'^(?=.*\d).{4,8}$');
    return regExp.hasMatch(info['data']);
  }
}
The Map<String, dynamic> info object:

/// info['rule'] = Validation rule i.e "max:12".
/// info['data'] = Data the user has passed into the validation rule.
The handle method expects a boolean return type, if the data passes validation return true and false if it doesn't.

Basics
Authentication

Introduction
Basics
Adding an auth user
Retrieve an auth user
Logout an auth user
Checking if a user is authenticated
Authentication page

Introduction
In Nylo, you can use the built-in helpers to make Authentication a breeze.

To authenticate a user, run the below command.

await Auth.authenticate();
If you'd like to add data, use the 'data' parameter.

await Auth.authenticate(data: {"token_id": "ey2sdm..."});
To retrieve the authenticated user's data, run the below.

Map user = await Auth.data();

print(user); // {token_id: ey2sdm...}
Let's imagine the below scenario.

A user registers using an email and password.
After registering, you create the user a session token.
We now want to store the session token on the user's device for future use.
_login(String email, String password) async {
  // 1 - Example register via an API Service
  User? user = await api<AuthApiService>((request) => request.registerUser(
    email: email, 
    password: password
 ));

  // 2 - Returns the users session token
  print(user?.token); // ey2sdm...

  // 3 - Save the user to Nylo
  await Auth.authenticate(data: {"token_id": user?.token});
}
Now the User will be authenticated and the data will be stored on their device.


Adding an auth user
When a user logs in to your application, you can add them using the Auth.authenticate() helper.

_login() async {
  ...

  await Auth.authenticate(data: {"token_id": "ey2sdm..."});
} 

Retrieve an auth user's data
If a user is logged into your app, you can retrieve the user's data by calling Auth.data().

_getUser() async {
  dynamic userData = await Auth.data();

  print(userData); // {token_id: ey2sdm...}
}

Logout an auth user
When a user logs out of your application, you can remove them using the Auth.logout() helper.

_logout() async {

  await Auth.logout();
}
Now, the user is logged out of the app and the authentication page won't show when they next visit the app.


Checking if a user is authenticated
You can check if a user is authenticated by calling the Auth.isAuthenticated() helper.

_isAuthenticated() async {
  bool isAuthenticated = await Auth.isAuthenticated();

  print(isAuthenticated); // true
}

Authentication Page
Once your user is stored using the Auth.authenticate(user) helper. You'll be able to set an 'authentication page', this will be used as the initial page the user sees when they open the app.

Go to your routes/router.dart file and use the authenticatedRoute function.

appRouter() => nyRoutes((router) {

  router.add(HomePage.path).initialRoute(); // initial route

  router.add(ProfilePage.path).authenticatedRoute(); // authenticated route
});
Now, when the app boots, it will use the authenticated page instead of the default route.

Basics
Logging

Introduction
Log Levels
Helpers

Introduction
To print information to the console, you can use one of the following:

printInfo(dynamic message)
printDebug(dynamic message)
printError(dynamic message)
The above helpers will only print to the console if the APP_DEBUG variable in your .env file is set to true.

// .env
APP_DEBUG=true
This is useful when you want to print information to the console during development, but not in production.

Here's an example using the helpers:

import 'package:nylo_framework/nylo_framework.dart';
...

String name = 'Anthony';
String city = 'London';
int age = 18;

printInfo(name); // [info] Anthony
printDebug(age); // [debug] 18
printError(city); // [error] London
You can also use the dump helper to print data to the console.

String city = 'London';
int age = 18;

age.dump(); // 18

dump(city); // London
Why use NyLogger?
NyLogger may appear similar to print in Flutter, however, there's more to it.

If your application's .env variable APP_DEBUG is set to false, NyLogger will not print to the console.

In some scenarios you may still want to print while your application's APP_DEBUG is false, the showNextLog helper can be used for that.

// .env
APP_DEBUG=false

// usage for showNextLog
String name = 'Anthony';
String country = 'UK';
List<String> favouriteCountries = ['Spain', 'USA', 'Canada'];

printInfo(name); // Will not print
printInfo(country); // Will not print

showNextLog();
printInfo(country); // UK

printDebug(favouriteCountries); // Will not print

Log Levels
You can use the following log levels:

[info] - printInfo(dynamic message)
[debug] - printDebug(dynamic message)
[error] - printError(dynamic message)

Helpers
You can print data easily using the dump or dd extension helpers. They can be called from your objects, like in the below example.

String project = 'Nylo';
List<String> seasons = ['Spring', 'Summer', 'Fall', 'Winter'];

project.dump(); // 'Nylo'
seasons.dump(); // ['Spring', 'Summer', 'Fall', 'Winter']

String code = 'Dart';

code.dd(); // Prints: 'Dart' and exits the code

Basics
Forms

Introduction
How it works
Creating Forms
Field Types
Text Fields
Numeric Fields
Selection Fields
Boolean Fields
Date and Time Fields
Password Fields
Masked Input Fields
Checkbox Fields
Picker Fields
Radio Fields
Chip Fields
Switch Box Fields
Form Validation
Form Casts
Managing Form Data
Initializing Data
Submit Button
Form Styling
Advanced Features
Form Layout
Conditional Fields
Form Events
Pre-built Components
API Reference for NyForm

Introduction
Nylo's form system provides:

Easy form creation and management
Built-in validation
Field type casting
Form state management
Styling customization
Data handling utilities

Creating a form
First, run the below metro command from your terminal.

dart run nylo_framework:main make:form LoginForm
# or with Metro alias
metro make:form LoginForm
This will create a new form class lib/app/forms/login_form.dart

E.g. The newly created LoginForm

import 'package:nylo_framework/nylo_framework.dart';

class LoginForm extends NyFormData {

  LoginForm({String? name}) : super(name ?? "login");

  // Add your fields here
  @override
  fields() => [
    Field.email("Email", 
        validator: FormValidator.email()
    ),
    Field.password("Password",
        validator: FormValidator.password()
    ),
  ];
}
Displaying a form
To display a form, you can use the NyForm widget.

import 'package:nylo_framework/nylo_framework.dart';
import '/app/forms/login_form.dart';
import '/resources/widgets/buttons/buttons.dart';
...

// Create your form
LoginForm form = LoginForm();

// add the form using the NyForm widget
@override
Widget view(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: NyForm(
        form: form, 
        footer: Button.primary(text: "Submit", submitForm: (form, (data) {
              printInfo(data);
          }),
        ),
      ),
    )
  );
}
This is all you need to create and display a form in Nylo.

The UI of this page will now contain two fields, Email and Password, and a submit button.

Using the Button widget to submit the form
Out the box, Nylo provides 8 pre-built buttons that you can use to submit a form.

Each button has a different style and color.

Button.primary
Button.secondary
Button.outlined
Button.textOnly
Button.icon
Button.gradient
Button.rounded
Button.transparency
They all have the ability to submit a form using the submitForm parameter.

Button.primary(text: "Submit", submitForm: (form, (data) {
    printInfo(data);
}));
Submitting the form via a different widget
To submit a form, you can call the submit method on a form.

LoginForm form = LoginForm();

@override
Widget view(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: NyForm(
            form: form, 
            footer: MaterialButton(
                onPressed: () {
                    form.submit(onSuccess: (data) {
                        // Do something with the data
                    });
                },
                child: Text("Submit"),
            )),
        )
    );
}
When you call form.submit(), Nylo will validate the form and if the form is valid, it will call the onSuccess callback with the form data.

That's a quick overview of how to create, display and submit a form in Nylo.

This is just scratching the surface, you can customize your forms even further by adding casts, validation rules, dummy data and global styles.


Creating Forms
Using the Metro CLI
The easiest way to create a new form is using the Metro CLI:

metro make:form LoginForm

# or
dart run nylo_framework:main make:form LoginForm
This creates a new form class in lib/app/forms/login_form.dart.

Form Structure
Forms in Nylo extend the NyFormData class:

class ProductForm extends NyFormData {
  ProductForm({String? name}) : super(name ?? "product");

  @override
  fields() => [
    // Define form fields here
    Field.text("Name"),
    Field.number("Price"),
    Field.textarea("Description")
  ];
}

Field Types
Nylo provides multiple ways to define fields, with the recommended approach using static methods for cleaner syntax:


Text Fields
// Recommended approach
Field.text("Name"),
Field.textArea("Description"),
Field.email("Email"),
Field.capitalizeWords("Title"),
Field.url("Website"),

// Alternative approach using constructor with casts
Field("Name", cast: FormCast.text()),
Field("Description", cast: FormCast.textArea())

Numeric Fields
// Recommended approach
Field.number("Age"),
Field.currency("Price", currency: "usd"),
Field.decimal("Score"),

// Alternative approach
Field("Age", cast: FormCast.number()),
Field("Price", cast: FormCast.currency("usd"))

Selection Fields
// Recommended approach
Field.picker("Category", options: ["Electronics", "Clothing", "Books"]),
Field.chips("Tags", options: ["Featured", "Sale", "New"]),
Field.radio("Size", options: ["Small", "Medium", "Large"]),

// Alternative approach
Field("Category", 
  cast: FormCast.picker(
    options: ["Electronics", "Clothing", "Books"]
  )
)

Boolean Fields
// Recommended approach
Field.checkbox("Accept Terms"),
Field.switchBox("Enable Notifications"),

// Alternative approach
Field("Accept Terms", cast: FormCast.checkbox()),
Field("Enable Notifications", cast: FormCast.switchBox())

Date and Time Fields
// Recommended approach
Field.date("Birth Date", 
  firstDate: DateTime(1900),
  lastDate: DateTime.now()
),
Field.datetime("Appointment"),

// Alternative approach
Field("Birth Date", 
  cast: FormCast.date(
    firstDate: DateTime(1900),
    lastDate: DateTime.now()
  )
)

Password Fields
// Recommended approach
Field.password("Password", viewable: true)

// Alternative approach
Field("Password", cast: FormCast.password(viewable: true))

Masked Input Fields
// Recommended approach
Field.mask("Phone", mask: "(###) ###-####"),
Field.mask("Credit Card", mask: "#### #### #### ####")

// Alternative approach
Field("Phone", 
  cast: FormCast.mask(mask: "(###) ###-####")
)

Checkbox Fields
// Recommended approach
Field.checkbox("Accept Terms"),

// Alternative approach
Field("Accept Terms", cast: FormCast.checkbox())

Picker Fields
// Recommended approach
Field.picker("Category", options: ["Electronics", "Clothing", "Books"]),

// Alternative approach
Field("Category", 
  cast: FormCast.picker(
    options: ["Electronics", "Clothing", "Books"]
  )
)

Radio Fields
// Recommended approach
Field.radio("Size", options: ["Small", "Medium", "Large"]),

// Alternative approach
Field("Size", 
  cast: FormCast.radio(
    options: ["Small", "Medium", "Large"]
  )
)

Chip Fields
// Recommended approach
Field.chips("Tags", options: ["Featured", "Sale", "New"]),

// Alternative approach
Field("Tags", 
  cast: FormCast.chips(
    options: ["Featured", "Sale", "New"]
  )
)

Switch Box Fields
// Recommended approach
Field.switchBox("Enable Notifications"),

// Alternative approach
Field("Enable Notifications", cast: FormCast.switchBox())

Form Validation
Nylo provides extensive validation capabilities:

Basic Validation
Field.text("Username",
  validate: FormValidator()
    .notEmpty()
    .minLength(3)
    .maxLength(20)
)
Combined Validation
Field.password("Password",
  validate: FormValidator()
    .notEmpty()
    .minLength(8)
    .password(strength: 2)
)
Custom Validation
Field.number("Age",
  validate: FormValidator.custom(
    (value) {
      if (value < 18) return false;
      if (value > 100) return false;
      return true;
    },
    message: "Age must be between 18 and 100"
  )
)
Validation Examples
// Email validation
Field.email("Email", 
  validate: FormValidator.email(
    message: "Please enter a valid email address"
  )
)

// Password validation with strength levels
Field.password("Password",
  validate: FormValidator.password(strength: 2)
)

// Length validation
Field.text("Username", 
  validate: FormValidator()
    .minLength(3)
    .maxLength(20)
)

// Phone number validation
Field.phone("Phone",
  validate: FormValidator.phoneNumberUs()  // US format
  // or
  validate: FormValidator.phoneNumberUk()  // UK format
)

// URL validation
Field.url("Website",
  validate: FormValidator.url()
)

// Contains validation
Field.picker("Category",
  validate: FormValidator.contains(["Tech", "Health", "Sports"])
)

// Numeric validation
Field.number("Age",
  validate: FormValidator()
    .numeric()
    .minValue(18)
    .maxValue(100)
)

// Date validation
Field.date("EventDate",
  validate: FormValidator()
    .date()
    .dateInFuture()
)

// Boolean validation
Field.checkbox("Terms",
  validate: FormValidator.isTrue()
)

// Multiple validators
Field.text("Username",
  validate: FormValidator()
    .notEmpty()
    .minLength(3)
    .maxLength(20)
    .regex(r'^[a-zA-Z0-9_]+$')
)
Available Validators
Validator	Description
notEmpty()	Ensures field is not empty
email()	Validates email format
minLength(n)	Minimum length check
maxLength(n)	Maximum length check
numeric()	Numbers only
regex(pattern)	Custom regex pattern
contains(list)	Must contain value from list
dateInPast()	Date must be in past
dateInFuture()	Date must be in future
password(strength: 1|2)	Password strength validation
phoneNumberUs()	US phone format
phoneNumberUk()	UK phone format
url()	Valid URL format
zipcodeUs()	US zipcode format
postcodeUk()	UK postcode format
isTrue()	Must be true
isFalse()	Must be false
dateAgeIsYounger(age)	Age younger than specified
dateAgeIsOlder(age)	Age older than specified

Form Casts
Casts transform field input into specific formats:

Available Casts
Cast	Description	Example
FormCast.email()	Email input	user@example.com
FormCast.number()	Numeric input	42
FormCast.currency("usd")	Currency formatting	$42.99
FormCast.capitalizeWords()	Title case	Hello World
FormCast.date()	Date picker	2024-01-15
FormCast.mask()	Custom input mask	(123) 456-7890
FormCast.picker()	Selection list	-
FormCast.chips()	Multi-select chips	-
FormCast.checkbox()	Boolean checkbox	-
FormCast.switchBox()	Boolean switch	-
FormCast.textarea()	Multi-line text	-
FormCast.password()	Password input	-
Custom Casts
Create custom casts in config/form_casts.dart:

final Map<String, dynamic> formCasts = {
  "phone": (Field field, Function(dynamic value)? onChanged) {
    return CustomPhoneField(
      field: field,
      onChanged: onChanged
    );
  }
};

Managing Form Data
In this section, we'll cover how to manage form data in Nylo. Everything from setting initial data to updating and clearing form fields.


Setting Initial Data
NyForm(
  form: form,
  loadData: () async {
    final userData = await api<ApiService>((request) => request.getUserData());
    
    return {
      "name": userData?.name,
      "email": userData?.email
    };
  }
)

// or 
NyForm(
  form: form,
  initialData: {
    "name": "John Doe",
    "email": "john@example.com"
  }
)
You can also set initial data directly in the form class:

class EditAccountForm extends NyFormData {
  EditAccountForm({String? name}) : super(name ?? "edit_account");

  @override
  get init => () async {
    final userResource = await api<ApiService>((request) => request.getUserData());

    return {
      "first_name": userResource?.firstName,
      "last_name": userResource?.lastName,
      "phone_number": userResource?.phoneNumber,
    };
  };

  @override
  fields() => [
    Field.text("First Name"),
    Field.text("Last Name"),
    Field.number("Phone Number"),
  ];
}
Updating Data
// Update single field
form.setField("name", "Jane Doe");

// Update multiple fields
form.setData({
  "name": "Jane Doe",
  "email": "jane@example.com"
});
Clearing Data
// Clear everything
form.clear();

// Clear specific field
form.clearField("name");

Submit Button
In your Form class, you can define a submit button:

class UserInfoForm extends NyFormData {
  UserInfoForm({String? name}) : super(name ?? "user_info");

  @override
  fields() => [
        Field.text("First Name",
            style: "compact"
        ),
        Field.text("Last Name",
            style: "compact"
        ),
        Field.number("Phone Number",
            style: "compact"
        ),
      ];
  
  @override
  Widget? get submitButton => Button.primary(text: "Submit", 
                submitForm: (this, (data) {
                    printInfo(data);
                }));
}
The Button widget is a pre-built component that can be used to submit a form. All you need to do is pass the submitForm parameter to the button.

Out the box, Nylo provides 8 pre-built buttons that you can use to submit a form.

Button.primary
Button.secondary
Button.outlined
Button.textOnly
Button.icon
Button.gradient
Button.rounded
If you want to use a different widget to submit the form, you can call the submit method on the form:

class UserInfoForm extends NyFormData {
  UserInfoForm({String? name}) : super(name ?? "user_info");

  @override
  fields() => [
        Field.text("First Name",
            style: "compact"
        ),
        Field.text("Last Name",
            style: "compact"
        ),
        Field.number("Phone Number",
            style: "compact"
        ),
      ];
  
  @override
  Widget? get submitButton => ElevatedButton(
    onPressed: () {
      submit(onSuccess: (data) {
        printInfo(data);
      });
    },
    child: Text("Submit"),
  );
}
Lastly, you can also add a submit button directly to the form widget:

NyForm(
    form: form,
    footer: Button.primary(text: "Submit", submitForm: (form, (data) {
      printInfo(data);
    })),
)
Or with another widget:

NyForm(
  form: form,
  footer: MaterialButton(onPressed: () {
    form.submit(onSuccess: (data) {
      printInfo(data);
    });
  }, child: Text("Submit")),
)

Form Styling
Global Styles
Define global styles in app/forms/style/form_style.dart:

class FormStyle extends NyFormStyle {
  @override
  FormStyleTextField textField(BuildContext context, Field field) {
    return {
      'default': (NyTextField textField) => textField.copyWith(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
      'compact': (NyTextField textField) => textField.copyWith(
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4
          ),
        ),
      ),
    };
  }
}
Field-Level Styling
Using Style Extension
Field.email("Email",
  style: "compact".extend(
    labelText: "Email Address",
    prefixIcon: Icon(Icons.email),
    backgroundColor: Colors.grey[100],
    borderRadius: BorderRadius.circular(8),
    
    // Custom decoration states
    decoration: (data, inputDecoration) {
      return inputDecoration.copyWith(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue)
        )
      );
    },
    successDecoration: (data, inputDecoration) {
      return inputDecoration.copyWith(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green)
        )
      );
    },
    errorDecoration: (data, inputDecoration) {
      return inputDecoration.copyWith(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red)
        )
      );
    }
  )
)
Direct Styling
Field.text("Name",
  style: (NyTextField textField) => textField.copyWith(
    decoration: InputDecoration(
      prefixIcon: Icon(Icons.person),
      border: OutlineInputBorder(),
    ),
  ),
)

Advanced Features

Form Layout
fields() => [
  // Single field
  Field.text("Title"),
  
  // Grouped fields in row
  [
    Field.text("First Name"),
    Field.text("Last Name"),
  ],
  
  // Another single field
  Field.textarea("Bio")
];

Conditional Fields
Field.checkbox("Has Pets",
  onChange: (value) {
    if (value == true) {
      form.showField("Pet Names");
    } else {
      form.hideField("Pet Names");
    }
  }
)

Form Events
NyForm(
  form: form,
  onChanged: (field, data) {
    print("$field changed: $data");
  },
  validateOnFocusChange: true
)

Pre-built Components
Login Form
NyLoginForm loginForm = Forms.login(
  emailValidationMessage: "Please enter a valid email",
  passwordValidationMessage: "Password is required",
  style: "compact"
);

API Reference for NyForm
A widget that manages form state, validation, and submission in Nylo applications.

Constructor
NyForm({
  Key? key,
  required NyFormData form,
  double crossAxisSpacing = 10,
  double mainAxisSpacing = 10,
  Map<String, dynamic>? initialData,
  Function(String field, Map<String, dynamic> data)? onChanged,
  bool validateOnFocusChange = false,
  Widget? header,
  Widget? footer,
  Widget? loading,
  bool locked = false,
})
Parameters
Required Parameters
Parameter	Type	Description
form	NyFormData	The form to display and manage. Contains field definitions and validation rules.
Optional Parameters
Parameter	Type	Default	Description
key	Key?	null	Controls how one widget replaces another widget in the tree.
crossAxisSpacing	double	10	Spacing between fields in the cross axis direction.
mainAxisSpacing	double	10	Spacing between fields in the main axis direction.
initialData	Map<String, dynamic>?	null	Initial values for form fields. Keys should match field names.
onChanged	Function(String, Map<String, dynamic>)?	null	Callback when any field value changes. Provides field name and complete form data.
validateOnFocusChange	bool	false	Whether to validate fields when focus changes.
header	Widget?	null	Widget to display above the form fields.
footer	Widget?	null	Widget to display below the form fields.
loading	Widget?	null	Widget to display while the form is loading. Defaults to a skeleton loader if not provided.
locked	bool	false	When true, makes the form read-only and prevents user input.
Example Usage
NyForm(
  form: LoginForm(),
  initialData: {
    "email": "user@example.com",
    "password": ""
  },
  header: Text("Login"),
  footer: SubmitButton(),
  onChanged: (field, data) {
    print("Field $field changed. New data: $data");
  },
  validateOnFocusChange: true,
  crossAxisSpacing: 16,
  mainAxisSpacing: 20,
)
Notes
The form parameter automatically initializes with the provided initialData if any.
The loading widget is only shown when the form is in a loading state.
The onChanged callback provides both the changed field name and the complete form data.
When locked is true, the form becomes non-interactive but still displays values.
header and footer widgets are optional and will only be displayed if provided.

Basics
Cache

Introduction
Basics
Save Data with Expiration Time
Save Data Forever
Retrieve Data
Remove Data
Networking
Caching API Responses
API Methods
Methods

Introduction
Nylo provides a flexible cache driver out the box. You can store and retrieve items on the fly.

Caching is most useful when you need to store data that is expensive to generate or retrieve. For example, you can cache the result of an API request to avoid making the same request multiple times.

In this section we'll dive into the basics of caching in Nylo.


Save Data with Expiration Time
To store an item in the cache, you can use the saveRemember method. The method accepts three arguments: the key, the expiration time in seconds and the callback that returns the value to be stored.

import 'package:nylo_framework/nylo_framework.dart';
...

String key = "hello_world"; // Cache key
int seconds = 60; // 1 minute expiration

String val = await cache().saveRemember(key, seconds, () {
    printInfo("Cache miss");

    return "Hello World";
});

printInfo(val); // Hello World
In the example above, the saveRemember method will store the value "Hello World" in the cache under the key "hello_world" for 60 seconds. If the key already exists in the cache, the method will return the value stored in the cache.


Save Data Forever
To store an item in the cache indefinitely, you can use the saveForever method. The method accepts two arguments: the key and the callback that returns the value to be stored.

import 'package:nylo_framework/nylo_framework.dart';
...

String key = "hello_world"; // Cache key

String val = await cache().saveForever(key, () {
    printInfo("Cache miss");

    return "Hello World";
});

printInfo(val); // Hello World
In the example above, the saveForever method will store the value "Hello World" in the cache under the key "hello_world" indefinitely. If the key already exists in the cache, the method will return the value stored in the cache.


Retrieve Data
To retrieve an item from the cache, you can use the get method. The method accepts the key of the item to retrieve.

import 'package:nylo_framework/nylo_framework.dart';
...

String key = "hello_world"; // Cache key

String val = await cache().get(key);

printInfo(val); // Hello World
In the example above, the get method will return the value stored in the cache under the key "hello_world".


Remove Data
To remove an item from the cache, you can use the clear method. The method accepts the key of the item to remove.

import 'package:nylo_framework/nylo_framework.dart';
...

String key = "hello_world"; // Cache key

await cache().clear(key);
In the example above, the clear method will remove the item stored in the cache under the key "hello_world".


Caching API Responses
You can use the cache driver to cache API responses. This is useful when you want to avoid making the same request multiple times.

import 'package:nylo_framework/nylo_framework.dart';
...

Map<String, dynamic>? githubResponse = await api<ApiService>(
            (request) => request.get("https://api.github.com/repos/nylo-core/nylo"),
    cacheDuration: const Duration(seconds: 60),
    cacheKey: "github_nylo_dev",
);

printInfo(githubResponse);
In the example above, the api method will make a GET request to the GitHub API to fetch the repo data for nylo-dev. The response will be cached for 60 seconds under the key github_nylo_dev.

You can also cache the response in an ApiService when using the network method.

import 'package:nylo_framework/nylo_framework.dart';
...

class ApiService extends NyApiService {
  ...

  Future githubInfo() async {
    return await network(
      request: (request) => request.get("https://api.github.com/repos/nylo-core/nylo"),
      cacheKey: "github_nylo_info",
      cacheDuration: const Duration(hours: 1),
    );
  }
}
Then, use the githubInfo method to fetch the GitHub user profile.

import 'package:nylo_framework/nylo_framework.dart';
...

Map<String, dynamic>? githubResponse = await api<ApiService>((request) => request.githubInfo());

printInfo(githubResponse);
In the example above, the githubInfo method will fetch the user profile of the nylo-core user from the GitHub API. The response will be cached for 1 hour under the key github_nylo_info.


API Methods and Properties
Methods
saveRemember(String key, int seconds, Function callback): Save an item in the cache with an expiration time.
saveForever(String key, Function callback): Save an item in the cache indefinitely.
get(String key): Retrieve an item from the cache.
clear(String key): Remove an item from the cache.
flush(): Remove all items from the cache.
documents(): Retrieve all items from the cache.
has(String key): Check if an item exists in the cache.
put(String key, dynamic value, int seconds): Store an item in the cache with an expiration time.
size(): Retrieve the number of items in the cache.

Widgets
Themes & Styling

Introduction
Themes
Light & Dark themes
Creating a theme
Configuration
Theme colors
Using colors
Base styles
Switching theme
Fonts
Design
Text Extensions

Introduction
You can manage your application's UI styles using themes. Themes allow us to change i.e. the font size of text, how buttons appear and the general appearance of our application.

If you are new to themes, the examples on the Flutter website will help you get started here.

Out of the box, Nylo includes pre-configured themes for Light mode and Dark mode.

The theme will also update if the device enters 'light/dark' mode.


Light & Dark themes
Light theme - lib/resources/themes/light_theme.dart
Dark theme - lib/resources/themes/dark_theme.dart
Inside these files, you'll find the ThemeData and ThemeStyle pre-defined.


Creating a theme
If you want to have multiple themes for your app, we have an easy way for you to do this. If you're new to themes, follow along.

First, run the below command from the terminal

dart run nylo_framework:main make:theme bright_theme
# or with metro alias
metro make:theme bright_theme
Note: replace bright_theme with the name of your new theme.

This creates a new theme in your /resources/themes/ directory and also a theme colors file in /resources/themes/styles/.

// App Themes
final List<BaseThemeConfig<ColorStyles>> appThemes = [
  BaseThemeConfig<ColorStyles>(
    id: getEnv('LIGHT_THEME_ID'),
    description: "Light theme",
    theme: lightTheme,
    colors: LightThemeColors(),
  ),
  BaseThemeConfig<ColorStyles>(
    id: getEnv('DARK_THEME_ID'),
    description: "Dark theme",
    theme: darkTheme,
    colors: DarkThemeColors(),
  ),

  BaseThemeConfig<ColorStyles>( // new theme automatically added
    id: 'Bright Theme',
    description: "Bright Theme",
    theme: brightTheme,
    colors: BrightThemeColors(),
  ),
];
You can modify the colors for your new theme in the /resources/themes/styles/bright_theme_colors.dart file.


Theme Colors
To manage the theme colors in your project, check out the lib/resources/themes/styles directory. This directory contains the style colors for the light_theme_colors.dart and dark_theme_colors.dart.

In this file, you should have something similar to the below.

// e.g Light Theme colors
class LightThemeColors implements ColorStyles {
  // general
  @override
  Color get background => const Color(0xFFFFFFFF);

  @override
  Color get content => const Color(0xFF000000);
  @override
  Color get primaryAccent => const Color(0xFF0045a0);

  @override
  Color get surfaceBackground => Colors.white;
  @override
  Color get surfaceContent => Colors.black;

  // app bar
  @override
  Color get appBarBackground => Colors.blue;
  @override
  Color get appBarPrimaryContent => Colors.white;

  // buttons
  @override
  Color get buttonBackground => Colors.blue;
  @override
  Color get buttonContent => Colors.white;

  @override
  Color get buttonSecondaryBackground => const Color(0xff151925);
  @override
  Color get buttonSecondaryContent => Colors.white.withAlpha((255.0 * 0.9).round());

  // bottom tab bar
  @override
  Color get bottomTabBarBackground => Colors.white;

  // bottom tab bar - icons
  @override
  Color get bottomTabBarIconSelected => Colors.blue;
  @override
  Color get bottomTabBarIconUnselected => Colors.black54;

  // bottom tab bar - label
  @override
  Color get bottomTabBarLabelUnselected => Colors.black45;
  @override
  Color get bottomTabBarLabelSelected => Colors.black;

  // toast notification
  @override
  Color get toastNotificationBackground => Colors.white;
}

Using colors in widgets
import 'package:flutter_app/config/theme.dart';
...

// gets the light/dark background colour depending on the theme
ThemeColor.get(context).background

// e.g. of using the "ThemeColor" class
Text(
  "Hello World",
  style: TextStyle(
      color:  ThemeColor.get(context).content // Color - content
  ),
),

// or 

Text(
  "Hello World",
  style: TextStyle(
      color:  ThemeConfig.light().colors.content // Light theme colors - primary content
  ),
),

Base styles
Base styles allow you to customize various widget colors from one area in your code.

Nylo ships with pre-configured base styles for your project located lib/resources/themes/styles/color_styles.dart.

These styles provide an interface for your theme colors in light_theme_colors.dart and dart_theme_colors.dart.


File lib/resources/themes/styles/color_styles.dart

abstract class ColorStyles {

  // general
  @override
  Color get background;
  @override
  Color get content;
  @override
  Color get primaryAccent;

  @override
  Color get surfaceBackground;
  @override
  Color get surfaceContent;

  // app bar
  @override
  Color get appBarBackground;
  @override
  Color get appBarPrimaryContent;

  @override
  Color get buttonBackground;
  @override
  Color get buttonContent;

  @override
  Color get buttonSecondaryBackground;
  @override
  Color get buttonSecondaryContent;

  // bottom tab bar
  @override
  Color get bottomTabBarBackground;

  // bottom tab bar - icons
  @override
  Color get bottomTabBarIconSelected;
  @override
  Color get bottomTabBarIconUnselected;

  // bottom tab bar - label
  @override
  Color get bottomTabBarLabelUnselected;
  @override
  Color get bottomTabBarLabelSelected;

  // toast notification
  Color get toastNotificationBackground;
}
You can add additional styles here and then implement the colors in your theme.


Switching theme
Nylo supports the ability to switch themes on the fly.

E.g. If you need to switch the theme if a user taps a button to activate the "dark theme".

You can support that by doing the below:

import 'package:nylo_framework/theme/helper/ny_theme.dart';
...

TextButton(onPressed: () {

    // set theme to use the "dark theme" 
    NyTheme.set(context, id: "dark_theme");
    setState(() { });
  
  }, child: Text("Dark Theme")
),

// or

TextButton(onPressed: () {

    // set theme to use the "light theme" 
    NyTheme.set(context, id: "light_theme");
    setState(() { });
  
  }, child: Text("Light Theme")
),

Fonts
Updating your primary font throughout the app is easy in Nylo. Open the lib/config/design.dart file and update the below.

final TextStyle appThemeFont = GoogleFonts.lato();
We include the GoogleFonts library in the repository, so you can start using all the fonts with little effort. To update the font to something else, you can do the following:

// OLD
// final TextStyle appThemeFont = GoogleFonts.lato();

// NEW
final TextStyle appThemeFont = GoogleFonts.montserrat();
Check out the fonts on the official Google Fonts library to understand more

Need to use a custom font? Check out this guide - https://flutter.dev/docs/cookbook/design/fonts

Once you've added your font, change the variable like the below example.

final TextStyle appThemeFont = TextStyle(fontFamily: "ZenTokyoZoo"); // ZenTokyoZoo used as an example for the custom font

Design
The config/design.dart file is used for managing the design elements for your app.

appFont variable contains the font for your app.

logo variable is used to display your app's Logo.

You can modify resources/widgets/logo_widget.dart to customize how you want to display your Logo.

loader variable is used to display a loader. Nylo will use this variable in some helper methods as the default loader widget.

You can modify resources/widgets/loader_widget.dart to customize how you want to display your Loader.


Text Extensions
Here are the available text extensions that you can use in Nylo.

Rule Name	Usage	Info
Display Large	displayLarge()	Applies the displayLarge textTheme
Display Medium	displayMedium()	Applies the displayMedium textTheme
Display Small	displaySmall()	Applies the displaySmall textTheme
Heading Large	headingLarge()	Applies the headingLarge textTheme
Heading Medium	headingMedium()	Applies the headingMedium textTheme
Heading Small	headingSmall()	Applies the headingSmall textTheme
Title Large	titleLarge()	Applies the titleLarge textTheme
Title Medium	titleMedium()	Applies the titleMedium textTheme
Title Small	titleSmall()	Applies the titleSmall textTheme
Body Large	bodyLarge()	Applies the bodyLarge textTheme
Body Medium	bodyMedium()	Applies the bodyMedium textTheme
Body Small	bodySmall()	Applies the bodySmall textTheme
Label Large	labelLarge()	Applies the labelLarge textTheme
Label Medium	labelMedium()	Applies the labelMedium textTheme
Label Small	labelSmall()	Applies the labelSmall textTheme
Font Weight Bold	fontWeightBold	Applies font weight bold to a Text widget
Font Weight Light	fontWeightLight	Applies font weight light to a Text widget
Set Color	setColor(context, (color) => colors.primaryAccent)	Set a different text color on the Text widget
Align Left	alignLeft	Align the font to the left
Align Right	alignRight	Align the font to the right
Align Center	alignCenter	Align the font to the center
Set Max Lines	setMaxLines(int maxLines)	Set the maximum lines for the text widget


Display large
Text("Hello World").displayLarge()

Display medium
Text("Hello World").displayMedium()

Display small
Text("Hello World").displaySmall()

Heading large
Text("Hello World").headingLarge()

Heading medium
Text("Hello World").headingMedium()

Heading small
Text("Hello World").headingSmall()

Title large
Text("Hello World").titleLarge()

Title medium
Text("Hello World").titleMedium()

Title small
Text("Hello World").titleSmall()

Body large
Text("Hello World").bodyLarge()

Body medium
Text("Hello World").bodyMedium()

Body small
Text("Hello World").bodySmall()

Label large
Text("Hello World").labelLarge()

Label medium
Text("Hello World").labelMedium()

Label small
Text("Hello World").labelSmall()

Font weight bold
Text("Hello World").fontWeightBold()

Font weight light
Text("Hello World").fontWeightLight()

Set color
Text("Hello World").setColor(context, (color) => colors.content)
// Color from your colorStyles

Align left
Text("Hello World").alignLeft()

Align right
Text("Hello World").alignRight()

Align center
Text("Hello World").alignCenter()

Set max lines
Text("Hello World").setMaxLines(5)

Widgets
Assets

Introduction
Files
Displaying images
Returning files
Managing assets
Adding new files

Introduction
In this section, we'll look into how you can manage assets throughout your widgets. Nylo provides a few helper methods which make it easy to fetch images, files and more from your public/ directory.


Displaying images
You can return images by calling the below helper method.

getImageAsset('nylo_logo.png');
In your widget, it would look something like the below.

Image.asset(
  getImageAsset("nylo_logo.png"),
)

// or

Image.asset(
  "nylo_logo.png",
).localAsset()

Returning files
You can call the below helper method to get the full file path for an asset.

getPublicAsset('/images/nylo_logo.png');
This could also be any file within the public/ directory too

getPublicAsset('/video/welcome.mp4');

Adding new files
To add new files, open the public/ directory and include your files in a new folder or an existing one.

Widgets
NyState

Introduction
How to use NyState
Loading Style
State Management
State Actions
Helpers

Introduction
When you create a page in Nylo, it will extend the NyState class. This class overrides Flutter's State class and provides additional features to make development easier.

You can interact with the state extactly like you would with a normal Flutter state, but with the added benefits of the NyState.

Let's cover how to use NyState.


How to use NyState
You can start using this class by extending it.

Example

class _HomePageState extends NyState<HomePage> {

  @override
  get init => () async {
    
  };

  @override
  view(BuildContext context) {
    return Scaffold(
        body: Text("The page loaded")
    );
  }
The init method is used to initialize the state of the page. You can use this method as async or without async and behind the scenes, it will handle the async call and display a loader.

The view method is used to display the UI for the page.

Creating a new page
To create a new page in Nylo, you can run the below command.

dart run nylo_framework:main make:page product_page
// or with the alias metro
metro make:page product_page

Loading Style
You can use the loadingStyle property to set the loading style for your page.

Example

class _HomePageState extends NyState<HomePage> {

  @override
  LoadingStyleType get loadingStyle => LoadingStyleType.normal();

  @override
  get init => () async {
    await sleep(3); // simulate a network call for 3 seconds
  };
The default loadingStyle will be your loading Widget (resources/widgets/loader_widget.dart). You can customize the loadingStyle to update the loading style.

Here's a table for the different loading styles you can use: // normal, skeletonizer, none

Style	Description
normal	Default loading style
skeletonizer	Skeleton loading style
none	No loading style
You can change the loading style like this:

@override
LoadingStyle get loadingStyle => LoadingStyle.normal();
// or
@override
LoadingStyle get loadingStyle => LoadingStyle.skeletonizer();
If you want to update the loading Widget in one of the styles, you can pass a child to the LoadingStyle.

@override
LoadingStyle get loadingStyle => LoadingStyle.normal(
    child: Center(
        child: Text("Loading..."),
    ),
);
// same for skeletonizer
@override
LoadingStyle get loadingStyle => LoadingStyle.skeletonizer(
    child: Container(
        child: PageLayoutForSkeletonizer(),
    )
);
Now, when the tab is loading, the text "Loading..." will be displayed.

Example below:

class _HomePageState extends NyState<HomePage> {
    get init => () async {
        await sleep(3); // simulate a network call for 3 seconds
    };

    @override
    LoadingStyle get loadingStyle => LoadingStyle.normal(
        child: Center(
            child: Text("Loading..."),
        ),
    );

    @override
    Widget view(BuildContext context) {
        return Scaffold(
            body: Text("The page loaded")
        );
    }
    ... 
}

State Management
class _SettingsTabState extends NyState<SettingsTab> {

  _SettingsTabState() {
    stateName = SettingsTab.state;
  }

  @override
  get init => () async { 
    // handle how you want to initialize the state
    // 'stateData' will contain the data you pass to the state
  };
  
  @override
  void stateUpdated(data) {
    // e.g. to update this state from another class
    // updateState(SettingsTab.state, data: "example payload");
  }

  @override
  Widget view(BuildContext context) {
    return Container(
      child: Cart(),
    );
  }
}
Learn more about state management here. You can also watch our YouTube video on State Management here.


State Actions
In Nylo, you can define small actions in your Widgets that can be called from other classes. This is useful if you want to update the state of a widget from another class.

First, you must define your actions in your widget. This works for NyState and NyPage.

class _MyWidgetState extends NyState<MyWidget> {

  @override
  get init => () async {
    // handle how you want to initialize the state
  };

  @override
  get stateActions => {
    "hello_world_in_widget": () {
      print('Hello world');
    },
    "update_user_name": (User user) async {
      // Example with data
      _userName = user.name;
      setState(() {});
    },
    "show_toast": (String message) async {
      showToastSuccess(description: message);
    },
  };
}
Then, you can call the action from another class using the stateAction method.

stateAction('hello_world_in_widget', state: MyWidget.state);

// Another example with data
User user = User(name: "John Doe");
stateAction('update_user_name', state: MyWidget.state, data: user);
// Another example with data
stateAction('show_toast', state: MyWidget.state, data: "Hello world");
If you are using stateActions with a NyPage, you must use the path of the page.

stateAction('hello_world_in_widget', state: ProfilePage.path);

// Another example with data
User user = User(name: "John Doe");
stateAction('update_user_name', state: ProfilePage.path, data: user);

// Another example with data
stateAction('show_toast', state: ProfilePage.path, data: "Hello world");
There's also another class called StateAction, this has a few methods that you can use to update the state of your widgets.

refreshPage - Refresh the page.
pop - Pop the page.
showToastSorry - Display a sorry toast notification.
showToastWarning - Display a warning toast notification.
showToastInfo - Display an info toast notification.
showToastDanger - Display a danger toast notification.
showToastOops - Display an oops toast notification.
showToastSuccess - Display a success toast notification.
showToastCustom - Display a custom toast notification.
validate - Validate data from your widget.
changeLanguage - Update the language in the application.
confirmAction - Perform a confirm action.
Example

class _UpgradeButtonState extends NyState<UpgradeButton> {

  view(BuildContext context) {
    return Button.primary(
      onPressed: () {
        StateAction.showToastSuccess(UpgradePage.state,
          description: "You have successfully upgraded your account",
        );
      },
      text: "Upgrade",
    );
  }
}
You can use the StateAction class to update the state of any page/widget in your application as long as the widget is state managed.


Helpers
color	lockRelease
showToast	isLoading
validate	afterLoad
afterNotLocked	afterNotNull
whenEnv	setLoading
pop	isLocked
changeLanguage	confirmAction
showToastSuccess	showToastOops
showToastDanger	showToastInfo
showToastWarning	showToastSorry

Color
Returns a color from your current theme.

Example

class _HomePageState extends NyState<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Text("The page loaded", style: TextStyle(
          color: color().primaryContent
        )
      )
    );
  }

Reboot
This method will re-run the init method in your state. It's useful if you want to refresh the data on the page.

Example

class _HomePageState extends NyState<HomePage> {

  List<User> users = [];

  @override
  get init => () async {
    users = await api<ApiService>((request) => request.fetchUsers());
  };

  @override
  Widget view(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Users"),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                reboot(); // refresh the data
              },
            )
          ],
        ),
        body: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            return Text(users[index].firstName);
          }
        ),
    );
  }
}

Pop
pop - Remove the current page from the stack.

Example

class _HomePageState extends NyState<HomePage> {
  
  popView() {
    pop();
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: popView,
        child: Text("Pop current view")
      )
    );
  }

showToast
Show a toast notification on the context.

Example

class _HomePageState extends NyState<HomePage> {
  
  displayToast() {
    showToast(
        title: "Hello",
        description: "World", 
        icon: Icons.account_circle,
        duration: Duration(seconds: 2),
        style: ToastNotificationStyleType.INFO // SUCCESS, INFO, DANGER, WARNING
    );
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: displayToast,
        child: Text("Display a toast")
      )
    );
  }

validate
The validate helper performs a validation check on data.

You can learn more about the validator here.

Example

class _HomePageState extends NyState<HomePage> {
TextEditingController _textFieldControllerEmail = TextEditingController();

  handleForm() {
    String textEmail = _textFieldControllerEmail.text;

    validate(rules: {
        "email address": [textEmail, "email"]
      }, onSuccess: () {
      print('passed validation')
    });
  }

changeLanguage
You can call changeLanguage to change the json /lang file used on the device.

Learn more about localization here.

Example

class _HomePageState extends NyState<HomePage> {
  
  changeLanguageES() {
    await changeLanguage('es');
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: changeLanguageES,
        child: Text("Change Language".tr())
      )
    );
  }

whenEnv
You can use whenEnv to run a function when your application is in a certain state. E.g. your APP_ENV variable inside your .env file is set to 'developing', APP_ENV=developing.

Example

class _HomePageState extends NyState<HomePage> {

  TextEditingController _textEditingController = TextEditingController();
  
  @override
  get init => () {
    whenEnv('developing', perform: () {
      _textEditingController.text = 'test-email@gmail.com';
    });
  };

lockRelease
This method will lock the state after a function is called, only until the method has finished will it allow the user to make subsequent requests. This method will also update the state, use isLocked to check.

The best example to showcase lockRelease is to imagine that we have a login screen when the user taps 'Login'. We want to perform an async call to login the user but we don't want the method called multiple times as it could create an undesired experience.

Here's an example below.

class _LoginPageState extends NyState<LoginPage> {

  _login() async {
    await lockRelease('login_to_app', perform: () async {
      
      await Future.delayed(Duration(seconds: 4), () {
        print('Pretend to login...');
      });

    });
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLocked('login_to_app'))
              AppLoader(),
            Center(
              child: InkWell(
                onTap: _login,
                child: Text("Login"),
              ),
            )
          ],
        )
    );
  }
Once you tap the _login method, it will block any subsequent requests until the original request has finished. The isLocked('login_to_app') helper is used to check if the button is locked. In the example above, you can see we use that to determine when to display our loading Widget.


isLocked
This method will check if the state is locked using the lockRelease helper.

Example

class _HomePageState extends NyState<HomePage> {

  @override
  Widget view(BuildContext context) {
    return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLocked('login_to_app'))
              AppLoader(),
          ],
        )
    );
  }

view
The view method is used to display the UI for the page.

Example

class _HomePageState extends NyState<HomePage> {

  @override
  Widget view(BuildContext context) {
      return Scaffold(
          body: Center(
              child: Text("My Page")
          )
      );
  }
}

confirmAction
The confirmAction method will display a dialog to the user to confirm an action. This method is useful if you want the user to confirm an action before proceeding.

Example

_logout() {
 confirmAction(() {
    // logout();
 }, title: "Logout of the app?");   
}

showToastSuccess
The showToastSuccess method will display a success toast notification to the user.

Example

_login() {
    ...
    showToastSuccess(
        description: "You have successfully logged in"
    );   
}

showToastOops
The showToastOops method will display an oops toast notification to the user.

Example

_error() {
    ...
    showToastOops(
        description: "Something went wrong"
    );
}

showToastDanger
The showToastDanger method will display a danger toast notification to the user.

Example

_error() {
    ...
    showToastDanger(
        description: "Something went wrong"
    );
}

showToastInfo
The showToastInfo method will display an info toast notification to the user.

Example

_info() {
    ...
    showToastInfo(
        description: "Your account has been updated"
    );
}

showToastWarning
The showToastWarning method will display a warning toast notification to the user.

Example

_warning() {
    ...
    showToastWarning(
        description: "Your account is about to expire"
    );
}

showToastSorry
The showToastSorry method will display a sorry toast notification to the user.

Example

_sorry() {
    ...
    showToastSorry(
        description: "Your account has been suspended"
    );
}

isLoading
The isLoading method will check if the state is loading.

Example

class _HomePageState extends NyState<HomePage> {

  @override
  Widget build(BuildContext context) {
    if (isLoading()) {
      return AppLoader();
    }

    return Scaffold(
        body: Text("The page loaded", style: TextStyle(
          color: colors().primaryContent
        )
      )
    );
  }

afterLoad
The afterLoad method can be used to display a loader until the state has finished 'loading'.

You can also check other loading keys using the loadingKey parameter afterLoad(child: () {}, loadingKey: 'home_data').

Example

class _HomePageState extends NyState<HomePage> {

  @override
  get init => () {
    awaitData(perform: () async {
        await sleep(4);
        print('4 seconds after...');
    });
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: afterLoad(child: () {
          return Text("Loaded");
        })
    );
  }

afterNotLocked
The afterNotLocked method will check if the state is locked.

If the state is locked it will display the [loading] widget.

Example

class _HomePageState extends NyState<HomePage> {  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: afterNotLocked('login', child: () {
            return MaterialButton(
              onPressed: () {
                login();
              },
              child: Text("Login"),
            );
          }),
        )
    );
  }

  login() async {
    await lockRelease('login', perform: () async {
      await sleep(4);
      print('4 seconds after...');
    });
  }
}

afterNotNull
You can use afterNotNull to show a loading widget until a variable has been set.

Imagine you need to fetch a user's account from a DB using a Future call which might take 1-2 seconds, you can use afterNotNull on that value until you have the data.

Example

class _HomePageState extends NyState<HomePage> {

  User? _user;

  @override
  get init => () async {
    _user = await api<ApiService>((request) => request.fetchUser()); // example
    setState(() {});
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: afterNotNull(_user, child: () {
          return Text(_user!.firstName);
        })
    );
  }

setLoading
You can change to a 'loading' state by using setLoading.

The first parameter accepts a bool for if it's loading or not, the next parameter allows you to set a name for the loading state, e.g. setLoading(true, name: 'refreshing_content');.

Example

class _HomePageState extends NyState<HomePage> {

  @override
  get init => () async {
    setLoading(true, name: 'refreshing_content');

    await sleep(4);

    setLoading(false, name: 'refreshing_content');
  };

  @override
  Widget build(BuildContext context) {
    if (isLoading(name: 'refreshing_content')) {
      return AppLoader();
    }

    return Scaffold(
        body: Text("The page loaded")
    );
  }

  Introduction to NyFutureBuilder
The NyFutureBuilder is a helpful widget for handling Future's in your Flutter projects. It will display a loader while the future is in progress, after the Future completes, it will return the data via the child parameter.

Let's dive into some code.

We have a Future that returns a String
We want to display the data on the UI for our user
// 1. Example future that takes 3 seconds to complete
Future<String> _findUserName() async {
  await sleep(3); // wait for 3 seconds
  return "John Doe";
}

// 2. Use the NyFutureBuilder widget
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
       child: Container(
         child: NyFutureBuilder<String>(future: _findUserName(), child: (context, data) {
           // data = "John Doe"
           return Text(data!);
         },),
       ),
    ),
  );
}
This widget will handle the loading on the UI for your users until the future completes.


Customizing the NyFutureBuilder
You can pass the following parameters to the NyFutureBuilder class to customize it for your needs.

Options:
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
       child: NyFutureBuilder(
         future: NyStorage.read("product_name"), 
         child: (context, data) {
            return Text(data);
         },
         loadingStyle: LoadingStyle.normal(child: Text("Loading...")), // change the default loader
         onError: (AsyncSnapshot snapshot) { // handle exceptions thrown from your future.
           print(snapshot.error.toString());
           return Text("Error");
         },
       )
    ),
  );
}

Widgets
NyTextField

Introduction
Validation
Validation error message
Faking data
Usage
NyTextField.compact
NyTextField.emailAddress
NyTextField.password

Introduction to NyTextField
The NyTextField class is a text field widget that provides extra utility.

It provides the additional features:

Validation
Handling fake data (e.g. development)
The NyTextField widget behaves like the TextField, but it features the above additional utilities to make handing text fields easier.


Validation
You can handle validation for your text fields by providing the validationRules parameter like in the below example.

TextEditingController _textEditingController = TextEditingController();
  
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
       child: Container(
         child: NyTextField(
             controller: _textEditingController, 
             validationRules: "not_empty|postcode_uk"
         ),
       ),
    ),
  );
}
You can pass your validation rules into the validationRules parameter. See all the available validation rules here.


Validation Error Messages
Error messages will be thrown when the validation fails on the text field. You can update the error message by setting the validationErrorMessage parameter. All you need to do is pass the message you want to display when an error occurs.

TextEditingController _textEditingController = TextEditingController();
  
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
       child: Container(
         child: NyTextField(
             controller: _textEditingController, 
             validationRules: "not_empty|postcode_uk",
             validationErrorMessage: "Data is not valid"
         ),
       ),
    ),
  );
}

Faking data
When testing/developing your application, you may want to display some fake dummy data inside your text fields to speed up development.

First make sure your .env file is set to 'developing' mode.

// .env
APP_ENV="developing"
...
You can set the dummyData parameter to populate fake data.

TextEditingController _textEditingController = TextEditingController();
  
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
       child: Container(
         child: NyTextField(
             controller: _textEditingController, 
             validationRules: "not_empty|postcode_uk",
             dummyData: "B3 1JJ" // This value will be displayed
         ),
       ),
    ),
  );
}
If you need to dynamically set dummyData, try a package like faker.


Usage NyTextField Compact
The NyTextField.compact widget is a helpful widget for handling text fields in your Flutter projects.

It will display a compact text field, styled by the Nylo team.

Here's how you can start using the NyTextField.compact widget.

import 'package:nylo_framework/nylo_framework.dart';
... 
final TextEditingController myTextField = TextEditingController();

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
       child: Column(
         children: [
            NyTextField.compact(controller: myTextField)
         ],
       ),
    ),
  );
}

Usage NyTextField Email Address
The NyTextField.emailAddress widget is a helpful widget for handling email address text fields in your Flutter projects.

Here's how you can start using the NyTextField.emailAddress widget.

import 'package:nylo_framework/nylo_framework.dart';
... 
final TextEditingController myTextField = TextEditingController();

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
       child: Column(
         children: [
            NyTextField.emailAddress(controller: myTextField)
         ],
       ),
    ),
  );
}

Usage NyTextField Password
The NyTextField.password widget is a helpful widget for handling password text fields in your Flutter projects.

Here's how you can start using the NyTextField.password widget.

import 'package:nylo_framework/nylo_framework.dart';
...
final TextEditingController myTextField = TextEditingController();

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
       child: Column(
         children: [
            NyTextField.password(controller: myTextField)
         ],
       ),
    ),
  );
}

Widgets
NyPullToRefresh

Introduction
Usage
NyPullToRefresh
NyPullToRefresh.separated
NyPullToRefresh.grid
Parameters
Updating The State

Introduction
In this section, we will learn about the NyPullToRefresh widget.

The NyPullToRefresh widget is a helpful widget for handling 'pull to refresh' in your Flutter projects.

If you're not familiar with 'pull to refresh', it's essentially a ListView that can fetch more data when a user scrolls to the bottom of the list.

This makes it a great option for those with big data because you'll be able to paginate through the data in chunks.

Let's dive into some code.


Usage NyPullToRefresh
The NyPullToRefresh widget is a helpful widget for handling 'pull to refresh' lists in your Flutter projects.

Here's how you can start using the NyPullToRefresh widget.

@override
Widget build(BuildContext context) {
 return NyPullToRefresh(
    child: (context, data) {
        return ListTile(title: Text(data['title']));
    },
    data: (int iteration) async {
        return [
            {"title": "Clean Room"},
            {"title": "Go to the airport"},
            {"title": "Buy new shoes"},
            {"title": "Go shopping"},
            {"title": "Find my keys"},
            {"title": "Clear the garden"}
        ].paginate(itemsPerPage: 2, page: iteration).toList();
    },
 );
}

// or from an API Service
// this example uses the Separated ListView, it will add a divider between each item
@override
  Widget build(BuildContext context) {
    return NyPullToRefresh.separated(
        child: (context, data) {
            return ListTile(title: Text(data.title));
        },
        data: (int iteration) async {
            // Example: List<Todo> returned from an APIService
            // the iteration parameter can be used for pagination
            // each time the user pulls to refresh, the iteration will increase by 1
            return api<ApiService>((request) => request.getListOfTodos(), page: iteration);
        },
        separatorBuilder: (context, index) {
            return Divider();
        },
        stateName: "todo_list_view",
    );
  }
When the returned data is an empty array, it will stop the pagination.


Usage NyPullToRefresh Separated
The NyPullToRefresh.separated widget is a helpful widget for handling 'pull to refresh' lists with dividers in your Flutter projects.

Here's how you can start using the NyPullToRefresh.separated widget.

@override
Widget build(BuildContext context) {
return Scaffold(
    body: SafeArea(
        child: NyPullToRefresh.separated(
            child: (BuildContext context, dynamic data) {
                return ListTile(title: Text(data['title']));
            },
            data: (int iteration) async {
                return [
                    {"title": "Clean Room"},
                    {"title": "Go to the airport"},
                    {"title": "Buy new shoes"},
                    {"title": "Go shopping"},
                    {"title": "Find my keys"}
                ];
            },
            separatorBuilder: (BuildContext context, int index) {
                return Divider();
            },
        )
    )
);
}
// or from an API
@override
Widget build(BuildContext context) {
return Scaffold(
    body: SafeArea(
        child: NyPullToRefresh.separated(
            child: (BuildContext context, dynamic data) {
                return ListTile(
                    title: Text(data['title']),
                    subtitle: Text(data['completed'].toString())
                );
            },
            data: (int iteration) async {
                return await api<ApiService>((request) =>
                        request.get('https://jsonplaceholder.typicode.com/todos'));
            },
            separatorBuilder: (BuildContext context, int index) {
                return Divider();
            },
        )
    )
);
}
The NyPullToRefresh.separated widget requires three parameters:

child - This is the widget that will be displayed for each item in the list.
data - This is the data that will be displayed in the list.
separatorBuilder - This is the widget that will be displayed between each item in the list.

Usage NyPullToRefresh Grid
The NyPullToRefresh.grid widget is a helpful widget for handling 'pull to refresh' lists in a grid format in your Flutter projects.

Here's how you can start using the NyPullToRefresh.grid widget.

@override
Widget build(BuildContext context) {
return Scaffold(
    body: SafeArea(
        child: NyPullToRefresh.grid(
            child: (BuildContext context, dynamic data) {
                return ListTile(title: Text(data['title']));
            },
            data: (int iteration) async {
                return [
                    {"title": "Clean Room"},
                    {"title": "Go to the airport"},
                    {"title": "Buy new shoes"},
                    {"title": "Go shopping"},
                    {"title": "Find my keys"}
                ];
            },
            crossAxisCount: 2, // The number of rows in the grid
            // mainAxisSpacing: 1.0, // The mainAxis spacing
            // crossAxisSpacing: 1.0, // The crossAxisSpacing
        )
    )
);
}
// or from an API
@override
Widget build(BuildContext context) {
return Scaffold(
    body: SafeArea(
        child: NyPullToRefresh.grid(
            child: (BuildContext context, dynamic data) {
                return ListTile(
                    title: Text(data['title']),
                    subtitle: Text(data['completed'].toString())
                );
            },
            data: (int iteration) async {
                return await api<ApiService>((request) =>
                        request.get('https://jsonplaceholder.typicode.com/todos'));
            },
            crossAxisCount: 2, // The number of rows in the grid
            // mainAxisSpacing: 1.0, // The mainAxis spacing
            // crossAxisSpacing: 1.0, // The crossAxisSpacing
        )
    )
);
}
The NyPullToRefresh.grid widget requires two parameters:

child - This is the widget that will be displayed for each item in the list.
data - This is the data that will be displayed in the list.
The NyPullToRefresh.grid widget also has some optional parameters:

crossAxisCount - The number of rows in the grid.
mainAxisSpacing - The mainAxis spacing.
crossAxisSpacing - The crossAxisSpacing.

Parameters
Here are some important parameters you should know about before using the NyPullToRefresh widget.

Property	Type	Description
child	Widget Function(BuildContext context, dynamic data) {}	The child widget that will be displayed when the data is available.
data	Future Function(int iteration) data	The list of data you want the list view to use.
stateName	String? stateName	You can name the state using stateName, later you will need this key to update the state.
useSkeletonizer	bool useSkeletonizer	Enable loading using the skeletonizer effect
If you would like to know all the parameters available, visit this link here.


Updating the State
You can update the state of a NyPullToRefresh widget by referencing the stateName parameter.

_updateListView() {
    StateAction.refresh("todo_list_view");
}

Widgets
NyListView

Introduction
Usage
NyListView
NyListView.separated
NyListView.grid
Parameters
Updating The State

Introduction
In this section, we will learn about the NyListView widget.

The NyListView widget is a helpful widget for handling List Views in your Flutter projects.

It works in the same way as the regular ListView widget, but it has some extra features that make it easier to use.

Let's take a look at some code.


Usage NyListView
The NyListView widget is a helpful widget for handling List Views in your Flutter projects.

Here's how you can start using the NyListView widget.

@override
Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
        child: NyListView(child: (BuildContext context, dynamic data) {
            return ListTile(
                title: Text(data['title'])
            );
        }, data: () async {
            return [
                {"title": "Clean Room"},
                {"title": "Go to the airport"},
                {"title": "Buy new shoes"},
                {"title": "Go shopping"},
                {"title": "Find my keys"}
            ];
        }))
    );
}
// or from an API
@override
Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
        child: NyListView(child: (BuildContext context, dynamic data) {
            return ListTile(
                title: Text(data['title']),
                subtitle: Text(data['completed'])
            );
        }, data: () async {
            return await api<ApiService>((request) =>
                request.get('https://jsonplaceholder.typicode.com/todos'));
        }))
    );
}
The NyListView widget requires two parameters:

child - This is the widget that will be displayed for each item in the list.
data - This is the data that will be displayed in the list.

Usage NyListView Separated
The NyListView.separated widget is a helpful widget for handling List Views with dividers in your Flutter projects.

Here's how you can start using the NyListView.separated widget.

@override
Widget build(BuildContext context) {
return Scaffold(
    body: SafeArea(
        child: NyListView.separated(
            child: (BuildContext context, dynamic data) {
                return ListTile(title: Text(data['title']));
            },
            data: () async {
                return [
                    {"title": "Clean Room"},
                    {"title": "Go to the airport"},
                    {"title": "Buy new shoes"},
                    {"title": "Go shopping"},
                    {"title": "Find my keys"}
                ];
            },
            separatorBuilder: (BuildContext context, int index) {
                return Divider();
            },
        )
    )
);
}
// or from an API
@override
Widget build(BuildContext context) {
return Scaffold(
    body: SafeArea(
        child: NyListView.separated(
            child: (BuildContext context, dynamic data) {
                return ListTile(
                    title: Text(data['title']),
                    subtitle: Text(data['completed'].toString())
                );
            },
            data: () async {
                return await api<ApiService>((request) =>
                        request.get('https://jsonplaceholder.typicode.com/todos'));
            },
            separatorBuilder: (BuildContext context, int index) {
                return Divider();
            },
        )
    )
);
}
The NyListView.separated widget requires three parameters:

child - This is the widget that will be displayed for each item in the list.
data - This is the data that will be displayed in the list.
separatorBuilder - This is the widget that will be displayed between each item in the list.

Usage NyListView Grid
The NyListView.grid widget is a helpful widget for handling Grid Views in your Flutter projects.

Here's how you can start using the NyListView.grid widget.

@override
Widget build(BuildContext context) {
return Scaffold(
    body: SafeArea(
        child: NyListView.grid(
            child: (BuildContext context, dynamic data) {
                return ListTile(title: Text(data['title']));
            },
            data: () async {
                return [
                    {"title": "Clean Room"},
                    {"title": "Go to the airport"},
                    {"title": "Buy new shoes"},
                    {"title": "Go shopping"},
                    {"title": "Find my keys"}
                ];
            },
            crossAxisCount: 2, // The number of rows in the grid
            // mainAxisSpacing: 1.0, // The mainAxis spacing
            // crossAxisSpacing: 1.0, // The crossAxisSpacing
        )
    )
);
}
// or from an API
@override
Widget build(BuildContext context) {
return Scaffold(
    body: SafeArea(
        child: NyListView.grid(
            child: (BuildContext context, dynamic data) {
                return ListTile(
                    title: Text(data['title']),
                    subtitle: Text(data['completed'].toString())
                );
            },
            data: () async {
                return await api<ApiService>((request) =>
                        request.get('https://jsonplaceholder.typicode.com/todos'));
            },
            crossAxisCount: 2, // The number of rows in the grid
            // mainAxisSpacing: 1.0, // The mainAxis spacing
            // crossAxisSpacing: 1.0, // The crossAxisSpacing
        )
    )
);
}
The NyListView.grid widget requires two parameters:

child - This is the widget that will be displayed for each item in the list.
data - This is the data that will be displayed in the list.
The NyListView.grid widget also has some optional parameters:

crossAxisCount - The number of rows in the grid.
mainAxisSpacing - The mainAxis spacing.
crossAxisSpacing - The crossAxisSpacing.

Parameters
Here are some important parameters you should know about before using the NyPullToRefresh widget.

Property	Type	Description
child	Widget Function(BuildContext context, dynamic data) {}	The child widget that will be displayed when the data is available.
data	Future Function() data	The list of data you want the list view to use.
stateName	String? stateName	You can name the state using stateName, later you will need this key to update the state.
useSkeletonizer	bool useSkeletonizer	Enable loading using the skeletonizer effect
If you would like to know all the parameters available, visit this link here.


Updating the State
You can update the state of a NyListView widget by referencing the stateName parameter.

@override
  Widget build(BuildContext context) {
    return NyListView(
        child: (BuildContext context, dynamic data) {
          return ListTile(title: Text(data['title']));
          }, 
        data: () async {
          return  [
            {"title": "Clean Room"}, 
            {"title": "Go to the airport"}, 
            {"title": "Buy new shoes"}, 
            {"title": "Go shopping"},
          ];
        },
      stateName: "my_list_of_todos",
    );
  }


_updateListView() {
    updateState("my_list_of_todos");
}
This will trigger the State to reboot and load fresh data from the data parameter.

Widgets
NyLanguageSwitcher

Introduction
Usage
NyLanguageSwitcher
NyLanguageSwitcher.showBottomModal
Parameters
Methods

Introduction
In this section, we will learn about the NyLanguageSwitcher widget.

The NyLanguageSwitcher widget is a helpful widget for handling language switching in your Flutter projects. This widget will automatically detect the languages you have in your /lang directory and display them to the user.

Note: If your app isn't localized yet, learn how to do so here before using this Widget.

What does NyLanguageSwitcher do?
If the user selects a language, the app will automatically switch to that language and update the UI accordingly.

When the user opens the app again, it will remember the language they selected and display the app in that language.

Let's take a look at some code.


Usage NyLanguageSwitcher
The NyLanguageSwitcher widget is a helpful widget for handling language switching in your Flutter projects.

Here's how you can start using the NyLanguageSwitcher widget.

@override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Test Page"),
          actions: [
            NyLanguageSwitcher() // Add the NyLanguageSwitcher widget to the app bar
          ],
        )
    );
  }
When the user taps the NyLanguageSwitcher widget, a dropdown option will appear with the languages available in your /lang directory.

After the user selects a language, the app will automatically switch to that language and update the UI accordingly.


Usage NyLanguageSwitcher Show Bottom Modal
The NyLanguageSwitcher.showBottomModal widget is a helpful widget for handling language switching in your Flutter projects.

Here's how you can start using the NyLanguageSwitcher.showBottomModal widget.

@override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Text("Change Language").onTap(() {
            NyLanguageSwitcher.showBottomModal(context);
            /// This will show a bottom modal with the languages available in your `/lang` directory
          }),
        )
    );
  }
When the user taps the NyLanguageSwitcher.showBottomModal widget, a bottom modal will appear with the languages available in your /lang directory.


Parameters
Here are some parameters you should know about before using the NyLanguageSwitcher widget.

Property	Type	Description
icon	Widget?	The icon for the DropdownButton.
iconEnabledColor	Color?	The icon enabled color for the DropdownButton.
dropdownBgColor	Color?	The background color for the DropdownButton.
onLanguageChange	Function(String language)?	The function to call when the language is changed.
hint	Widget?	The hint for the DropdownButton.
itemHeight	double	The height of each item in the DropdownButton.
dropdownBuilder	Widget Function(Map<String, dynamic> language)?	The builder for the DropdownButton.
dropdownAlignment	AlignmentGeometry	The alignment for the DropdownButton.
dropdownOnTap	Function()?	The function to call when the DropdownButton is tapped.
padding	EdgeInsetsGeometry?	The padding for the DropdownButton.
onTap	Function()?	The function to call when the DropdownButton is tapped.
borderRadius	BorderRadius?	The border radius for the DropdownButton.
iconSize	int?	The size of the icon for the DropdownButton.
elevation	int?	The elevation for the DropdownButton.
langPath	String	The path to the language files.
textStyle	TextStyle	The text style for the DropdownButton.

Methods
Here are some method you should know about before using the NyLanguageSwitcher widget.

Method	Description
NyLanguageSwitcher.showBottomModal(context)	This method will show a bottom modal with the languages available in your /lang directory.
NyLanguageSwitcher.clearLanguage()	This method will clear the language from the app.
NyLanguageSwitcher.getLanguageData(String localeCode)	This method will get the language data from the app.
NyLanguageSwitcher.currentLanguage()	This method will get the current language from the app.
NyLanguageSwitcher.storeLanguage(object: {"en": "English"})

Widgets
Themes & Styling

Introduction
Themes
Light & Dark themes
Creating a theme
Configuration
Theme colors
Using colors
Base styles
Switching theme
Fonts
Design
Text Extensions

Introduction
You can manage your application's UI styles using themes. Themes allow us to change i.e. the font size of text, how buttons appear and the general appearance of our application.

If you are new to themes, the examples on the Flutter website will help you get started here.

Out of the box, Nylo includes pre-configured themes for Light mode and Dark mode.

The theme will also update if the device enters 'light/dark' mode.


Light & Dark themes
Light theme - lib/resources/themes/light_theme.dart
Dark theme - lib/resources/themes/dark_theme.dart
Inside these files, you'll find the ThemeData and ThemeStyle pre-defined.


Creating a theme
If you want to have multiple themes for your app, we have an easy way for you to do this. If you're new to themes, follow along.

First, run the below command from the terminal

dart run nylo_framework:main make:theme bright_theme
# or with metro alias
metro make:theme bright_theme
Note: replace bright_theme with the name of your new theme.

This creates a new theme in your /resources/themes/ directory and also a theme colors file in /resources/themes/styles/.

// App Themes
final List<BaseThemeConfig<ColorStyles>> appThemes = [
  BaseThemeConfig<ColorStyles>(
    id: getEnv('LIGHT_THEME_ID'),
    description: "Light theme",
    theme: lightTheme,
    colors: LightThemeColors(),
  ),
  BaseThemeConfig<ColorStyles>(
    id: getEnv('DARK_THEME_ID'),
    description: "Dark theme",
    theme: darkTheme,
    colors: DarkThemeColors(),
  ),

  BaseThemeConfig<ColorStyles>( // new theme automatically added
    id: 'Bright Theme',
    description: "Bright Theme",
    theme: brightTheme,
    colors: BrightThemeColors(),
  ),
];
You can modify the colors for your new theme in the /resources/themes/styles/bright_theme_colors.dart file.


Theme Colors
To manage the theme colors in your project, check out the lib/resources/themes/styles directory. This directory contains the style colors for the light_theme_colors.dart and dark_theme_colors.dart.

In this file, you should have something similar to the below.

// e.g Light Theme colors
class LightThemeColors implements ColorStyles {
  // general
  @override
  Color get background => const Color(0xFFFFFFFF);

  @override
  Color get content => const Color(0xFF000000);
  @override
  Color get primaryAccent => const Color(0xFF0045a0);

  @override
  Color get surfaceBackground => Colors.white;
  @override
  Color get surfaceContent => Colors.black;

  // app bar
  @override
  Color get appBarBackground => Colors.blue;
  @override
  Color get appBarPrimaryContent => Colors.white;

  // buttons
  @override
  Color get buttonBackground => Colors.blue;
  @override
  Color get buttonContent => Colors.white;

  @override
  Color get buttonSecondaryBackground => const Color(0xff151925);
  @override
  Color get buttonSecondaryContent => Colors.white.withAlpha((255.0 * 0.9).round());

  // bottom tab bar
  @override
  Color get bottomTabBarBackground => Colors.white;

  // bottom tab bar - icons
  @override
  Color get bottomTabBarIconSelected => Colors.blue;
  @override
  Color get bottomTabBarIconUnselected => Colors.black54;

  // bottom tab bar - label
  @override
  Color get bottomTabBarLabelUnselected => Colors.black45;
  @override
  Color get bottomTabBarLabelSelected => Colors.black;

  // toast notification
  @override
  Color get toastNotificationBackground => Colors.white;
}

Using colors in widgets
import 'package:flutter_app/config/theme.dart';
...

// gets the light/dark background colour depending on the theme
ThemeColor.get(context).background

// e.g. of using the "ThemeColor" class
Text(
  "Hello World",
  style: TextStyle(
      color:  ThemeColor.get(context).content // Color - content
  ),
),

// or 

Text(
  "Hello World",
  style: TextStyle(
      color:  ThemeConfig.light().colors.content // Light theme colors - primary content
  ),
),

Base styles
Base styles allow you to customize various widget colors from one area in your code.

Nylo ships with pre-configured base styles for your project located lib/resources/themes/styles/color_styles.dart.

These styles provide an interface for your theme colors in light_theme_colors.dart and dart_theme_colors.dart.


File lib/resources/themes/styles/color_styles.dart

abstract class ColorStyles {

  // general
  @override
  Color get background;
  @override
  Color get content;
  @override
  Color get primaryAccent;

  @override
  Color get surfaceBackground;
  @override
  Color get surfaceContent;

  // app bar
  @override
  Color get appBarBackground;
  @override
  Color get appBarPrimaryContent;

  @override
  Color get buttonBackground;
  @override
  Color get buttonContent;

  @override
  Color get buttonSecondaryBackground;
  @override
  Color get buttonSecondaryContent;

  // bottom tab bar
  @override
  Color get bottomTabBarBackground;

  // bottom tab bar - icons
  @override
  Color get bottomTabBarIconSelected;
  @override
  Color get bottomTabBarIconUnselected;

  // bottom tab bar - label
  @override
  Color get bottomTabBarLabelUnselected;
  @override
  Color get bottomTabBarLabelSelected;

  // toast notification
  Color get toastNotificationBackground;
}
You can add additional styles here and then implement the colors in your theme.


Switching theme
Nylo supports the ability to switch themes on the fly.

E.g. If you need to switch the theme if a user taps a button to activate the "dark theme".

You can support that by doing the below:

import 'package:nylo_framework/theme/helper/ny_theme.dart';
...

TextButton(onPressed: () {

    // set theme to use the "dark theme" 
    NyTheme.set(context, id: "dark_theme");
    setState(() { });
  
  }, child: Text("Dark Theme")
),

// or

TextButton(onPressed: () {

    // set theme to use the "light theme" 
    NyTheme.set(context, id: "light_theme");
    setState(() { });
  
  }, child: Text("Light Theme")
),

Fonts
Updating your primary font throughout the app is easy in Nylo. Open the lib/config/design.dart file and update the below.

final TextStyle appThemeFont = GoogleFonts.lato();
We include the GoogleFonts library in the repository, so you can start using all the fonts with little effort. To update the font to something else, you can do the following:

// OLD
// final TextStyle appThemeFont = GoogleFonts.lato();

// NEW
final TextStyle appThemeFont = GoogleFonts.montserrat();
Check out the fonts on the official Google Fonts library to understand more

Need to use a custom font? Check out this guide - https://flutter.dev/docs/cookbook/design/fonts

Once you've added your font, change the variable like the below example.

final TextStyle appThemeFont = TextStyle(fontFamily: "ZenTokyoZoo"); // ZenTokyoZoo used as an example for the custom font

Design
The config/design.dart file is used for managing the design elements for your app.

appFont variable contains the font for your app.

logo variable is used to display your app's Logo.

You can modify resources/widgets/logo_widget.dart to customize how you want to display your Logo.

loader variable is used to display a loader. Nylo will use this variable in some helper methods as the default loader widget.

You can modify resources/widgets/loader_widget.dart to customize how you want to display your Loader.


Text Extensions
Here are the available text extensions that you can use in Nylo.

Rule Name	Usage	Info
Display Large	displayLarge()	Applies the displayLarge textTheme
Display Medium	displayMedium()	Applies the displayMedium textTheme
Display Small	displaySmall()	Applies the displaySmall textTheme
Heading Large	headingLarge()	Applies the headingLarge textTheme
Heading Medium	headingMedium()	Applies the headingMedium textTheme
Heading Small	headingSmall()	Applies the headingSmall textTheme
Title Large	titleLarge()	Applies the titleLarge textTheme
Title Medium	titleMedium()	Applies the titleMedium textTheme
Title Small	titleSmall()	Applies the titleSmall textTheme
Body Large	bodyLarge()	Applies the bodyLarge textTheme
Body Medium	bodyMedium()	Applies the bodyMedium textTheme
Body Small	bodySmall()	Applies the bodySmall textTheme
Label Large	labelLarge()	Applies the labelLarge textTheme
Label Medium	labelMedium()	Applies the labelMedium textTheme
Label Small	labelSmall()	Applies the labelSmall textTheme
Font Weight Bold	fontWeightBold	Applies font weight bold to a Text widget
Font Weight Light	fontWeightLight	Applies font weight light to a Text widget
Set Color	setColor(context, (color) => colors.primaryAccent)	Set a different text color on the Text widget
Align Left	alignLeft	Align the font to the left
Align Right	alignRight	Align the font to the right
Align Center	alignCenter	Align the font to the center
Set Max Lines	setMaxLines(int maxLines)	Set the maximum lines for the text widget


Display large
Text("Hello World").displayLarge()

Display medium
Text("Hello World").displayMedium()

Display small
Text("Hello World").displaySmall()

Heading large
Text("Hello World").headingLarge()

Heading medium
Text("Hello World").headingMedium()

Heading small
Text("Hello World").headingSmall()

Title large
Text("Hello World").titleLarge()

Title medium
Text("Hello World").titleMedium()

Title small
Text("Hello World").titleSmall()

Body large
Text("Hello World").bodyLarge()

Body medium
Text("Hello World").bodyMedium()

Body small
Text("Hello World").bodySmall()

Label large
Text("Hello World").labelLarge()

Label medium
Text("Hello World").labelMedium()

Label small
Text("Hello World").labelSmall()

Font weight bold
Text("Hello World").fontWeightBold()

Font weight light
Text("Hello World").fontWeightLight()

Set color
Text("Hello World").setColor(context, (color) => colors.content)
// Color from your colorStyles

Align left
Text("Hello World").alignLeft()

Align right
Text("Hello World").alignRight()

Align center
Text("Hello World").alignCenter()

Set max lines
Text("Hello World").setMaxLines(5)