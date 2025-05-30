import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import Lottie
import 'package:provider/provider.dart';
import 'dart:async'; // لإدارة عمليات التحميل المتأخر
import 'dart:developer' as developer; // DIAGNOSTIC: Added proper logging
import '../providers/theme_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/auth_provider.dart'; // Import AuthProvider
import '../services/firestore_service.dart'; // Import FirestoreService
import '../models/user_profile.dart'; // Import UserProfile model
import '../widgets/app_drawer.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'search_screen.dart';
import 'categories_screen.dart';
import 'more_screen.dart'; // Import the new MoreScreen
// DIAGNOSTIC: Removed unused dart:math import
import 'wallet_screen.dart'; // Import wallet screen for navigation
import 'login_screen.dart'; // Import LoginScreen
import 'edit_profile_screen.dart'; // Import EditProfileScreen

// Placeholder screens - we will create these later

// Removed the placeholder SearchScreen class definition
// Removed the placeholder CategoriesScreen class definition
// Removed the placeholder FavoritesScreen class definition
// Removed the placeholder AccountScreen class definition

class MainNavigationScreen extends StatefulWidget {
  // Static instance reference for profile completion check
  static MainNavigationScreenState? _instance;
  
  // Constructor now uses a regular key instead of the static key
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() {
    final state = MainNavigationScreenState();
    _instance = state;
    return state;
  }
  
  // Static method to check profile completion from anywhere
  static void checkProfileCompletion() {
    _instance?.checkProfileCompletion();
  }
  
  // Static method to wrap other screens with the bottom navigation bar
  static Widget wrapWithBottomNav({
    required BuildContext context, 
    required Widget child,
    required int selectedIndex,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Choose logo based on theme
    final logoAsset = isDarkMode
        ? 'assets/images/logo_dark.png'
        : 'assets/images/logo_white.png';
    
    // Create a scaffold that includes both app bar and bottom navigation bar
    return Scaffold(
      // Include the app bar
      appBar: AppBar(
        title: Image.asset(
          logoAsset,
          height: 40,
          errorBuilder: (context, error, stackTrace) {
            return const Text('Elsahm'); // Fallback text
          },
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                splashColor: Colors.white.withValues(alpha: 0.2),
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.menu,
                    size: 26,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ),
        actions: [
          // User balance display with wallet animation
          Container(
            margin: EdgeInsets.zero,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                // Check if user is authenticated
                if (authProvider.isAuthenticated) {
                  // Navigate to wallet screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WalletScreen()),
                  );
                } else {
                  // Show auth required dialog
                  _showStaticAuthRequiredDialog(context);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Balance amount and currency
                  if (authProvider.isAuthenticated)
                    StreamBuilder<UserProfile?>(
                      stream: FirestoreService().getUserProfileStream(
                        authProvider.user!.uid,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 16,
                            height: 16,
                            child: const CircularProgressIndicator(
                              color: Colors.grey,
                              strokeWidth: 2,
                            ),
                          );
                        }

                        final userBalance = snapshot.data?.balance ?? 0.0;
                        // Convert to int to remove decimals
                        final balanceInt = userBalance.toInt();

                        return Container(
                          margin: EdgeInsets.zero,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Price number
                              Text(
                                "$balanceInt",
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              // Currency label below the number
                              Text(
                                "جنية",
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                  // Wallet icon
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: Lottie.asset(
                      'assets/animations/wallet2.json',
                      repeat: true,
                      animate: true,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: child,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Home (Index 0)
          final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
          navigationProvider.setIndex(0);
          // Return to the main screen
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        backgroundColor: Colors.white,
        elevation: 4.0,
        shape: const CircleBorder(),
        child: Lottie.asset(
          'assets/animations/app_home_new2.json',
          width: 42,
          height: 42,
          fit: BoxFit.contain,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFF2C3E50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildStaticNavItem(
              context,
              Icons.search,
              'البحث',
              1,
              selectedIndex,
            ),
            _buildStaticNavItem(
              context,
              Icons.dashboard_outlined,
              'الاقسام',
              2,
              selectedIndex,
            ),
            const SizedBox(width: 40),
            _buildStaticNavItem(
              context,
              Icons.favorite_outline,
              'المفضلة',
              3,
              selectedIndex,
            ),
            _buildStaticNavItem(
              context,
              Icons.more_horiz_outlined,
              'المزيد',
              4,
              selectedIndex,
            ),
          ],
        ),
      ),
    );
  }
  
  // Static version of _buildNavItem for use in the static wrapper
  static Widget _buildStaticNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    int selectedIndex,
  ) {
    final bool isSelected = selectedIndex == index;
    final Color color = isSelected
        ? (Theme.of(context).brightness == Brightness.dark
            ? Colors.lightBlueAccent
            : Colors.tealAccent[400]!)
        : Colors.grey[400]!;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
            navigationProvider.setIndex(index);
            // Return to the main navigation screen
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Static method to show auth required dialog
  static void _showStaticAuthRequiredDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode 
                ? [const Color(0xFF2D3748), const Color(0xFF1A202C)]
                : [Colors.white, const Color(0xFFF7FAFC)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning animation
              SizedBox(
                height: 100,
                width: 100,
                child: Lottie.asset(
                  'assets/animations/warning.json',
                  repeat: true,
                  animate: true,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              
              // Title
              Text(
                'تسجيل الدخول مطلوب',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              // Content
              Text(
                'يجب عليك تسجيل الدخول أو إنشاء حساب للوصول إلى المحفظة وإدارة رصيدك',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Cancel button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Login button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  // حالة تحميل البيانات
  bool _isDataLoading = false;
  // DIAGNOSTIC: Removed unused _isProfileChecked field

  // قائمة الشاشات الرئيسية - تم حذف static لمنع المشاكل
  final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(), // Index 0
    SearchScreen(), // Index 1 (Placeholder for Offers)
    CategoriesScreen(fromMainScreen: true), // Index 2
    FavoritesScreen(), // Index 3 (Placeholder for Cart)
    MoreScreen(), // Index 4 - Use the new MoreScreen
  ];

  @override
  void initState() {
    super.initState();
    developer.log("==== MainNavigationScreen initState ====", name: 'MainNavigation');
    
    // تأخير تحميل البيانات لتسريع ظهور الواجهة
    _delayDataLoading();
    
    // قم بالتحقق من اكتمال الملف الشخصي بعد عدة تأخيرات متتالية
    // لضمان رؤية الرسالة حتى لو تأخر تحميل البيانات
    
    // محاولة فورية
    WidgetsBinding.instance.addPostFrameCallback((_) {
      developer.log("تحقق فوري من اكتمال الملف الشخصي", name: 'ProfileCheck');
      if (mounted) checkProfileCompletion();
    });
    
    // محاولة بعد ثانيتين
    Future.delayed(const Duration(seconds: 2), () {
      developer.log("تحقق من اكتمال الملف الشخصي بعد ثانيتين", name: 'ProfileCheck');
      if (mounted) checkProfileCompletion();
    });
    
    // محاولة بعد خمس ثوان للتأكد
    Future.delayed(const Duration(seconds: 5), () {
      developer.log("تحقق من اكتمال الملف الشخصي بعد خمس ثوان", name: 'ProfileCheck');
      if (mounted) checkProfileCompletion();
    });
  }

  // دالة للتحقق من اكتمال الملف الشخصي
  Future<void> checkProfileCompletion() async {
    developer.log("====== بدء التحقق من اكتمال الملف الشخصي ======", name: 'ProfileCheck');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    developer.log("تحقق من اكتمال الملف الشخصي - مستخدم مسجل دخول: ${authProvider.isAuthenticated}", name: 'ProfileCheck');
    developer.log("معرف المستخدم: ${authProvider.user?.uid}", name: 'ProfileCheck');
    
    // التحقق فقط إذا كان المستخدم مسجل دخول
    if (authProvider.isAuthenticated) {
      final firestoreService = FirestoreService();
      final userProfile = await firestoreService.getUserProfile(authProvider.user!.uid);
      
      developer.log("تم الحصول على الملف الشخصي: ${userProfile != null}", name: 'ProfileCheck');
      
      if (userProfile != null) {
        // التحقق مما إذا كان المستخدم جديدًا
        final isNewUser = authProvider.getAndResetIsNewUser();
        developer.log("هل المستخدم جديد: $isNewUser", name: 'ProfileCheck');
        
        // قائمة بالبيانات المفقودة
        final List<String> missingFields = [];
        
        // التحقق من البيانات المطلوبة
        if (userProfile.name.isEmpty) {
          missingFields.add("الاسم الكامل");
        }
        if (userProfile.faculty.isEmpty) {
          missingFields.add("الكلية");
        }
        if (userProfile.branch.isEmpty) {
          missingFields.add("الفرع");
        }
        if (userProfile.studentId.isEmpty) {
          missingFields.add("الرقم الجامعي");
        }
        
        developer.log("البيانات المفقودة: $missingFields، مستخدم جديد: $isNewUser", name: 'ProfileCheck');
        
        // عرض رسالة فقط في حالة وجود بيانات مفقودة
        if (missingFields.isNotEmpty) {
          if (mounted) {
            developer.log("عرض رسالة استكمال الملف الشخصي", name: 'ProfileCheck');
            _showProfileCompletionDialog(userProfile, missingFields);
          } else {
            developer.log("Widget غير مثبت، لا يمكن عرض الرسالة", name: 'ProfileCheck');
          }
        } else {
          developer.log("الملف الشخصي مكتمل، لا داعي لعرض رسالة", name: 'ProfileCheck');
        }
      } else {
        developer.log("لم يتم العثور على ملف شخصي للمستخدم", name: 'ProfileCheck');
      }
    } else {
      developer.log("المستخدم غير مسجل دخول، لا يمكن التحقق من الملف الشخصي", name: 'ProfileCheck');
    }
    developer.log("====== انتهاء التحقق من اكتمال الملف الشخصي ======", name: 'ProfileCheck');
  }

  // دالة لعرض رسالة استكمال الملف الشخصي
  void _showProfileCompletionDialog(UserProfile userProfile, List<String> missingFields) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      barrierDismissible: false, // منع إغلاق الرسالة بالنقر خارجها
      builder: (BuildContext context) {
        return PopScope(
          canPop: false, // DIAGNOSTIC: Updated from deprecated WillPopScope
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDarkMode 
                    ? [const Color(0xFF2D3748), const Color(0xFF1A202C)]
                    : [Colors.white, const Color(0xFFF7FAFC)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1), // DIAGNOSTIC: Updated from deprecated withOpacity
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // أيقونة التنبيه
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: Lottie.asset(
                      'assets/animations/warning.json',
                      repeat: true,
                      animate: true,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // عنوان الرسالة
                  Text(
                    "استكمال البيانات مطلوب",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // محتوى الرسالة
                  Text(
                    missingFields.isEmpty 
                      ? "يجب عليك استكمال بيانات ملفك الشخصي للوصول إلى جميع الخدمات"
                      : "يجب عليك استكمال البيانات التالية في ملفك الشخصي:\n• ${missingFields.join('\n• ')}",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // أزرار الإجراءات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // زر الإلغاء
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            'إلغاء',
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // زر تعديل البيانات
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // إغلاق الرسالة
                          // الانتقال إلى صفحة تعديل الملف الشخصي
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(userProfile: userProfile),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: const Text(
                          "تعديل البيانات",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // تأخير تحميل البيانات
  Future<void> _delayDataLoading() async {
    // تأخير لمدة قصيرة حتى تظهر الواجهة
    await Future.delayed(const Duration(milliseconds: 300));

    // بدء تحميل البيانات
    if (mounted) {
      setState(() {
        _isDataLoading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to both ThemeProvider and NavigationProvider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final isDarkMode =
        themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    // Choose logo based on theme (Swapped as per request)
    final logoAsset =
        isDarkMode
            ? 'assets/images/logo_dark.png'
            : 'assets/images/logo_white.png';

    developer.log(
      "Building MainNavigationScreen - Selected index: ${navigationProvider.selectedIndex}",
      name: 'MainNavigation'
    );
    developer.log("Logo asset: $logoAsset", name: 'MainNavigation');
    developer.log("Dark mode: $isDarkMode", name: 'MainNavigation');

    return Scaffold(
      appBar: AppBar(
        // DIAGNOSTIC: Removed dead code by always showing AppBar
        title: Image.asset(
          logoAsset,
          height: 40, // Increased height slightly
          errorBuilder: (context, error, stackTrace) {
            developer.log("Error loading logo: $error", name: 'MainNavigation');
            return const Text('Elsahm'); // Fallback text
          },
        ),
        centerTitle: true, // Center the logo
        leading: Builder(
          builder:
              (context) =>
                  _buildMenuButton(context, isDarkMode),
        ),
        actions: [
          // User balance display with wallet animation
          if (_isDataLoading) // عرض الرصيد فقط بعد تحميل البيانات
            _buildBalanceWidget(context, isDarkMode),
        ],
      ),
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: navigationProvider.selectedIndex, // Use index from provider
        children: _widgetOptions,
      ),
      // Custom Bottom App Bar
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => navigationProvider.setIndex(0), // Navigate to Home (Index 0)
        backgroundColor: Colors.white, // White background for the FAB
        elevation: 4.0, // Add some shadow
        shape: const CircleBorder(), // Ensure it's circular
        child: Lottie.asset(
          'assets/animations/app_home_new2.json',
          width: 42, // Reduced size
          height: 42, // Reduced size
          fit: BoxFit.contain,
          // Consider adding controller for more animation control if needed
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0, // Space around the FAB
        color:
            isDarkMode
                ? const Color(0xFF1E1E1E)
                : const Color(0xFF2C3E50), // Dark background matching image
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribute items
          children: <Widget>[
            _buildNavItem(
              context,
              navigationProvider,
              Icons.search,
              'البحث',
              1,
            ), // Search -> Index 1
            _buildNavItem(
              context,
              navigationProvider,
              Icons.dashboard_outlined,
              'الاقسام',
              2,
            ), // Categories -> Index 2
            const SizedBox(width: 40), // Spacer for the FAB notch
            _buildNavItem(
              context,
              navigationProvider,
              Icons.favorite_outline,
              'المفضلة',
              3,
            ), // Favorites -> Index 3
            _buildNavItem(
              context,
              navigationProvider,
              Icons.more_horiz_outlined,
              'المزيد',
              4,
            ), // More -> Index 4
          ],
        ),
      ),
    );
  }

  // Widget to display user balance with wallet animation
  Widget _buildBalanceWidget(BuildContext context, bool isDarkMode) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Container(
      margin: EdgeInsets.zero, // Eliminar margen para que esté en el extremo
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // Verificar si el usuario está autenticado
          if (authProvider.isAuthenticated) {
            // Si está autenticado, navegar a la pantalla de la billetera
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WalletScreen()),
            );
          } else {
            // Si no está autenticado, mostrar diálogo de requerimiento de inicio de sesión
            _showAuthRequiredDialog(context);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Balance amount and currency (a la izquierda)
            if (authProvider.isAuthenticated)
              StreamBuilder<UserProfile?>(
                stream: FirestoreService().getUserProfileStream(
                  authProvider.user!.uid,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 16,
                      height: 16,
                      child: const CircularProgressIndicator(
                        color: Colors.grey,
                        strokeWidth: 2,
                      ),
                    );
                  }

                  final userBalance = snapshot.data?.balance ?? 0.0;
                  // Convertir a entero para eliminar los decimales
                  final balanceInt = userBalance.toInt();

                  return Container(
                    margin: EdgeInsets.zero, // Eliminar el margen para reducir el espacio
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Price number (sin decimales)
                        Text(
                          "$balanceInt",
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        // Currency label below the number
                        Text(
                          "جنية",
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
            // Wallet icon on the right (a la derecha)
            SizedBox(
              width: 70, // Aumentar tamaño
              height: 70, // Aumentar tamaño
              child: Lottie.asset(
                'assets/animations/wallet2.json',
                repeat: true,
                animate: true,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para mostrar diálogo cuando se requiere autenticación
  void _showAuthRequiredDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode 
                ? [const Color(0xFF2D3748), const Color(0xFF1A202C)]
                : [Colors.white, const Color(0xFFF7FAFC)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1), // DIAGNOSTIC: Updated from deprecated withOpacity
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animación de advertencia
              SizedBox(
                height: 100,
                width: 100,
                child: Lottie.asset(
                  'assets/animations/warning.json',
                  repeat: true,
                  animate: true,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              
              // Título
              Text(
                'تسجيل الدخول مطلوب',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              // Contenido
              Text(
                'يجب عليك تسجيل الدخول أو إنشاء حساب للوصول إلى المحفظة وإدارة رصيدك',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              
              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botón de cancelar
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Botón de inicio de sesión
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Cerrar el diálogo
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom static menu button for better performance
  Widget _buildMenuButton(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          splashColor: Colors.white.withValues(alpha: 0.2), // DIAGNOSTIC: Updated from deprecated withOpacity
          onTap: () {
            Scaffold.of(context).openDrawer();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.menu,
              size: 26,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build navigation items to avoid repetition
  Widget _buildNavItem(
    BuildContext context,
    NavigationProvider navigationProvider,
    IconData icon,
    String label,
    int index,
  ) {
    final bool isSelected = navigationProvider.selectedIndex == index;
    final Color color =
        isSelected
            ? (Theme.of(context).brightness == Brightness.dark
                ? Colors.lightBlueAccent
                : Colors.tealAccent[400]!) // Use theme accent or specific color
            : Colors.grey[400]!; // Color for unselected items

    return Expanded(
      // Use Expanded to ensure equal spacing
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => navigationProvider.setIndex(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 4.0,
            ), // Reduced vertical padding
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, color: color, size: 24),
                const SizedBox(
                  height: 2,
                ), // Reduced space between icon and text
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11, // Adjust font size
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
