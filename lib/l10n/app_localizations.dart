import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Rent App'**
  String get appTitle;

  /// No description provided for @foundationReady.
  ///
  /// In en, this message translates to:
  /// **'Project Foundation Ready'**
  String get foundationReady;

  /// No description provided for @discoveryMarketplace.
  ///
  /// In en, this message translates to:
  /// **'The discovery marketplace for film, media & production.'**
  String get discoveryMarketplace;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get navEquipment;

  /// No description provided for @navProfessionals.
  ///
  /// In en, this message translates to:
  /// **'Professionals'**
  String get navProfessionals;

  /// No description provided for @navRentalHouses.
  ///
  /// In en, this message translates to:
  /// **'Rental Houses'**
  String get navRentalHouses;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover equipment and creative professionals'**
  String get homeSubtitle;

  /// No description provided for @equipmentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Production equipment'**
  String get equipmentSubtitle;

  /// No description provided for @professionalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Creative professionals'**
  String get professionalsSubtitle;

  /// No description provided for @rentalHousesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Equipment rental offices & businesses'**
  String get rentalHousesSubtitle;

  /// No description provided for @featuredRentalHouses.
  ///
  /// In en, this message translates to:
  /// **'Featured Rental Houses'**
  String get featuredRentalHouses;

  /// No description provided for @searchRentalHousesHint.
  ///
  /// In en, this message translates to:
  /// **'Search rental houses, offices...'**
  String get searchRentalHousesHint;

  /// No description provided for @individualOwner.
  ///
  /// In en, this message translates to:
  /// **'Individual Owner'**
  String get individualOwner;

  /// No description provided for @creativeProfessional.
  ///
  /// In en, this message translates to:
  /// **'Creative Professional'**
  String get creativeProfessional;

  /// No description provided for @rentalHouseOwner.
  ///
  /// In en, this message translates to:
  /// **'Rental House'**
  String get rentalHouseOwner;

  /// No description provided for @equipmentFromThisRentalHouse.
  ///
  /// In en, this message translates to:
  /// **'Equipment from this Rental House'**
  String get equipmentFromThisRentalHouse;

  /// No description provided for @noRentalHousesTitle.
  ///
  /// In en, this message translates to:
  /// **'No Rental Houses Found'**
  String get noRentalHousesTitle;

  /// No description provided for @noRentalHousesDesc.
  ///
  /// In en, this message translates to:
  /// **'There are no public rental houses available at the moment.'**
  String get noRentalHousesDesc;

  /// No description provided for @favoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Saved equipment & professionals'**
  String get favoritesSubtitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Account and settings'**
  String get profileSubtitle;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get seeAll;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAll;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @locationCairo.
  ///
  /// In en, this message translates to:
  /// **'Cairo, Egypt'**
  String get locationCairo;

  /// No description provided for @locationMaadi.
  ///
  /// In en, this message translates to:
  /// **'Maadi, Cairo'**
  String get locationMaadi;

  /// No description provided for @location6thOctober.
  ///
  /// In en, this message translates to:
  /// **'6th of October'**
  String get location6thOctober;

  /// No description provided for @perDay.
  ///
  /// In en, this message translates to:
  /// **'/ day'**
  String get perDay;

  /// No description provided for @fromPrice.
  ///
  /// In en, this message translates to:
  /// **'From EGP {price}'**
  String fromPrice(String price);

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @verifiedProvider.
  ///
  /// In en, this message translates to:
  /// **'Verified Provider'**
  String get verifiedProvider;

  /// No description provided for @verifiedProfessional.
  ///
  /// In en, this message translates to:
  /// **'Verified Professional'**
  String get verifiedProfessional;

  /// No description provided for @businessVerified.
  ///
  /// In en, this message translates to:
  /// **'Business Verified'**
  String get businessVerified;

  /// No description provided for @contactVerified.
  ///
  /// In en, this message translates to:
  /// **'Contact Verified'**
  String get contactVerified;

  /// No description provided for @availableTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Available tomorrow'**
  String get availableTomorrow;

  /// No description provided for @availableNow.
  ///
  /// In en, this message translates to:
  /// **'Available now'**
  String get availableNow;

  /// No description provided for @updatedHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'Updated {hours}h ago'**
  String updatedHoursAgo(String hours);

  /// No description provided for @yearsExperience.
  ///
  /// In en, this message translates to:
  /// **'{years}+ years experience'**
  String yearsExperience(String years);

  /// No description provided for @searchHomeHint.
  ///
  /// In en, this message translates to:
  /// **'Search equipment, professionals, brands...'**
  String get searchHomeHint;

  /// No description provided for @searchEquipmentHint.
  ///
  /// In en, this message translates to:
  /// **'Search cameras, lenses, lighting...'**
  String get searchEquipmentHint;

  /// No description provided for @searchProfessionalsHint.
  ///
  /// In en, this message translates to:
  /// **'Search professionals'**
  String get searchProfessionalsHint;

  /// No description provided for @browseCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get browseCategories;

  /// No description provided for @tabEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get tabEquipment;

  /// No description provided for @tabProfessionals.
  ///
  /// In en, this message translates to:
  /// **'Professionals'**
  String get tabProfessionals;

  /// No description provided for @catAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get catAll;

  /// No description provided for @catCameras.
  ///
  /// In en, this message translates to:
  /// **'Cameras'**
  String get catCameras;

  /// No description provided for @catLenses.
  ///
  /// In en, this message translates to:
  /// **'Lenses'**
  String get catLenses;

  /// No description provided for @catLighting.
  ///
  /// In en, this message translates to:
  /// **'Lighting'**
  String get catLighting;

  /// No description provided for @catAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get catAudio;

  /// No description provided for @catGripSupport.
  ///
  /// In en, this message translates to:
  /// **'Grip & Support'**
  String get catGripSupport;

  /// No description provided for @catDrones.
  ///
  /// In en, this message translates to:
  /// **'Drones & Motion'**
  String get catDrones;

  /// No description provided for @catDirectors.
  ///
  /// In en, this message translates to:
  /// **'Directors'**
  String get catDirectors;

  /// No description provided for @catCinematographers.
  ///
  /// In en, this message translates to:
  /// **'Cinematographers'**
  String get catCinematographers;

  /// No description provided for @catEditors.
  ///
  /// In en, this message translates to:
  /// **'Editors'**
  String get catEditors;

  /// No description provided for @catPhotographers.
  ///
  /// In en, this message translates to:
  /// **'Photographers'**
  String get catPhotographers;

  /// No description provided for @catColorists.
  ///
  /// In en, this message translates to:
  /// **'Colorists'**
  String get catColorists;

  /// No description provided for @catSoundEngineers.
  ///
  /// In en, this message translates to:
  /// **'Sound Engineers'**
  String get catSoundEngineers;

  /// No description provided for @catStylists.
  ///
  /// In en, this message translates to:
  /// **'Stylists & Art'**
  String get catStylists;

  /// No description provided for @catProduction.
  ///
  /// In en, this message translates to:
  /// **'Production'**
  String get catProduction;

  /// No description provided for @catPostProduction.
  ///
  /// In en, this message translates to:
  /// **'Post Production'**
  String get catPostProduction;

  /// No description provided for @catSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get catSound;

  /// No description provided for @catArtStyling.
  ///
  /// In en, this message translates to:
  /// **'Art & Styling'**
  String get catArtStyling;

  /// No description provided for @featuredEquipment.
  ///
  /// In en, this message translates to:
  /// **'Featured Equipment'**
  String get featuredEquipment;

  /// No description provided for @featuredProfessionals.
  ///
  /// In en, this message translates to:
  /// **'Featured Professionals'**
  String get featuredProfessionals;

  /// No description provided for @quickSearchEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get quickSearchEquipment;

  /// No description provided for @quickSearchProfessionals.
  ///
  /// In en, this message translates to:
  /// **'Professionals'**
  String get quickSearchProfessionals;

  /// No description provided for @noFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesTitle;

  /// No description provided for @noFavoritesDesc.
  ///
  /// In en, this message translates to:
  /// **'Save equipment and professionals you want to find quickly later.'**
  String get noFavoritesDesc;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @yourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get yourProfile;

  /// No description provided for @profileDesc.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save favorites, manage listings, and showcase your professional creative portfolio.'**
  String get profileDesc;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @myListings.
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get myListings;

  /// No description provided for @myEquipment.
  ///
  /// In en, this message translates to:
  /// **'My Equipment'**
  String get myEquipment;

  /// No description provided for @addEquipment.
  ///
  /// In en, this message translates to:
  /// **'Add Equipment'**
  String get addEquipment;

  /// No description provided for @equipmentSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Equipment submitted for review.'**
  String get equipmentSubmittedSuccess;

  /// No description provided for @noEquipmentTitle.
  ///
  /// In en, this message translates to:
  /// **'No equipment listings yet'**
  String get noEquipmentTitle;

  /// No description provided for @noEquipmentDesc.
  ///
  /// In en, this message translates to:
  /// **'Add your production gear to start listing it for rent.'**
  String get noEquipmentDesc;

  /// No description provided for @myProfessionalProfile.
  ///
  /// In en, this message translates to:
  /// **'Professional Profile'**
  String get myProfessionalProfile;

  /// No description provided for @portfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get portfolio;

  /// No description provided for @pendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get pendingReview;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @suspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get suspended;

  /// No description provided for @savedItems.
  ///
  /// In en, this message translates to:
  /// **'Saved Items'**
  String get savedItems;

  /// No description provided for @contacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contacts;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneLabel;

  /// No description provided for @whatsappLabel.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp number'**
  String get whatsappLabel;

  /// No description provided for @cityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityLabel;

  /// No description provided for @areaLabel.
  ///
  /// In en, this message translates to:
  /// **'Area / District'**
  String get areaLabel;

  /// No description provided for @profileTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile type'**
  String get profileTypeLabel;

  /// No description provided for @profileTypeIndividual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get profileTypeIndividual;

  /// No description provided for @profileTypeBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business / Office'**
  String get profileTypeBusiness;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordLink;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @emailValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get emailValidation;

  /// No description provided for @passwordValidation.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordValidation;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordMismatch;

  /// No description provided for @fullNameValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name.'**
  String get fullNameValidation;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully.'**
  String get profileUpdatedSuccess;

  /// No description provided for @checkEmailVerification.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Please check your email to verify your account.'**
  String get checkEmailVerification;

  /// No description provided for @invalidCredentialsError.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get invalidCredentialsError;

  /// No description provided for @userAlreadyExistsError.
  ///
  /// In en, this message translates to:
  /// **'User with this email is already registered.'**
  String get userAlreadyExistsError;

  /// No description provided for @signupDisabledError.
  ///
  /// In en, this message translates to:
  /// **'Signups are currently disabled. Please contact support.'**
  String get signupDisabledError;

  /// No description provided for @rateLimitError.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment and try again.'**
  String get rateLimitError;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection.'**
  String get networkError;

  /// No description provided for @unknownAuthError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again later.'**
  String get unknownAuthError;

  /// No description provided for @profileSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Setup'**
  String get profileSetupTitle;

  /// No description provided for @profileSetupHeading.
  ///
  /// In en, this message translates to:
  /// **'Who does this account represent?'**
  String get profileSetupHeading;

  /// No description provided for @profileSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to be identified on Rent App. You can change this anytime from your profile.'**
  String get profileSetupSubtitle;

  /// No description provided for @individualOptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individualOptionTitle;

  /// No description provided for @individualOptionDesc.
  ///
  /// In en, this message translates to:
  /// **'Freelancer, creative professional, or individual equipment owner.'**
  String get individualOptionDesc;

  /// No description provided for @businessOptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Business / Office'**
  String get businessOptionTitle;

  /// No description provided for @businessOptionDesc.
  ///
  /// In en, this message translates to:
  /// **'Equipment rental office, production company, studio, or other business.'**
  String get businessOptionDesc;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get changePhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @sameAsMobile.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp number is the same as my mobile number'**
  String get sameAsMobile;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number.'**
  String get invalidPhone;

  /// No description provided for @governorateLabel.
  ///
  /// In en, this message translates to:
  /// **'Governorate / City'**
  String get governorateLabel;

  /// No description provided for @districtLabel.
  ///
  /// In en, this message translates to:
  /// **'Area / District'**
  String get districtLabel;

  /// No description provided for @myActivitySection.
  ///
  /// In en, this message translates to:
  /// **'MY ACTIVITY'**
  String get myActivitySection;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get accountSection;

  /// No description provided for @myEquipmentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your equipment listings'**
  String get myEquipmentSubtitle;

  /// No description provided for @proProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage services & portfolio'**
  String get proProfileSubtitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Account, language & preferences'**
  String get settingsSubtitle;

  /// No description provided for @profileCompletionHeader.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get profileCompletionHeader;

  /// No description provided for @completeProfilePrompt.
  ///
  /// In en, this message translates to:
  /// **'Add missing information to boost your visibility'**
  String get completeProfilePrompt;

  /// No description provided for @businessLogo.
  ///
  /// In en, this message translates to:
  /// **'Business Logo'**
  String get businessLogo;

  /// No description provided for @businessNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Business / Office Name'**
  String get businessNameLabel;

  /// No description provided for @businessNameValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter your business / office name'**
  String get businessNameValidation;

  /// No description provided for @contactPersonLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact Person Name'**
  String get contactPersonLabel;

  /// No description provided for @fullAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Business Address'**
  String get fullAddressLabel;

  /// No description provided for @businessDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Short Business Description'**
  String get businessDescriptionLabel;

  /// No description provided for @websiteUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Website URL'**
  String get websiteUrlLabel;

  /// No description provided for @workingHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get workingHoursLabel;

  /// No description provided for @workingDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Working Days'**
  String get workingDaysLabel;

  /// No description provided for @openTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Opening Time'**
  String get openTimeLabel;

  /// No description provided for @closeTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Closing Time'**
  String get closeTimeLabel;

  /// No description provided for @accountTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountTypeLabel;

  /// No description provided for @personalOptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personalOptionTitle;

  /// No description provided for @personalOptionDesc.
  ///
  /// In en, this message translates to:
  /// **'Find equipment, professionals and rental houses. You can also list your own equipment.'**
  String get personalOptionDesc;

  /// No description provided for @professionalOptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get professionalOptionTitle;

  /// No description provided for @professionalOptionDesc.
  ///
  /// In en, this message translates to:
  /// **'Create a professional profile and portfolio, discover equipment and rental houses, and list your own equipment.'**
  String get professionalOptionDesc;

  /// No description provided for @profileTypePersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get profileTypePersonal;

  /// No description provided for @profileTypeProfessional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get profileTypeProfessional;

  /// No description provided for @myBusinessProfile.
  ///
  /// In en, this message translates to:
  /// **'My Business / Rental House'**
  String get myBusinessProfile;

  /// No description provided for @businessProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage rental house info & office details'**
  String get businessProfileSubtitle;

  /// No description provided for @accessDeniedProOnly.
  ///
  /// In en, this message translates to:
  /// **'Only professional accounts can access or manage professional profiles.'**
  String get accessDeniedProOnly;

  /// No description provided for @accessDeniedBusinessOnly.
  ///
  /// In en, this message translates to:
  /// **'Only business accounts can access or manage business profiles.'**
  String get accessDeniedBusinessOnly;

  /// No description provided for @pendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get pendingApproval;

  /// No description provided for @approvedStatus.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approvedStatus;

  /// No description provided for @contactSupportToChangeType.
  ///
  /// In en, this message translates to:
  /// **'Account type is set during setup and cannot be changed here. Contact support to change.'**
  String get contactSupportToChangeType;

  /// No description provided for @accountDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account is no longer available.'**
  String get accountDeletedMessage;

  /// No description provided for @accountSuspendedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account has been suspended. Please contact support if you believe this is a mistake.'**
  String get accountSuspendedMessage;

  /// No description provided for @accountVerificationFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t verify your account. Please try again.'**
  String get accountVerificationFailedMessage;

  /// No description provided for @sessionExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get sessionExpiredMessage;

  /// No description provided for @offlineMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. We\'ll check your account when you\'re connected again.'**
  String get offlineMessage;

  /// No description provided for @atLeastOneContactRequired.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one contact number: Phone or WhatsApp.'**
  String get atLeastOneContactRequired;

  /// No description provided for @selectAccountTypeValidation.
  ///
  /// In en, this message translates to:
  /// **'Please select an account type to continue.'**
  String get selectAccountTypeValidation;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
