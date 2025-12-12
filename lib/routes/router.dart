import '/resources/pages/not_found_page.dart';
import '/resources/pages/home_page.dart';
import '/resources/pages/statistics_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* App Router
|--------------------------------------------------------------------------
| TaskFlow Todo App Router Configuration
| 
| This router handles navigation between pages with proper transitions
| and deep linking support for the TaskFlow todo application.
|
| Routes:
| - / (home) - Main task list interface
| - /statistics - Task statistics and progress view
| - /home?tab={all|today|completed} - Home with specific tab
| - /home?category={categoryId} - Home with category filter
| - /statistics?period={week|month} - Statistics with time period
|
| Learn more https://nylo.dev/docs/6.x/router
|-------------------------------------------------------------------------- */

appRouter() => nyRoutes((router) {
      // Home page - main task interface with deep linking support
      router.add(HomePage.path).initialRoute();

      // Statistics page
      router.add(StatisticsPage.path);

      // Alternative home route for deep linking
      router.add(("/", (_) => HomePage()));

      // Deep linking routes for specific app states
      router.group(() => {
        "prefix": "/app"
      }, (router) {
        // Home with tab filter: /app/home?tab=today
        router.add(("/home", (_) => HomePage()));
        
        // Statistics with period filter: /app/statistics?period=week
        router.add(("/statistics", (_) => StatisticsPage()));
      });

      // 404 Not Found page
      router.add(NotFoundPage.path).unknownRoute();
});
