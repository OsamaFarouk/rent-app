// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Rent App';

  @override
  String get foundationReady => 'Project Foundation Ready';

  @override
  String get discoveryMarketplace =>
      'The discovery marketplace for film, media & production.';

  @override
  String get navHome => 'Home';

  @override
  String get navEquipment => 'Equipment';

  @override
  String get navProfessionals => 'Professionals';

  @override
  String get navRentalHouses => 'Rental Houses';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeSubtitle => 'Discover equipment and creative professionals';

  @override
  String get equipmentSubtitle => 'Production equipment';

  @override
  String get professionalsSubtitle => 'Creative professionals';

  @override
  String get rentalHousesSubtitle => 'Equipment rental offices & businesses';

  @override
  String get featuredRentalHouses => 'Featured Rental Houses';

  @override
  String get searchRentalHousesHint => 'Search rental houses, offices...';

  @override
  String get individualOwner => 'Individual Owner';

  @override
  String get creativeProfessional => 'Creative Professional';

  @override
  String get rentalHouseOwner => 'Rental House';

  @override
  String get equipmentFromThisRentalHouse => 'Equipment from this Rental House';

  @override
  String get noRentalHousesTitle => 'No Rental Houses Found';

  @override
  String get noRentalHousesDesc =>
      'There are no public rental houses available at the moment.';

  @override
  String get favoritesSubtitle => 'Saved equipment & professionals';

  @override
  String get profileSubtitle => 'Account and settings';

  @override
  String get seeAll => 'View all';

  @override
  String get showAll => 'Show all';

  @override
  String get showLess => 'Show less';

  @override
  String get locationCairo => 'Cairo, Egypt';

  @override
  String get locationMaadi => 'Maadi, Cairo';

  @override
  String get location6thOctober => '6th of October';

  @override
  String get perDay => '/ day';

  @override
  String fromPrice(String price) {
    return 'From EGP $price';
  }

  @override
  String get verified => 'Verified';

  @override
  String get verifiedProvider => 'Verified Provider';

  @override
  String get verifiedProfessional => 'Verified Professional';

  @override
  String get businessVerified => 'Business Verified';

  @override
  String get contactVerified => 'Contact Verified';

  @override
  String get availableTomorrow => 'Available tomorrow';

  @override
  String get availableNow => 'Available now';

  @override
  String updatedHoursAgo(String hours) {
    return 'Updated ${hours}h ago';
  }

  @override
  String yearsExperience(String years) {
    return '$years+ years experience';
  }

  @override
  String get searchHomeHint => 'Search equipment, professionals, brands...';

  @override
  String get searchEquipmentHint => 'Search cameras, lenses, lighting...';

  @override
  String get searchProfessionalsHint => 'Search professionals';

  @override
  String get browseCategories => 'Categories';

  @override
  String get tabEquipment => 'Equipment';

  @override
  String get tabProfessionals => 'Professionals';

  @override
  String get catAll => 'All';

  @override
  String get catCameras => 'Cameras';

  @override
  String get catLenses => 'Lenses';

  @override
  String get catLighting => 'Lighting';

  @override
  String get catAudio => 'Audio';

  @override
  String get catGripSupport => 'Grip & Support';

  @override
  String get catDrones => 'Drones & Motion';

  @override
  String get catDirectors => 'Directors';

  @override
  String get catCinematographers => 'Cinematographers';

  @override
  String get catEditors => 'Editors';

  @override
  String get catPhotographers => 'Photographers';

  @override
  String get catColorists => 'Colorists';

  @override
  String get catSoundEngineers => 'Sound Engineers';

  @override
  String get catStylists => 'Stylists & Art';

  @override
  String get catProduction => 'Production';

  @override
  String get catPostProduction => 'Post Production';

  @override
  String get catSound => 'Sound';

  @override
  String get catArtStyling => 'Art & Styling';

  @override
  String get featuredEquipment => 'Featured Equipment';

  @override
  String get featuredProfessionals => 'Featured Professionals';

  @override
  String get quickSearchEquipment => 'Equipment';

  @override
  String get quickSearchProfessionals => 'Professionals';

  @override
  String get noFavoritesTitle => 'No favorites yet';

  @override
  String get noFavoritesDesc =>
      'Save equipment and professionals you want to find quickly later.';

  @override
  String get explore => 'Explore';

  @override
  String get yourProfile => 'Your Profile';

  @override
  String get profileDesc =>
      'Sign in to save favorites, manage listings, and showcase your professional creative portfolio.';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get signOut => 'Sign out';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get myListings => 'My Listings';

  @override
  String get myEquipment => 'My Equipment';

  @override
  String get addEquipment => 'Add Equipment';

  @override
  String get equipmentSubmittedSuccess => 'Equipment submitted for review.';

  @override
  String get noEquipmentTitle => 'No equipment listings yet';

  @override
  String get noEquipmentDesc =>
      'Add your production gear to start listing it for rent.';

  @override
  String get myProfessionalProfile => 'Professional Profile';

  @override
  String get portfolio => 'Portfolio';

  @override
  String get pendingReview => 'Pending Review';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String get suspended => 'Suspended';

  @override
  String get savedItems => 'Saved Items';

  @override
  String get contacts => 'Contacts';

  @override
  String get settings => 'Settings';

  @override
  String get emailLabel => 'Email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get whatsappLabel => 'WhatsApp number';

  @override
  String get cityLabel => 'City';

  @override
  String get areaLabel => 'Area / District';

  @override
  String get profileTypeLabel => 'Profile type';

  @override
  String get profileTypeIndividual => 'Individual';

  @override
  String get profileTypeBusiness => 'Business / Office';

  @override
  String get forgotPasswordLink => 'Forgot password?';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get emailValidation => 'Please enter a valid email address.';

  @override
  String get passwordValidation => 'Password must be at least 6 characters.';

  @override
  String get passwordMismatch => 'Passwords do not match.';

  @override
  String get fullNameValidation => 'Please enter your full name.';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully.';

  @override
  String get checkEmailVerification =>
      'Registration successful! Please check your email to verify your account.';

  @override
  String get invalidCredentialsError => 'Invalid email or password.';

  @override
  String get userAlreadyExistsError =>
      'User with this email is already registered.';

  @override
  String get signupDisabledError =>
      'Signups are currently disabled. Please contact support.';

  @override
  String get rateLimitError =>
      'Too many requests. Please wait a moment and try again.';

  @override
  String get networkError =>
      'Network error. Please check your internet connection.';

  @override
  String get unknownAuthError => 'An error occurred. Please try again later.';

  @override
  String get profileSetupTitle => 'Account Setup';

  @override
  String get profileSetupHeading => 'Who does this account represent?';

  @override
  String get profileSetupSubtitle =>
      'Choose how you want to be identified on Rent App. You can change this anytime from your profile.';

  @override
  String get individualOptionTitle => 'Individual';

  @override
  String get individualOptionDesc =>
      'Freelancer, creative professional, or individual equipment owner.';

  @override
  String get businessOptionTitle => 'Business / Office';

  @override
  String get businessOptionDesc =>
      'Equipment rental office, production company, studio, or other business.';

  @override
  String get continueButton => 'Continue';

  @override
  String get changePhoto => 'Change profile photo';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get sameAsMobile => 'WhatsApp number is the same as my mobile number';

  @override
  String get invalidPhone => 'Please enter a valid phone number.';

  @override
  String get governorateLabel => 'Governorate / City';

  @override
  String get districtLabel => 'Area / District';

  @override
  String get myActivitySection => 'MY ACTIVITY';

  @override
  String get accountSection => 'ACCOUNT';

  @override
  String get myEquipmentSubtitle => 'Manage your equipment listings';

  @override
  String get proProfileSubtitle => 'Manage services & portfolio';

  @override
  String get settingsSubtitle => 'Account, language & preferences';

  @override
  String get profileCompletionHeader => 'Complete Your Profile';

  @override
  String get completeProfilePrompt =>
      'Add missing information to boost your visibility';

  @override
  String get businessLogo => 'Business Logo';

  @override
  String get businessNameLabel => 'Business / Office Name';

  @override
  String get businessNameValidation =>
      'Please enter your business / office name';

  @override
  String get contactPersonLabel => 'Contact Person Name';

  @override
  String get fullAddressLabel => 'Full Business Address';

  @override
  String get businessDescriptionLabel => 'Short Business Description';

  @override
  String get websiteUrlLabel => 'Website URL';

  @override
  String get workingHoursLabel => 'Working Hours';

  @override
  String get workingDaysLabel => 'Working Days';

  @override
  String get openTimeLabel => 'Opening Time';

  @override
  String get closeTimeLabel => 'Closing Time';

  @override
  String get accountTypeLabel => 'Account Type';

  @override
  String get personalOptionTitle => 'Personal';

  @override
  String get personalOptionDesc =>
      'Find equipment, professionals and rental houses. You can also list your own equipment.';

  @override
  String get professionalOptionTitle => 'Professional';

  @override
  String get professionalOptionDesc =>
      'Create a professional profile and portfolio, discover equipment and rental houses, and list your own equipment.';

  @override
  String get profileTypePersonal => 'Personal';

  @override
  String get profileTypeProfessional => 'Professional';

  @override
  String get myBusinessProfile => 'My Business / Rental House';

  @override
  String get businessProfileSubtitle =>
      'Manage rental house info & office details';

  @override
  String get accessDeniedProOnly =>
      'Only professional accounts can access or manage professional profiles.';

  @override
  String get accessDeniedBusinessOnly =>
      'Only business accounts can access or manage business profiles.';

  @override
  String get pendingApproval => 'Pending Review';

  @override
  String get approvedStatus => 'Approved';

  @override
  String get contactSupportToChangeType =>
      'Account type is set during setup and cannot be changed here. Contact support to change.';

  @override
  String get accountDeletedMessage => 'Your account is no longer available.';

  @override
  String get accountSuspendedMessage =>
      'Your account has been suspended. Please contact support if you believe this is a mistake.';

  @override
  String get accountVerificationFailedMessage =>
      'We couldn\'t verify your account. Please try again.';

  @override
  String get sessionExpiredMessage =>
      'Your session has expired. Please sign in again.';

  @override
  String get offlineMessage =>
      'You\'re offline. We\'ll check your account when you\'re connected again.';

  @override
  String get atLeastOneContactRequired =>
      'Please add at least one contact number: Phone or WhatsApp.';

  @override
  String get selectAccountTypeValidation =>
      'Please select an account type to continue.';
}
